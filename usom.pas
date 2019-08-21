unit usom;

interface

uses windows, classes, mmsystem, winsock;

const PORT_NUMBER = 1500;
      BLOCK_SIZE = 65;
      NUM_BLOCKS = 25;

type
   PGSM610WaveFormat = ^TGSM610WaveFormat;
   TGSM610WaveFormat = record
      wf: tWAVEFORMATEX;
      wSamplesPerBlock : Word;
   end;

    XMITDATA = record
      m_dwSeq : DWORD; // Número de seqüência do bloco
      m_nSize : cardinal; //T_BSIZE ; // Tamanho do bloco em bytes
      m_nSizeP : cardinal; // T_BSIZE ; // Tamanho do bloco anterior (previous)
      m_abData : array [0..BLOCK_SIZE-1] of byte; // Bloco de dados a ser transmitido
      m_abDataP: array [0..BLOCK_SIZE-1] of byte; // Bloco de dados anterior
    end;


//    wavehdr_tag = record
//      lpData         : LPSTR ; //* apontador para buffer de dados */
//      dwBufferLength : DWORD ; //* tamanho do bloco em bytes */
//      dwBytesRecorded: DWORD ; //* usado apenas para entrada */
//      dwUser         : DWORD ; //* livre para uso do cliente */
//      dwFlags        : DWORD ; //* flags (veja definições) */
//      dwLoops        : DWORD ; //* contador de loops de controle */
//      lpNext         : PWaveHdr; ///* reservado para driver */
//      reserved       : DWORD ; /* reservado para driver */
//    end;
//    PWAVEHDR = ^wavehdr_tag;


  TSoundDialog = class
    protected
      m_hWnd : HWND; // Handle para janela de diálogo
      m_hWaveIn : HWAVEIN ; // Handle para dispositivo de captura de áudio
      m_aInBlocks : array [0..25{NUM_BLOCKS}] of integer; //CsendBuffer ; // Buffers de captura
      m_iCountIn : integer; // Itens na fila de captura
      m_dwOutSeq : DWORD; // Contador de seqüência de blocos enviados
      m_SockAddr : TSockAddr;
      m_nPrevSize : integer;
      m_Socket : TSocket;
      m_hWaveOut : HWAVEOUT;
      m_fOutClosing, m_fInClosing : boolean;
      procedure OnConnect();
      procedure OnWimOpen();
  end;

  TRecvBuffer = class
  protected
    m_WaveHeader : WAVEHDR; // cabeçalho do buffer
    m_Data : XMITDATA ; // Bloco de dados a ser transmitido via UDP
  public
    function Unprepare(hWaveOut:HWAVEOUT) : MMRESULT;
    function Add(hWaveOut:HWAVEOUT) : MMRESULT;
    function Prepare(hWaveOut:HWAVEOUT) : MMRESULT;
  end;


implementation

procedure TSoundDialog.OnConnect;
var szIPAddress : array [0..127] of char;
    ulAddrIP : cardinal;
    _pHostEnt : PHostEnt;
    WaveFormatGSM : TGSM610WaveFormat; //   GSM610WAVEFORMAT ;
    mmRC : MMRESULT;
begin
    // método da classe CSoundDialog

    ZeroMemory(@m_SockAddr, sizeof(m_SockAddr));
    m_nPrevSize := 0; // Inicializa tamanho do buffer anterior
    // Obtém endereço IP remoto do host
    GetDlgItemText(m_hWnd,0{IDC_EDIT_REMOTEIPADDR},szIPAddress, sizeof(szIPAddress));
    ulAddrIP := inet_addr(szIPAddress);

    if not ulAddrIP = INADDR_NONE then  // Endereço na forma x.y.z.w ?
      CopyMemory(@m_SockAddr.sin_addr, @ulAddrIP, sizeof(m_SockAddr.sin_addr))
      //memcpy(&(m_SockAddr.sin_addr), &ulAddrIP, sizeof(m_SockAddr.sin_addr));
    else
      begin// Use DNS para obter endereço IP
      _pHostEnt := gethostbyname(szIPAddress);
      if _pHostEnt = nil then
        begin
        MessageBox(m_hWnd, 'Erro resolvendo nome remoto', 'Erro',
                   MB_OK or MB_ICONSTOP);
        exit;
        end;


      CopyMemory(@m_SockAddr.sin_addr, @_pHostEnt.h_addr, _pHostEnt.h_length);
      //memcpy(&(m_SockAddr.sin_addr), pHostEnt->h_addr, pHostEnt->h_length);
      end;

    // Cria um socket e o associa a um port
    m_Socket := socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    m_SockAddr.sin_family := AF_INET;
    m_SockAddr.sin_port := htons(PORT_NUMBER);
    bind(m_Socket, m_SockAddr, sizeof(m_SockAddr));

    // Define o endereço remoto m_SockAddr para comunicações futuras
    // Conecta
    connect(m_Socket, m_SockAddr, sizeof(m_SockAddr));

    // Inicializa o dispositivo de entrada de dados: wave input
    // Abre dispositivo de captura e reprodução para GSM 6.10
    WaveFormatGSM.wf.wFormatTag := $31; //WAVE_FORMAT_GSM610;
    WaveFormatGSM.wf.nChannels := 1; // mono
    WaveFormatGSM.wf.nSamplesPerSec := 8000; // sample rate
    WaveFormatGSM.wf.nAvgBytesPerSec := 1625; // data rate = 1625 bytes/s
    // Block alignment = menor quant de dados codec pode processar de uma vez
    WaveFormatGSM.wf.nBlockAlign := 65;
    WaveFormatGSM.wf.wBitsPerSample := 0;
    // para este codec o número de bits por amostra não é especificado
    WaveFormatGSM.wf.cbSize := 2;
    // bytes de info extra apendados ao final da estrutura WAVEFORMATEX
    WaveFormatGSM.wSamplesPerBlock := 320;
    // Abre dispositivo de reprodução
    mmRC := waveOutOpen(@m_hWaveOut, // handle do dispositivo
                        WAVE_MAPPER, // Id do dispositivo
                        @WaveFormatGSM.wf,
                        m_hWnd, // função callback, janela, ev...
                        0, // parâmetro função callback
                        CALLBACK_WINDOW); // callback é handle jan.

    if not (mmRC = MMSYSERR_NOERROR) then
        //Showmessage('Erro abrindo dispositivo de reprodução wave\r\n');
    else
      begin
      m_fOutClosing := false;
      end;

    // Abre dispositivo de entrada
    mmRC := waveInOpen(@m_hWaveIn,
                       WAVE_MAPPER,
                       @WaveFormatGSM.wf,
                       m_hWnd,
                       0,
                       CALLBACK_WINDOW);

    if not (mmRC = MMSYSERR_NOERROR) then
   //    Report("Não conseguiu abrir dispositivo de entrada wave\r\n");
    else
      begin
      m_fInClosing := false;
      waveInStart(m_hWaveIn);
      end;

    if not (m_fInClosing and m_fOutClosing) then
      begin
      // Se pelo menos um dos dispositivos foi iniciado
      EnableWindow(GetDlgItem(m_hWnd, 0{IDC_BUTTON_CONNECT}),
                   FALSE); // Desabilita botão connect
      EnableWindow(GetDlgItem(m_hWnd, 1{IDC_BUTTON_DISCONNECT}),
                   TRUE); // Habilita botão disconnect
      end;
end;

procedure TSoundDialog.OnWimOpen;
var
  i: integer;
begin
  m_dwOutSeq := 0; // reseta seqüência de blocos enviados
  m_iCountIn := 0; // reseta contador de blocos na fila

  for i := 0 to NUM_BLOCKS-1 do
    begin
    // são 25 buffers prepara e adiciona blocos para capturar
    //a fila do dispositivo
    m_aInBlocks[i].Prepare(m_hWaveIn); // Prepara buffer
    m_aInBlocks[i].Add(m_hWaveIn); // Envia para dispositivo encher
    m_iCountIn := m_iCountIn+1;
    end;


end;

{ TRecvBuffer }

function TRecvBuffer.Add(hWaveOut: HWAVEOUT): MMRESULT;
begin
  result := waveOutWrite(hWaveOut, @m_WaveHeader, sizeof(m_WaveHeader));
end;

function TRecvBuffer.Prepare(hWaveOut: HWAVEOUT): MMRESULT;
begin
  ZeroMemory(@m_WaveHeader, sizeof(m_WaveHeader));
  m_WaveHeader.dwBufferLength := BLOCK_SIZE;
  m_WaveHeader.lpData := m_Data.m_abData;

  // Campo livre para uso do usuário. Não é usado pelas funções de áudio
  m_WaveHeader.dwUser := cardinal(self); // aponta obj. CrecvBuffer

  // Prepara um bloco de áudio para playback
  result := waveOutPrepareHeader(hWaveOut, @m_WaveHeader, sizeof(m_WaveHeader));

end;

function TRecvBuffer.Unprepare(hWaveOut: HWAVEOUT): MMRESULT;
begin
  // Deve ser chamada depois que o device driver reproduziu o bloco de dados
  // Você deve chamar esta função antes de liberar o buffer
  result := waveOutUnprepareHeader(hWaveOut, @m_WaveHeader,
                                     sizeof(m_WaveHeader));
end;

end.


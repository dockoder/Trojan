unit usrvsound;

interface

uses windows, sysutils ,classes, mmsystem;

const NUM_BLOCKS = 25;
      BLOCK_SIZE = 65;

type
  TTimer = class(TThread)

  end;

  PGSM610WaveFormat = ^TGSM610WaveFormat;
  TGSM610WaveFormat = record
    wf: tWAVEFORMATEX;
    wSamplesPerBlock : Word;
  end;

  XMITDATA = record
    cSeq   ,           // Número de seqüência do bloco
    cSize  ,           //T_BSIZE ; // Tamanho do bloco em bytes
    cSizeP : cardinal; // T_BSIZE ; // Tamanho do bloco anterior (previous)
    abData : array [0..BLOCK_SIZE-1] of byte; // Bloco de dados a ser transmitido
    abDataP: array [0..BLOCK_SIZE-1] of byte; // Bloco de dados anterior
  end;
  PXMITDATA = ^XMITDATA;

  TarrWaveInCaps = array of TWaveInCaps;

  TOnData = procedure (data : pchar; datasize : integer) of object;

  TCaptureSound = class
  private
    FCaptureOK : boolean;
    FError : integer;
    FGsmWF : TGSM610WaveFormat;
    FWaveIn : HWAVEIN;
    FWaveHdr : WAVEHDR;
    FBufferList : TList;

    FListDevices : TarrWaveInCaps;

    FErroText : string;
    FErroCode : integer;

    FOnData : TOnData;
    function GetListDevices: TarrWaveInCaps;

   // FBlocks : array [0..NUM_BLOCKS-1] of XMITDATA;
    function IsFormatSupported (wfx:tWAVEFORMATEX)  : boolean;

    function CreateBuffer : boolean;
    procedure DestroyBuffer;

    procedure SetErro(text:string; code:integer);
  public
    constructor Create;
    destructor Destroy; override;

    function Start : integer;
    procedure Stop;

    property ErroText : string
      read FErroText;
    property ErroCode : integer
      read FErroCode;

    property ListDevices : TarrWaveInCaps
      read GetListDevices;


    property OnData : TOnData
      read FOnData
      write FOnData;
  end;

//procedure WaveInProc (hwi :HWAVEIN; uMsg : WORD ; dwInstance, dwParam1, dwParam2 : cardinal);

implementation

procedure WaveInProc (hwi :HWAVEIN; uMsg : LongWord ; dwInstance : Pointer;
                      dwParam1, dwParam2 : LongWord); stdcall;
var whdr : PWAVEHDR;
    caps : TCaptureSound;
begin


    if uMsg = WIM_DATA then
      begin
      //saca o wave header
      whdr := PWaveHdr(dwInstance);
      //desprepara o buffer para ser usado
      waveInUnprepareHeader(hwi , whdr, sizeof(whdr) ) ;

      //saca a classe que detem o buffer
      caps := TCaptureSound (whdr.dwUser);
      //se os bytes gravados sao maior que 0...
      //e o evento OnData esta assinado entao passa o buffer
      //ao evento.
      if whdr.dwBytesRecorded > 0 then
        if Assigned(caps.FOnData) then
          caps.FOnData(whdr.lpData, whdr.dwBytesRecorded);
      end;

end;

{ TCaptureSound }

constructor TCaptureSound.Create;
begin
  FCaptureOK := false;
  FError := 0;
  FBufferList := TList.Create;

  // Inicializa o dispositivo de entrada de dados: wave input
    // Abre dispositivo de captura e reprodução para GSM 6.10
    FGsmWF.wf.wFormatTag := $31; //WAVE_FORMAT_GSM610;
    FGsmWF.wf.nChannels := 1; // mono
    FGsmWF.wf.nSamplesPerSec := 8000; // sample rate
    FGsmWF.wf.nAvgBytesPerSec := 1625; // data rate = 1625 bytes/s
    // Block alignment = menor quant de dados codec pode processar de uma vez
    FGsmWF.wf.nBlockAlign := 65;
    FGsmWF.wf.wBitsPerSample := 0;
    // para este codec o número de bits por amostra não é especificado
    FGsmWF.wf.cbSize := 2;
    // bytes de info extra adicionados ao final da estrutura WAVEFORMATEX
    FGsmWF.wSamplesPerBlock := 320;


    if not IsFormatSupported (FGsmWF.wf) then exit;

    try
      FError := waveInOpen(@FWaveIn, // handle do dispositivo
                           WAVE_MAPPER, // Id do dispositivo
                           @FGsmWF.wf,
                           DWORD(@WaveInProc),//m_hWnd, // função callback, janela, ev...
                           DWORD(self), // parâmetro função callback
                           CALLBACK_FUNCTION); // callback é handle jan.

      FCaptureOK := true;
      SetErro('TCaptureSound.Create - waveInStart', -1);
    except
      SetErro('TCaptureSound.Create', -1);
    end;
end;

function TCaptureSound.CreateBuffer : boolean;
var px : PXMITDATA;
    whdr : PWaveHdr;
    I: Integer;
begin
  result := true;
  try
    for I := 0 to NUM_BLOCKS - 1 do
      begin
      New(px);
      New(whdr);

      //adiciona na lista de buffers
      FBufferList.Add(px);

      whdr.dwBufferLength := BLOCK_SIZE;
      whdr.lpData := pansichar(@px.abData);
      whdr.dwUser := cardinal(self);

      //preparar o buffer
      waveInPrepareHeader(FWaveIn,whdr, sizeof(WaveHdr) ) ;
      //adicionar o buffer
      waveInAddBuffer(FWaveIn,whdr, sizeof(WaveHdr) ) ;
      end;
  except
     SetErro( Format('TCaptureSound.CreateBuffer. Interação= %d', [i]), -1);
     result := false;
  end;
end;

destructor TCaptureSound.Destroy;
begin
  try
    waveInReset(FWaveIn);
    waveInClose(FWaveIn);
    FBufferList.Free;
  except end;
  inherited;
end;

procedure TCaptureSound.DestroyBuffer;
var
  I: Integer;
begin
  try
    for I := 0 to FBufferList.Count - 1 do
      Dispose(FBufferList[i]);
  except end;
end;

function TCaptureSound.GetListDevices: TarrWaveInCaps;
var
  I, iNumDevs: Integer;
  wic : TWaveInCaps;
begin
  SetLength(FListDevices, 0);

  try
    iNumDevs := waveInGetNumDevs();

    for I := 0 to iNumDevs-1 do
      if waveInGetDevCaps(i, @wic, sizeof(TWAVEINCAPS)) = MMSYSERR_NOERROR then
        begin
          SetLength(FListDevices, length(FListDevices) + 1);
          FListDevices[high(FListDevices)] := wic;
        end;
  except end;
end;

function TCaptureSound.IsFormatSupported(wfx: tWAVEFORMATEX): boolean;
begin
  try
    result :=  MMSYSERR_NOERROR =
              waveInOpen(0, WAVE_MAPPER, @FGsmWF.wf,
                         0, 0, WAVE_FORMAT_QUERY);
  except
    result := false;
  end;
end;

procedure TCaptureSound.SetErro(text: string; code: integer);
begin
  FErroText := text;
  FErroCode := code;
end;

function TCaptureSound.Start : integer;
begin
  if CreateBuffer then
   Result := waveInStart(FWaveIn);
end;

procedure TCaptureSound.Stop;
begin
   waveInStop(FWaveIn);
   DestroyBuffer;
end;

end.

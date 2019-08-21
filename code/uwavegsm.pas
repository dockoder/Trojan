unit uwavegsm;

interface

uses classes,
     uwave, uwaverec, mmsystem;

const GSM_NUM_BLOCKS = 25;
      GSM_BLOCK_SIZE = 65;

type
  PGSM610WaveFormat = ^TGSM610WaveFormat;
  TGSM610WaveFormat = record
    wf: tWAVEFORMATEX;
    wSamplesPerBlock : Word;
  end;

  TGSMRec = class(TSoundRecorder)
  private
    FGsmWf : TGSM610WaveFormat;
    FBufferList : Tlist;
    FBufferIdx : integer;
    FRecording: boolean;
    FOnDataAvail: TDataAvailEvent;
    function IsFormatSupported (wfx:tWAVEFORMATEX)  : boolean;
  protected
    procedure AddBuffers;
    procedure WaveProc(const handle:THandle;
                      const msg:UINT;
                      const dwInstance:cardinal;
                      const dwParam1,dwParam2:cardinal);override;
  public
    constructor Create;override;
    destructor Destroy;override;
    procedure Open;override;
    procedure Close;override;
    procedure Start;override;
  published
    property Recording:boolean read FRecording;
  end;

implementation

{ TGSMRec }

procedure TGSMRec.AddBuffers;
var
  I: Integer;
begin
  for I := 0 to FBufferList.Count - 1 do
    if FBufferList[i]<>nil then
      WaveInAddBuffer(Handle,PWaveHdr(FBufferList[i]),sizeof(TWaveHdr));
end;

procedure TGSMRec.Close;
var
  I: Integer;
begin
  if Handle<>0 then
  begin
    FRecording := false;
    Stop;
    for I := 0 to FBufferList.Count - 1 do
      if FBufferList[i]<>nil then
       waveInUnPrepareHeader(Handle,FBufferList[i],Sizeof(TWaveHdr));
    FHandle:=0;
  end;
end;

constructor TGSMRec.Create;
var
  I: Integer;
  pBuf : PWaveHdr;
begin
  FBufferIdx := GSM_NUM_BLOCKS - 1;
  FilePath := '';
  Keep := false;

  // Inicializa o dispositivo de entrada de dados: wave input
  // Abre dispositivo de captura e reprodução para GSM 6.10
  FWaveFormat.wFormatTag := $31; //WAVE_FORMAT_GSM610;
  FWaveFormat.nChannels := 1; // mono
  FWaveFormat.nSamplesPerSec := 8000; // sample rate
  FWaveFormat.nAvgBytesPerSec := 1625; // data rate = 1625 bytes/s
  // Block alignment = menor quant de dados codec pode processar de uma vez
  FWaveFormat.nBlockAlign := 65;
  FWaveFormat.wBitsPerSample := 0;
  // para este codec o número de bits por amostra não é especificado
  FWaveFormat.cbSize := 2;
  // bytes de info extra adicionados ao final da estrutura WAVEFORMATEX
  FGsmWF.wf := FWaveFormat;
  FGsmWF.wSamplesPerBlock := 320;

  FBufferList := TList.Create;

  for I := 0 to GSM_NUM_BLOCKS do
    begin
    new(pBuf);
    FBufferList.Add(pBuf); //adiciona o pointer WaveHdr na lista de buffers
    GetMem(pBuf.lpData,GSM_BLOCK_SIZE); //cria memoria para os dados
    pBuf.dwBufferLength := GSM_BLOCK_SIZE;
    end;


end;

destructor TGSMRec.Destroy;
var
  I: Integer;
begin
  Close;
  for I := 0 to FBufferList.Count - 1 do
    begin
    FreeMem(PWaveHdr(FBufferList[i]).lpData,GSM_BLOCK_SIZE);
    dispose(FBufferList[i]);
    end;
  FBufferList.free;
  //inherited;
end;


function TGSMRec.IsFormatSupported(wfx: tWAVEFORMATEX): boolean;
begin
  try
    result :=  MMSYSERR_NOERROR =
              waveInOpen(0, WAVE_MAPPER, @FGsmWF.wf,
                         0, 0, WAVE_FORMAT_QUERY);
  except
    result := false;
  end;
end;

procedure TGSMRec.Open;
var ahandle:HWAVEIN;
    status:MMResult;
    statusStr: array [0..MAXERRORLENGTH-1] of char;
  I: Integer;
begin
  if not IsFormatSupported(FGsmWf.wf) then
    begin
    waveInGetErrorText(status,statusStr, MAXERRORLENGTH);
    raise ESndError.Create(statusStr);
    end;

  if Handle=0 then
  begin
    aHandle:=0;
    status:=waveInOpen(@aHandle,
                       WAVE_MAPPER,
                       @FGsmWf.wf,
                       cardinal(@_WaveInCallback),
                       cardinal(self),
                       CALLBACK_FUNCTION);

    FHandle:=aHandle;
    if Handle=0 then
      begin
      waveInGetErrorText(status,statusStr,MAXERRORLENGTH);
      raise ESndError.Create(statusStr);
      end;

    for I := 0 to FBufferList.Count - 1 do
      WaveInPrepareHeader(Handle,PWaveHdr(FBufferList[i]),sizeof(TWaveHdr));
  end;

end;


procedure TGSMRec.Start;
var i : integer;
begin
  inherited;

  if Handle<>0 then
  begin
    Stop;
    AddBuffers;
    waveInStart(Handle);
    FRecording:=true;
  end;

end;

procedure TGSMRec.WaveProc(const handle: THandle; const msg: UINT;
  const dwInstance, dwParam1, dwParam2: cardinal);
var wavehdr:PWaveHdr;
begin
  case msg of
    WIM_DATA:begin
               if FRecording then
               begin
                 waveHdr:=PWaveHdr(dwParam1);
                 DoDataAvail(waveHdr.lpData,
                             waveHdr.dwBufferLength,
                             waveHdr.dwBytesRecorded);
                 dec(FBufferIdx);
                 if FBufferIdx <= 0  then
                   begin
                   FBufferIdx := GSM_NUM_BLOCKS -1;
                   AddBuffers;
                   end;
               end;
             end;
  end;
end;


end.

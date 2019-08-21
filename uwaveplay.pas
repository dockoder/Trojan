unit uwaveplay;

interface

uses windows, classes, mmsystem, uwave;

type
  TDataRequiredEvent = procedure (const Buffer: pointer;
                                  const BufferSize: cardinal;
                                  var BytesInBuffer: cardinal) of object;
  TSoundPlayer=class(TWaveObject)
  private
    FBuffer1,FBuffer2,FCurrentBuffer:PWaveHdr;

    FPlaying: boolean;
    FOnDataRequired: TDataRequiredEvent;
    FLeftVolume,FRightVolume:word;

    procedure SetPlaying(const Value: boolean);
    procedure SwapBuffers;
    procedure SetOnDataRequired(const Value: TDataRequiredEvent);
    procedure WriteData;

    function  GetCurrentPosTime: cardinal;
    function  GetCurrentPosBytes: cardinal;
    procedure SetLeftVolume(const Value: word);
    function  GetLeftVolume: word;
    procedure SetRightVolume(const Value: word);
    function  GetRightVolume: word;
  protected
    procedure DoDataRequired(const Buffer:pointer;
                           const BufferSize:cardinal;
                           var BytesInBuffer:cardinal);virtual;
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
    procedure Stop;override;

    procedure Pause;
    procedure Resume;
  published
    property CurrentPosTime:cardinal read GetCurrentPosTime;
    property CurrentPosBytes:cardinal read GetCurrentPosBytes;

    property LeftVolume:word read GetLeftVolume write SetLeftVolume;
    property RightVolume:word read GetRightVolume write SetRightVolume;

    property Playing:boolean read FPlaying write SetPlaying;
    property OnDataRequired:TDataRequiredEvent read FOnDataRequired write SetOnDataRequired;
  end;


implementation

{ TSoundPlayer }
procedure TSoundPlayer.Close;
begin
  if FHandle<>0 then
  begin
    Stop;
    waveOutUnPrepareHeader(Handle,FBuffer1,Sizeof(TWaveHdr));
    waveOutUnPrepareHeader(Handle,FBuffer2,Sizeof(TWaveHdr));
    WaveOutClose(FHandle);
    FHandle:=0;
  end;
end;

procedure _WaveOutProc(Handle:HWAVEOUT;uMsg:UINT;
                      dwInstance:DWORD;
                      dwParam1,dwParam2:DWORD);stdcall;
begin
  TSoundPlayer(dwInstance).WaveProc(handle,
                 uMsg,
                 dwInstance,
                 dwParam1,
                 dwParam2);
end;

constructor TSoundPlayer.Create;
begin
  inherited;
  new(FBuffer1);
  ZeroMemory(FBuffer1,sizeOf(TWaveHdr));
  GetMem(FBuffer1.lpData,PLAYBACK_BUFFER_SIZE);
  FBuffer1.dwBufferLength:=PLAYBACK_BUFFER_SIZE;

  new(FBuffer2);
  ZeroMemory(FBuffer2,sizeOf(TWaveHdr));
  GetMem(FBuffer2.lpData,PLAYBACK_BUFFER_SIZE);
  FBuffer2.dwBufferLength:=PLAYBACK_BUFFER_SIZE;
end;

destructor TSoundPlayer.Destroy;
begin
  Close;
  FreeMem(FBuffer1.lpData,PLAYBACK_BUFFER_SIZE);
  FreeMem(FBuffer2.lpData,PLAYBACK_BUFFER_SIZE);
  dispose(FBuffer1);
  dispose(FBuffer2);
  inherited;
end;

procedure TSoundPlayer.DoDataRequired(const Buffer: pointer;
  const BufferSize: cardinal; var BytesInBuffer: cardinal);
begin
  if Assigned(FOnDataRequired) then
    FOnDataRequired(Buffer,BufferSize,BytesInBuffer);
end;

function TSoundPlayer.GetCurrentPosBytes: cardinal;
var posInfo:TMMTime;
begin
  if (Handle<>0) then
  begin
    ZeroMemory(@posInfo,sizeof(TMMTime));
    PosInfo.wType:=TIME_BYTES;
    waveOutGetPosition(Handle,@posInfo,sizeof(TMMTime));
    result:=posInfo.cb;
  end else
    result:=0;
end;

function TSoundPlayer.GetCurrentPosTime: cardinal;
var posInfo:TMMTime;
begin
  result:=0;
  if Handle<>0 then
  begin
    PosInfo.wType:=TIME_MS;
    waveOutGetPosition(Handle,@posInfo,sizeof(TMMTime));
    result:=posInfo.ms;
  end;
end;

function TSoundPlayer.GetLeftVolume: word;
var dwVolume:cardinal;
begin
  waveOutGetVolume(FHandle,@dwVolume);
  FLeftVolume:=LoWord(dwVolume);
  FRightVolume:=HiWord(dwVolume);
  result:=FLeftVolume;
end;

function TSoundPlayer.GetRightVolume: word;
var dwVolume:cardinal;
begin
  waveOutGetVolume(FHandle,@dwVolume);
  FLeftVolume:=LoWord(dwVolume);
  FRightVolume:=HiWord(dwVolume);
  result:=FRightVolume;
end;

procedure TSoundPlayer.Open;
var ahandle:HWAVEOUT;
    status:MMResult;
    statusStr:string;
begin
  if Handle=0 then
  begin
    status:=WaveOutOpen(@aHandle,
                        WAVE_MAPPER,
                        @FWaveFormat,
                        cardinal(@_WaveOutProc),
                        cardinal(Self),
                        CALLBACK_FUNCTION);

    FHandle:=aHandle;
    if status<>MMSYSERR_NOERROR then
    begin
      setlength(statusStr,MAXERRORLENGTH);
      waveOutGetErrorText(status,pChar(statusStr),
                       MAXERRORLENGTH);
      raise ESndError.Create(statusStr);
    end;

    WaveOutPrepareHeader(Handle,FBuffer1,sizeof(TWaveHdr));
    WaveOutPrepareHeader(Handle,FBuffer2,sizeof(TWaveHdr));
  end;
end;

procedure TSoundPlayer.Pause;
begin
  if FHandle<>0 then
    WaveOutPause(FHandle);
end;

procedure TSoundPlayer.Resume;
begin
  if FHandle<>0 then
    WaveOutRestart(FHandle);
end;

procedure TSoundPlayer.SetLeftVolume(const Value: word);
var dwVolume:cardinal;
begin
  FLeftVolume:=value;
  dwVolume:=(FRightVolume shl 16) or FLeftVolume;
  waveOutSetVolume(FHandle,dwVolume);
end;

procedure TSoundPlayer.SetOnDataRequired(const Value: TDataRequiredEvent);
begin
  FOnDataRequired := Value;
end;

procedure TSoundPlayer.SetPlaying(const Value: boolean);
begin
  Stop;
end;

procedure TSoundPlayer.SetRightVolume(const Value: word);
var dwVolume:cardinal;
begin
  FRightVolume:=value;
  dwVolume:=(FRightVolume shl 16) or FLeftVolume;
  waveOutSetVolume(FHandle,dwVolume);
end;

procedure TSoundPlayer.Start;
begin
  if Handle<>0 then
  begin
    Stop;
    FCurrentBuffer:=FBuffer1;
 //pake buffer 64KB, kalo buffer kecil misal 4KB
 //suara terdengar putus-putus
    FBuffer1.dwBufferLength:=PLAYBACK_BUFFER_SIZE;
    FBuffer2.dwBufferLength:=PLAYBACK_BUFFER_SIZE;
    WriteData;
    FPlaying:=true;
  end;
end;

procedure TSoundPlayer.Stop;
begin
  FPlaying:=false;
  if FHandle<>0 then
     WaveOutReset(FHandle);
end;

procedure TSoundPlayer.SwapBuffers;
begin
  if FCurrentBuffer=FBuffer1 then
    FCurrentBuffer:=FBuffer2
  else
    FCurrentBuffer:=FBuffer1;
end;

procedure TSoundPlayer.WaveProc(const handle:THandle;
                      const msg:UINT;
                      const dwInstance:cardinal;
                      const dwParam1,dwParam2:cardinal);
begin
  case msg of
    WOM_DONE:begin
               if FPlaying then
               begin
                 //tukar buffer
                 SwapBuffers;
                 WriteData;
               end;
             end;
  end;
end;

procedure TSoundPlayer.WriteData;
var ActBytesInBuffer:cardinal;
begin
  ActBytesInBuffer:=0;
  DoDataRequired(FCurrentBuffer.lpData,
                 FCurrentBuffer.dwBufferLength,
                 ActBytesInBuffer);

  if ActBytesInBuffer=0 then
  begin
    FPlaying:=false;
    exit;
  end;

  if ActBytesInBuffer<FCurrentBuffer.dwBufferLength then
  begin
    //data yang harus dimainkan sudah
    //habis, isi panjang buffer dengan sisa data yang ada
    FCurrentBuffer.dwBufferLength:=ActBytesInBuffer;
    WaveOutWrite(Handle,FCurrentBuffer,sizeof(TWaveHdr));
    FPlaying:=false;
  end else
    WaveOutWrite(Handle,FCurrentBuffer,sizeof(TWaveHdr));
end;

end.

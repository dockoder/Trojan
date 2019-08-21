unit uwaverec;


interface

uses windows, classes, mmsystem, uwave;

type
  TDataAvailEvent=procedure(sender:TObject;
                            const Buffer:pointer;
                            const BufferSize:cardinal;
                            const BytesRecorded:cardinal) of object;

  TSoundRecorder=class(TWaveObject)
  private
    FBuffer1,FBuffer2,FCurrentBuffer:PWaveHdr;
    FRecording,
    FKeep: boolean;

    FMemBuffer : TMemoryStream;
    FInternalBuf : pchar;


    FFilePath : string;

    FOnDataAvail: TDataAvailEvent;
    procedure SetOnDataAvail(const Value: TDataAvailEvent);
    procedure SwapBuffers;
    procedure Setkeep(value : boolean);
  protected
    procedure DoDataAvail(const Buffer:pointer;
                           const BufferSize:cardinal;
                           const BytesRecorded:cardinal);virtual;
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
    procedure Flush;
  published
    property Recording:boolean
      read FRecording;
    property OnDataAvail:TDataAvailEvent
      read FOnDataAvail
      write SetOnDataAvail;
    property Keep : boolean
      read FKeep
      write SetKeep;
    property FilePath : string
      read  FFilePath
      write FFilePath;
  end;

procedure _WaveInCallback(const handle:HWAVEIN;
                         const msg:UINT;
                         const dwInstance:cardinal;
                         const dwParam1,dwParam2:cardinal);stdcall;

implementation
uses sysutils, dialogs;

{Helper Function -  Callback}
procedure _WaveInCallback(const handle:HWAVEIN;
                         const msg:UINT;
                         const dwInstance:cardinal;
                         const dwParam1,dwParam2:cardinal);
var waveHdr:PWaveHdr;
     sr : TSoundRecorder;
     pos, i : integer;
begin
  waveHdr:=PWaveHdr(dwParam1);
  if (waveHdr = nil) and
     (msg <> MM_WIM_DATA) then exit;

  sr:=TSoundRecorder(dwInstance);

  if sr.keep then
    begin
    pos :=sr.FMemBuffer.Position;
    i := sr.FMemBuffer.Write(waveHdr.lpData,waveHdr.dwBytesRecorded);
    sr.FMemBuffer.Position := pos+i;
    end ;
 // else
    sr.WaveProc(handle,msg,dwInstance,dwParam1,dwParam2);

end;

{ TSoundRecorder }

procedure TSoundRecorder.Close;
begin
  if Handle<>0 then
  begin
    Stop;
    waveInUnPrepareHeader(Handle,FBuffer1,Sizeof(TWaveHdr));
    waveInUnPrepareHeader(Handle,FBuffer2,Sizeof(TWaveHdr));
    waveInClose(Handle);
    FHandle:=0;
  end;

  Setkeep(false);
end;

constructor TSoundRecorder.Create;
begin
  inherited;
  FFilePath := '';
  FKeep := false;
  FRecording := false;

  
  new(FBuffer1);
  ZeroMemory(FBuffer1,sizeOf(TWaveHdr));
  GetMem(FBuffer1.lpData,MAX_BUFFER_SIZE);
  FBuffer1.dwBufferLength:=MAX_BUFFER_SIZE;

  new(FBuffer2);
  ZeroMemory(FBuffer2,sizeOf(TWaveHdr));
  GetMem(FBuffer2.lpData,MAX_BUFFER_SIZE);
  FBuffer2.dwBufferLength:=MAX_BUFFER_SIZE;
end;

destructor TSoundRecorder.Destroy;
begin
  Close;
  Setkeep(false);
  FreeMem(FBuffer1.lpData,MAX_BUFFER_SIZE);
  FreeMem(FBuffer2.lpData,MAX_BUFFER_SIZE);
  dispose(FBuffer1);
  dispose(FBuffer2);
  inherited;
end;

procedure TSoundRecorder.DoDataAvail(const Buffer: pointer; const BufferSize,
  BytesRecorded: cardinal);
begin
  if Assigned(FOnDataAvail) then
    FOnDataAvail(self,Buffer,BufferSize,BytesRecorded);
end;

procedure TSoundRecorder.Flush;
begin
  Setkeep(false);
end;

procedure TSoundRecorder.Open;
var ahandle:HWAVEIN;
    status:MMResult;
    statusStr:string;
begin
  if Handle=0 then
  begin
    aHandle:=0;
    status:=waveInOpen(@aHandle,
               WAVE_MAPPER,
               @FWaveFormat,
               cardinal(@_WaveInCallback),
               cardinal(self),
               CALLBACK_FUNCTION);
    FHandle:=aHandle;
    if Handle=0 then
    begin
      setlength(statusStr,MAXERRORLENGTH);
      waveInGetErrorText(status,pChar(statusStr),
                       MAXERRORLENGTH);
//      raise ESndError.Create(statusStr);
    end;

    WaveInPrepareHeader(Handle,FBuffer1,sizeof(TWaveHdr));
    WaveInPrepareHeader(Handle,FBuffer2,sizeof(TWaveHdr));
  end;

end;

procedure TSoundRecorder.Setkeep(value: boolean);
var
  HeapObj: THandle;
begin
  FKeep := value;
  if value then
    begin
    if not assigned(FMemBuffer) then
      begin
      FMemBuffer:=TMemoryStream.Create;
      FMemBuffer.Position:=0;
//      if assigned(FInternalBuf) then
//        begin
//        FreeMem(FInternalBuf);
//        HeapObj := HeapCreate(HEAP_GENERATE_EXCEPTIONS,1,0 );
//        end;

      end;
    end
  else
    begin
    if assigned(FMemBuffer) then
      begin
      if (FMemBuffer.Size > 0) and
         (FFilePath<>'') then
          FMemBuffer.SaveToFile(FilePath);
      FMemBuffer.Free;
      end;
    end;
end;

procedure TSoundRecorder.SetOnDataAvail(const Value: TDataAvailEvent);
begin
    FOnDataAvail := Value;
end;

procedure TSoundRecorder.Start;
begin
  if Handle<>0 then
  begin
    Stop;

    FCurrentBuffer:=FBuffer1;
    WaveInAddBuffer(Handle,FBuffer1,sizeof(TWaveHdr));
    waveInStart(Handle);
    FRecording:=true;
  end;
end;

procedure TSoundRecorder.Stop;
begin
  if Handle<>0 then
  begin
    //waveInReset(Handle) ;
    waveInStop(Handle);
    FRecording:=false;
  end;
end;

procedure TSoundRecorder.SwapBuffers;
begin
  if FCurrentBuffer=FBuffer1 then
    FCurrentBuffer:=FBuffer2
  else
    FCurrentBuffer:=FBuffer1;

  WaveInAddBuffer(Handle,FCurrentBuffer,sizeof(TWaveHdr));
end;

procedure TSoundRecorder.WaveProc(const handle:THandle;
                      const msg:UINT;
                      const dwInstance:cardinal;
                      const dwParam1,dwParam2:cardinal);
var wavehdr:PWaveHdr;
begin
  case msg of
    WIM_DATA:begin
               if FRecording then
               begin
                 waveHdr:=PWaveHdr(dwParam1);
                 SwapBuffers;
                 DoDataAvail(waveHdr.lpData,
                             waveHdr.dwBufferLength,
                             waveHdr.dwBytesRecorded);
               end;
             end;
  end;

end;


end.

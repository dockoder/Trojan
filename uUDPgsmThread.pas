unit uUDPgsmThread;

interface

uses windows, classes, SysUtils, Contnrs  ,mmsystem,
     uwavegsm,
     IdUDPServer, IdUDPClient, idSocketHandle, idglobal;

type
  TarrWaveInCaps = array of TWaveInCaps;

  TSenderType = (stNone, stServer, stClient);

  TarrPointer = array of pointer;

  TUDPGsmThread = class(TThread)
  private
    FServidor :TIdUDPServer;
    FCliente: TIdUDPClient;
    FGSMRec : TGSMRec;

    FBufferList : TarrPointer;

    FSenderType : TSenderType;
    FCapture: boolean;
    CS : TCriticalSection;

    FMutex : THandle;

    procedure SetCapture(const Value: boolean);

    procedure SetCliente(const Value: TIdUDPClient);
    procedure SetServidor(value : TIdUDPServer);
  protected
    procedure DoDataAvail(sender:TObject;
                            const Buffer:pointer;
                            const BufferSize:cardinal;
                            const BytesRecorded:cardinal) ;
    procedure execute; override;
  public
    constructor Create(ASendertype : TSenderType;
                       host : string;
                       port : integer); overload;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;

    property Servidor : TIdUDPServer
                           read FServidor;


    property Cliente : TIdUDPClient
                           read FCliente;


    property SenderType : TSenderType
                           read FSenderType;

    property Capture : boolean
                           read FCapture
                          write SetCapture;

  end;

function GetSoundDevicesIn : TarrWaveInCaps;


implementation

procedure ReallocList(list : TarrPointer);
var
  I: Integer;
begin
  Freemem(List[0]);
  for I := 0 to high(List)-1 do
    List[i] := List[i+1];

  setlength(list, length(list)-1);
end;



function GetSoundDevicesIn : TarrWaveInCaps;
var i, j : integer;
    pwic : PWaveInCaps;
begin
  j := waveInGetNumDevs;
  for I := 0 to j - 1 do
    begin
    setlength(result, length(result)+1);
    pwic := @result[high(result)];
    waveInGetDevCaps(i, pwic, sizeof(TWaveInCaps));
    end;
end;

{ TUDPGsmThread }

constructor TUDPGsmThread.Create(ASendertype : TSenderType;
                       host : string;
                       port : integer);
begin
  case ASendertype of
    stNone: Raise Exception.Create('type missing');
    stServer :
      begin
      FServidor := TIdUDPServer.Create(nil);
      Fservidor.DefaultPort := port;
      end;
    stClient :
      begin
      FCliente := TIdUDPClient.Create(nil);
      FCliente.Host := host;
      FCliente.Port := port;
      FCliente.Connect;
      FGSMRec := TGSMRec.Create;
      FGSMRec.OnDataAvail := DoDataAvail;
      FGSMRec.Open;
      end;
  end;

  FSenderType := ASendertype;
  FCapture := false;
  FMutex := CreateMutex(nil, false, 'MutexGetData');
  inherited Create(false);

  CS := TCriticalSection.Create;
end;

destructor TUDPGsmThread.Destroy;
var p : pointer;
  I: Integer;
begin
  if FServidor<>nil then FServidor.Free;
  if FCliente<>nil then FCliente.Free;
  if FGSMRec<>nil then
    begin
    if FCapture then Stop;
    FGSMRec.Close;
    FGSMRec.Free;
    end;

  if length(FBufferList) > 0 then
     for I := 0 to high(FBufferList) do
       try
         if FBufferList[i]<>nil then
            FreeMem(FBufferList[i]);
       except end;

  FreeAndNil(cs);
  inherited;
end;

procedure TUDPGsmThread.DoDataAvail(sender:TObject;
                            const Buffer:pointer;
                            const BufferSize:cardinal;
                            const BytesRecorded:cardinal) ;
var
  I: Integer;
  p : pointer;
begin
  if (not FCapture) or (FSenderType = stNone)  then exit;
  //cs.Acquire;
  i := WaitForSingleObject(FMutex, 5000);

  if i = WAIT_OBJECT_0 then
    try
      GetMem(p, BytesRecorded);
      if p=nil then exit;
      move(buffer, p, BytesRecorded);
      setlength(FBufferList, length(FBufferList) +1);
      FBufferList[high(FBufferList)] := p;
    finally
      ReleaseMutex(FMutex);
      //cs.Release;
    end;
end;

procedure TUDPGsmThread.execute;
var buffer : pointer;
begin
  inherited;

  while not terminated do
    if FSenderType = stClient then
      begin
      if (FCliente.Connected) and FCapture  then
        try
          //cs.Acquire;
          FMutex := CreateMutex(nil, false, 'MutexGetData');
          if WaitForSingleObject(FMutex,5000) =  WAIT_OBJECT_0 then
          
          if FBufferList[0]<>nil then
            begin
            buffer := FBufferList[0];
            if buffer<>nil then
              FCliente.SendBuffer(TidBytes(buffer));
            ReallocList(FBufferList);
            end;
        finally
          ReleaseMutex(FMutex);
          //cs.Release;
        end;
      end
    else //tipo  stServer
end;

procedure TUDPGsmThread.SetCapture(const Value: boolean);
begin
  if value then
    Start
  else
    Stop;
end;

procedure TUDPGsmThread.SetCliente(const Value: TIdUDPClient);
begin
   if assigned(value) then
     begin
     FCliente := Value;
     FSenderType := stClient;
     end;

end;

procedure TUDPGsmThread.SetServidor(value: TIdUDPServer);
begin
   if assigned(value) then
     begin
     FServidor := value;
     FSenderType := stServer;
     end;
end;

procedure TUDPGsmThread.Start;
begin
  FCapture := true;
  FGSMRec.Start;

end;

procedure TUDPGsmThread.Stop;
begin
  FCapture := false;
  FGSMRec.Stop;
end;

end.

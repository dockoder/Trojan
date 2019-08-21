unit uGsmNet;

interface

uses SysUtils ,classes, mmsystem, uwavegsm,
     IdUDPServer, IdUDPClient, idSocketHandle, idglobal;

type
  TarrWaveInCaps = array of TWaveInCaps;

  TSenderType = (stNone, stServer, stClient);

  TGsmNet = class(TGSMRec)
  private
    FHost : string;
    FPort : integer;
    FServidor :TIdUDPServer;
    FClientes: TList;
    FSenderType : TSenderType;
    procedure SetSenderType(const Value: TSenderType);

    function CreateCliente(_Host : string; _Port:integer) : TIdUDPClient;
    function CreateServidor: boolean;
  protected
    procedure DoDataAvail(const Buffer:pointer;
                           const BufferSize:cardinal;
                           const BytesRecorded:cardinal);override;
  public
        constructor Create(ASendertype : TSenderType;
                       host : string;
                       port : integer); overload;
        destructor Destroy; override;
        
    property Servidor : TIdUDPServer
                           read FServidor;

    property Clientes : TList
                         read FClientes;

    property Port : integer
                        read FPort
                        write FPort;
    property Host : string
                        read FHost
                        write FHost;

    property SenderType : TSenderType
                           read FSenderType
                           write SetSenderType;

  end;

function GetSoundDevicesIn : TarrWaveInCaps;

implementation

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


{ TGsmNet }
constructor TGsmNet.Create(ASendertype : TSenderType;
                       host : string;
                       port : integer);
begin
  inherited Create;
  SenderType := stClient;
  FPort := port;
  FHost := trim(FHost);
end;

function TGsmNet.CreateCliente(_Host : string; _Port:integer) : TIdUDPClient;
var
  p: TIdUDPClient;
begin
  p := TIdUDPClient.Create(nil);
  try
    p.Host := _Host;
    p.Port := _Port;
    p.Connect;
    FClientes.Add(p);
    result := p;
  except
    p.free;
    result := nil;
  end;
end;

function TGsmNet.CreateServidor: boolean;
begin
  result := false;
  if FServidor=nil then
    begin
    FServidor := TIdUDPServer.Create(nil);
    FServidor.DefaultPort := FPort;
    result := true;
    end;
end;

destructor TGsmNet.Destroy;
var
  I: Integer;
begin
  try
    for I := 0 to FClientes.Count - 1 do
      if FClientes[i]<>nil then
        TIdUDPClient( FClientes[i]).Free;
  finally
    FClientes.Clear;
    FreeAndNil(FClientes);
  end;    
  inherited;
end;

procedure TGsmNet.DoDataAvail(const Buffer: pointer; const BufferSize,
  BytesRecorded: cardinal);
var
  I: Integer;
  p : array of byte;
begin
  if FSenderType = stNone then exit;

  try
    try
      Setlength(p, BytesRecorded);
      Move(buffer, p[0], BytesRecorded);
      //CopyTIdByteArray(TidBytes(buffer), 0, p, 0, BytesRecorded);
    except
      exit;
    end;

     case FSenderType of
        stClient: for I := 0 to FClientes.Count - 1 do
                   if (FClientes[i]<>nil) and
                      (TIdUDPClient(FClientes[i]).Connected) then
                      TIdUDPClient(FClientes[i]).SendBuffer(TBytes(p));

        stServer: for I := 0 to FServidor.Bindings.Count - 1 do
                         FServidor.Bindings[i].Send( TBytes(buffer), 0,
                                                     BytesRecorded);
     end;
  finally
    Setlength(p, 0);
    p:=nil;
  end;
end;

procedure TGsmNet.SetSenderType(const Value: TSenderType);
begin
  case value of
    stServer: CreateServidor;
    stClient: CreateCliente(FHost, FPort);
  end;
  FSenderType := Value;
end;


end.

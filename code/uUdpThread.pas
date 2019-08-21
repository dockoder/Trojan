unit uUdpThread;

interface

uses classes, idUDPClient, idglobal;

type
  TOnReceive = procedure (Sender: TObject; AData: TIdBytes; size : Cardinal) of object;

  TUDPClientThread = class(TThread)
  private
    FUDPClient  : TIdUDPClient;
    FBuffer : TidBytes;
    FSizeRead : cardinal;
    FTimeout : integer;

    FOnReceive : TOnReceive;
    function GetConnected: boolean;
    function GetHost: string;
    function GetPort: integer;
    procedure SetHost(const Value: string);
    procedure SetPort(const Value: integer);
    function GetTimeout: integer;
    procedure SetTimeout(Value: integer);

    procedure Receive;
  protected
    procedure Execute; override;
  public
    constructor Create(host:string; port:integer); overload;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;

    property Host : string
                           read GetHost
                          write SetHost;
    property Port : integer
                           read GetPort
                          write SetPort;
    property Timeout : integer
                           read GetTimeout
                          write SetTimeout;
    property Connected : boolean
                           read GetConnected;

    property OnReceive : TOnReceive
                           read FOnReceive
                          write FOnReceive;


  end;

implementation

{ TUDPClientThread }

procedure TUDPClientThread.Connect;
begin
  FUDPClient.Connect;
end;

constructor TUDPClientThread.Create(host:string; port:integer);
begin
  FUDPClient := TIdUDPClient.Create(nil);
  FUDPClient.Host := host;
  FUDPClient.Port := port;
  FTimeout := 40;
  inherited Create(false);
end;

destructor TUDPClientThread.Destroy;
begin
  FUDPClient.Free;
  inherited;
end;

procedure TUDPClientThread.Disconnect;
begin
  FUDPClient.Disconnect;
end;

procedure TUDPClientThread.Execute;
begin
  inherited;
  while not terminated do
    begin
    if FUDPClient.Connected then
      begin
      FSizeRead := FUDPClient.ReceiveBuffer(FBuffer, FTimeout);
      if FSizeRead > 0 then Synchronize(Receive);
      end;
      sleep(1);
    end;
end;

function TUDPClientThread.GetConnected: boolean;
begin
  result := FUDPClient.Connected;
end;

function TUDPClientThread.GetHost: string;
begin
  result := FUDPClient.Host;
end;

function TUDPClientThread.GetPort: integer;
begin
  result := FUDPClient.Port;
end;

function TUDPClientThread.GetTimeout: integer;
begin
  result := FTimeout;
end;

procedure TUDPClientThread.Receive;
begin
  if assigned(FOnReceive) then
     FOnReceive(self, FBuffer, FSizeRead);
end;

procedure TUDPClientThread.SetHost(const Value: string);
begin
  if not FUDPClient.Connected then
    FUDPClient.Host := value;
end;

procedure TUDPClientThread.SetPort(const Value: integer);
begin
  if not FUDPClient.Connected then
    FUDPClient.Port := value;
end;

procedure TUDPClientThread.SetTimeout(Value: integer);
begin
  if value < IdTimeoutInfinite then
    value := IdTimeoutInfinite;

  FTimeout := value;
end;

end.

unit commsound;

interface

uses SysUtils ,mmsystem, uwavegsm,
     IdUDPServer, IdUDPClient, idSocketHandle, idglobal;

type
  TarrWaveInCaps = array of TWaveInCaps;

  TSenderType = (stNone, stServer, stClient);

  TGsmNet = class(TGSMRec)
  private
    FHost : string;
    FPort : integer;
    FServidor :TIdUDPServer;
    FCliente: TIdUDPClient;
    FSenderType : TSenderType;
    procedure SetSenderType(const Value: TSenderType);

    function CreateCliente : boolean;
    function CreateServidor: boolean;
  protected
    procedure DoDataAvail(const Buffer:pointer;
                           const BufferSize:cardinal;
                           const BytesRecorded:cardinal);override;
  public
        constructor Create(ASendertype : TSenderType;
                       host : string;
                       port : integer); overload;
    property Servidor : TIdUDPServer
                           read FServidor;

    property Cliente : TIdUDPClient
                           read FCliente;

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
end;

function TGsmNet.CreateCliente: boolean;
begin
  result := false;
  if FCliente=nil then
    begin
    FCliente := TIdUDPClient.Create(nil);
    FCliente.Host := FHost;
    FCliente.Port := FPort;
    Fcliente.Connect;
    result := true;
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
        stClient: if FCliente.Connected then
                      FCliente.SendBuffer(TBytes(p));

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
    stClient: CreateCliente;
  end;
  FSenderType := Value;
end;


end.

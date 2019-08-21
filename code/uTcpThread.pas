unit uTcpThread;

interface

uses
  Classes, SysUtils , windows, dialogs,
  IdGlobal, IdComponent, IdCmdTCPClient, IdUDPClient, comando;

const CHUNKSIZE = 8192;

type
  TOnResposta = procedure (const resp : TResposta) of object;

  TTCPThread = class(TThread)
  private
    FForm : pointer;
    FTcp : TIdCmdTCPClient;
    FUdp : TIdUDPClient;
    Fcomando : string;
    FParametros: string;

    FStream: TMemoryStream;
    FDeskImagePath : string; //caminho para imagem do
    FFileSize : cardinal;
    FFilePos : cardinal;

    FOnResposta : TOnResposta;

    procedure SetComando(value:string);

    procedure SetResposta;
    procedure WorkEventDownload (ASender: TObject; AWorkMode: TWorkMode;
                                 AWorkCount: Integer);
    procedure WorkEventVideo(ASender: TObject; AWorkMode: TWorkMode;
                     const ACount: Int64);


    procedure SendComando;
    function GetRespostaFromPeer: TResposta;
    procedure DespachaComando;

    procedure UpdateDirListView;
    procedure UpdateDeskPicture;
    procedure UpdateBarDownload;


    procedure  PING ;
    procedure  MSG ;
    procedure  CHAT ;
    procedure  GETFILE ;
    procedure  GETLISTDIR;
    procedure  GETSCRIPT;
    procedure  RUN;
    procedure  REBOOT;
    procedure  SHOOTDONW;
    procedure  GETSCREEN;
    procedure  GETMOUSE;
    procedure  RELEASEMOUSE;
    procedure  WWW;
    procedure  SENDMAIL;
    procedure  VIDEO;

  protected
    procedure Execute; override;
  public
    constructor Create(container : pointer;
                       host : string;
                       port : integer); overload;
    destructor Destroy; override;

    property Comando : string
      read FComando
      write SetComando;

    property OnResposta : TOnResposta
      read FOnResposta
      write FOnResposta;

  end;

implementation

uses ufrmUser, ufrmMensagens, IdBaseComponent;


{ TTCPThread }

procedure TTCPThread.CHAT;
var r : TResposta;
begin
  if not Assigned(FForm) then exit;

  SendComando;
  SetResposta;
end;

constructor TTCPThread.Create(container : pointer; host: string; port: integer);
begin
  FreeOnTerminate := true;

  Fcomando := '';
  FParametros := '';

  FForm := container;

  FTcp := TIdCmdTCPClient.Create(nil);
  FTcp.Host := host;
  FTcp.Port := port;

  inherited Create(true);
end;

procedure TTCPThread.DespachaComando;
begin
  if Fcomando = COMM_STR_PING then PING;
  if Fcomando = COMM_STR_MSG then MSG;
  if Fcomando = COMM_STR_CHAT then CHAT;
  if Fcomando = COMM_STR_GETFILE then GETFILE;
  if Fcomando = COMM_STR_GETLISTDIR then GETLISTDIR;
  if Fcomando = COMM_STR_GETSCRIPT then  GETSCRIPT;
  if Fcomando = COMM_STR_RUN then RUN;
  if Fcomando = COMM_STR_REBOOT then REBOOT;
  if Fcomando = COMM_STR_SHOOTDONW then SHOOTDONW;
  if Fcomando = COMM_STR_GETSCREEN then GETSCREEN;
  if Fcomando = COMM_STR_GETMOUSE then GETMOUSE;
  if Fcomando = COMM_STR_RELEASEMOUSE then RELEASEMOUSE;
  if Fcomando = COMM_STR_WWW then WWW;
  if Fcomando = COMM_STR_SENDMAIL then SENDMAIL;
  if Fcomando = COMM_STR_VIDEO  then VIDEO;
end;

destructor TTCPThread.Destroy;
begin
  FTcp.Free;
  inherited;
end;

procedure TTCPThread.Execute;
begin
  FTcp.Connect;
  while not terminated do
    begin
    if Length(Fcomando) > 0 then DespachaComando;
    sleep(1);
    end;
  FTcp.Disconnect;
end;

procedure TTCPThread.GETFILE;
var fs : TFileStream;
    i, _pos : integer;
  strfile: string;
begin
  if not Assigned(FForm) then exit;

  for i := 1 to length(FParametros) do
    if FParametros[i] = '\'  then
      _pos := i;

  strfile := Copy(FParametros, _pos+1, length(FParametros));

  if not DirectoryExists('.\download') then
    CreateDir('.\download');

  strFile := '.\Download\' + strFile;

  SendComando;

  FFileSize := strtoint(FTcp.IOHandler.ReadLn);

  fs := TFileStream.Create(strFile, fmCreate);
  try
    FTcp.OnWork := WorkEventDownload;
    FTcp.IOHandler.ReadStream(fs, FFileSize);
  finally
    FreeAndNil(fs);
    FTcp.OnWork := nil;
  end;

  SetResposta;

end;

procedure TTCPThread.GETLISTDIR;
var
  I, q: Integer;
  strSize : string;
  iSize: integer;

begin
  if not assigned(FForm)  then exit;

  FParametros := trim( inputbox('Diretório a pesquisar', 'Diretorio:', 'c:'));

  SendComando;

  strSize := FTcp.IOHandler.ReadLn;
  iSize := strtoint(trim(strSize));

  FStream := TMemoryStream.Create ;
  try
    FTcp.IOHandler.ReadStream(FStream, iSize);
    Synchronize(UpdateDirListView);
  finally
    FreeAndNil(FStream);
  end;

  SetResposta;

end;


procedure TTCPThread.GETMOUSE;
begin

end;

function TTCPThread.GetRespostaFromPeer: TResposta;
begin
  Result.texto := FTcp.LastCmdResult.Text.Text;
  Result.valor := FTcp.LastCmdResult.NumericCode;
end;

procedure TTCPThread.GETSCREEN;
var fs : TFileStream;
    sTemp : array[0..255] of char;
    iTamanhoArquivo: Integer;
begin
  if (GetTempFileName('.', pchar('img'), 0, sTemp) = 0 ) or
     (not assigned(FForm) ) then exit;

  FDeskImagePath := sTemp;

  FDeskImagePath := ChangeFileExt(FDeskImagePath, '.jpg');

  SendComando;

  //pega o tamnho do arquivo
  try
    iTamanhoArquivo := strtoint(trim(FTcp.IOHandler.ReadLn));

    fs := TFileStream.Create( FDeskImagePath, fmCreate) ;
    try
      FTcp.IOHandler.ReadStream(fs, iTamanhoArquivo);
    finally
      FreeAndNil(fs);
      Synchronize(UpdateDeskPicture);
    end;
  finally
    SetResposta;
  end;



end;


procedure TTCPThread.GETSCRIPT;
begin

end;

procedure TTCPThread.MSG;
begin
  if not Assigned(FForm) then exit;

  with TfrmMensagens.Create(nil) do
  try
    if ShowModal = 1 {mrOk} then
      begin
        FParametros := memMensagem.Text + ' ';

        case rbBotoes.ItemIndex of
          0: FParametros := FParametros  + COMM_STR_PARAMS_MSG_OKCANCEL+ ' ';
          1: FParametros := FParametros + COMM_STR_PARAMS_MSG_YESNO + ' ';
        end;

        FParametros := FParametros + inttostr(rbIcones.ItemIndex);

        SendComando;
        SetResposta;
      end;
  finally
    Free;
  end;  
end;

procedure TTCPThread.PING;
begin

end;

procedure TTCPThread.REBOOT;
begin
  if not Assigned(FForm) then exit;
  SendComando;
  SetResposta;
end;

procedure TTCPThread.RELEASEMOUSE;
begin

end;

procedure TTCPThread.SetResposta;
begin
  if Assigned(FOnResposta) then
    FOnResposta(GetRespostaFromPeer);
end;

procedure TTCPThread.RUN;
var com : TComando;
    frm : TfrmUser;
begin
  FParametros := InputBox('Programa a correr remotamente', '', '');

  if not Assigned(FForm) or
     (trim(com.params) = '')  then exit;

  SendComando;
  SetResposta;
end;

procedure TTCPThread.SendComando;
begin
  try
    FTcp.SendCmd(Fcomando + ' ' + FParametros);
  finally
    Fcomando := '';
    FParametros := '';
  end;
end;

procedure TTCPThread.SENDMAIL;
begin
  if not Assigned(FForm) then exit;

  //implementar parametros

  SendComando;
  SetResposta;
end;

procedure TTCPThread.SetComando;
begin
 if Length(value) > 0 then
  begin
   Fcomando := Copy(value, 1, Pos(' ', value)-1) ;
   FParametros := Copy(value, Pos(' ', value)+1, length(value) ) ;
  end;

end;

procedure TTCPThread.SHOOTDONW;begin
  if not Assigned(FForm) then exit;
  SendComando;
  SetResposta;
end;


procedure TTCPThread.UpdateBarDownload;
begin
  TfrmUser(FForm).pbarDownload.Max := FFileSize div CHUNKSIZE;
  TfrmUser(FForm).pbarDownload.Position := FFilePos div CHUNKSIZE;
end;

procedure TTCPThread.UpdateDeskPicture;
begin
  if FileExists(FDeskImagePath) then
    begin
    TfrmUser(FForm).imgDesk.Picture.LoadFromFile (FDeskImagePath);
    SysUtils.DeleteFile(FDeskImagePath);
    end;
end;

procedure TTCPThread.UpdateDirListView;
var pai : array of TArquivoInfo;
    i, q, isize : integer;
    f : TfrmUser;
    dat : TDateTime;
begin
  FStream.Position := 0;
  isize := FStream.Size;
  try
    SetLength(pai, iSize div sizeof(TArquivoInfo));
    FStream.Read(pai[0], isize) ;

    f := TfrmUser(FForm);
    f.lvDirs.Clear;

    q := high(pai);
    for I := 0 to q do
      with f.lvDirs.Items.Add do
        begin
        Caption := pai[i].Name;
        if pai[i].Attr and faDirectory = faDirectory then
          ImageIndex := 1
        else
          ImageIndex := 0;
        SubItems.Add( Format('%d', [pai[i].Size]) );

        Dat := FileDateToDateTime(pai[i].Time);
        SubItems.Add(DateTimeToStr(dat));
        end;    
  finally
    Setlength(pai,0);
  end;

end;

procedure TTCPThread.VIDEO;
var
  buf: TBytes;
begin
  SendComando;
  SetResposta;

  if GetRespostaFromPeer.valor = RESP_OK then
    begin
    FUdp := TIdUDPClient.Create(nil);
    try
      FUdp.Host := FTcp.Host;
      FUdp.Port := FTcp.Port+1;
      while FUdp.ReceiveBuffer(buf) > 0 do
        begin
        end;
    finally
      FreeAndNil(FUdp);
    end;
    end;
end;

procedure TTCPThread.WorkEventDownload(ASender: TObject;AWorkMode: TWorkMode;
  AWorkCount: Integer);
begin
  if AWorkMode = wmRead then
    begin
    FFilePos := AWorkCount;
    Synchronize(UpdateBarDownload);
    end;                           
end;

procedure TTCPThread.WorkEventVideo(ASender: TObject; AWorkMode: TWorkMode;
  const ACount: Int64);
begin

end;

procedure TTCPThread.WWW;
var sSite : string;
begin

  sSite :=  InputBox('WWW','','');

  if( trim(sSite) = '' ) or
    (not Assigned(FForm) )  then exit;

  FParametros := trim(sSite);

  SendComando;
  SetResposta;
end;


end.

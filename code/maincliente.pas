unit maincliente;

{$define debug}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Menus, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient,
  IdSMTPBase, IdSMTP, IdPOP3, comando, uUdpThread, idGlobal;

type
  TfrmMainCliente = class(TForm)
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    mnuConectar: TMenuItem;
    Desconectar1: TMenuItem;
    N1: TMenuItem;
    Sair1: TMenuItem;
    Desconectartodos1: TMenuItem;
    Panel1: TPanel;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    lvServidores: TListView;
    Conectartodos1: TMenuItem;
    N2: TMenuItem;
    Splitter1: TSplitter;
    mnuLigar: TMenuItem;
    N3: TMenuItem;
    Ver1: TMenuItem;
    Ajuda1: TMenuItem;
    Comandos1: TMenuItem;
    mnuChat: TMenuItem;
    mnuMensagem: TMenuItem;
    N4: TMenuItem;
    Arquivo2: TMenuItem;
    mnuDir: TMenuItem;
    Script1: TMenuItem;
    mnuPrograma: TMenuItem;
    N5: TMenuItem;
    mnuReboot: TMenuItem;
    mnuShootdown: TMenuItem;
    N6: TMenuItem;
    mnuDesk: TMenuItem;
    CapturarRato1: TMenuItem;
    LiberarRato1: TMenuItem;
    N7: TMenuItem;
    mnuWWW: TMenuItem;
    mnuMail: TMenuItem;
    N8: TMenuItem;
    Preferencias1: TMenuItem;
    SMTP: TIdSMTP;
    POP3: TIdPOP3;
    TCP: TIdTCPClient;
    N9: TMenuItem;
    mnuSom: TMenuItem;
    statusbar: TStatusBar;

    procedure mnuSomClick(Sender: TObject);
    procedure lvServidoresDblClick(Sender: TObject);
    procedure mnuLigarClick(Sender: TObject);
    procedure mnuDirClick(Sender: TObject);
    procedure mnuMailClick(Sender: TObject);
    procedure mnuWWWClick(Sender: TObject);
    procedure mnuDeskClick(Sender: TObject);
    procedure mnuProgramaClick(Sender: TObject);
    procedure mnuRebootClick(Sender: TObject);
    procedure mnuMensagemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuChatClick(Sender: TObject);
    procedure mnuConectarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FListaServidores: TStringList;
    FComandos : TComandosClass;
    FUDPThread : TUDPClientThread;
    procedure Ligar;
    procedure ConectarAosServidores;

   procedure OnUDPReceive(Sender: TObject; AData: TIdBytes;
                          datasize : cardinal);
  public
    { Public declarations }
  end;

var
  frmMainCliente: TfrmMainCliente;

implementation

{$R *.dfm}

uses registry, idmessage, ufrmUser, IdReply, ufrmMensagens,
     jpeg;

procedure TfrmMainCliente.mnuConectarClick(Sender: TObject);
var
  i: integer;
begin
  i := lvServidores.ItemIndex; 
  if i > -1 then
    if lvServidores.Items[i].Caption = 'on' then 
      with TfrmUser.Create(self) do
        begin
        tcpCliente.Host := lvServidores.Items[i].SubItems[0];
        try
          tcpCliente.Connect;
          Caption := 'Servidor: ' + tcpCliente.Host;
          IP :=  tcpCliente.Host;
          Show; 
        except
          free;
        end;             
        end;   
end;

procedure TfrmMainCliente.mnuDeskClick(Sender: TObject);
var com : TComando;
    frm : TfrmUser;
    fs : TFileStream;
    sTemp : array[0..255] of char;
  strTamanhoArquivo: string;
  iTamanhoArquivo: Integer;
begin
  frm := TfrmUser(ActiveMDIChild);

  if (GetTempFileName('.', pchar('img'), 0, sTemp) = 0 ) or
     (not assigned(frm) ) then exit;

  StrPCopy(stemp, ChangeFileExt(stemp, '.jpg'));

  com := FComandos.Add;
  com.nome := COMM_STR_GETSCREEN;

  frm.tcpCliente.SendCmd(com.nome);

  //pega o tamnho do arquivo
  strTamanhoArquivo := trim(frm.tcpCliente.IOHandler.ReadLn);
  try
    iTamanhoArquivo := strtoint(strTamanhoArquivo);
  except
    exit;
  end;

  fs := TFileStream.Create( sTemp, fmCreate or fmShareExclusive) ;
  try
    frm.tcpCliente.IOHandler.ReadStream(fs, iTamanhoArquivo);
  finally
    fs.Free;
    frm.imgDesk.Picture.LoadFromFile (stemp);
  end;

  com.Enviado := true;
  com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
  com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;


//  if com.resposta.valor = RESP_OK then
//    begin
//    frm.Pages.Pages[2].Visible := true;
//    frm.imgDesk.Picture.LoadFromFile(stemp);
//    end
//  else
//    begin
////    frm.Pages.Pages[2].Visible := false;
////    frm.imgDesk.Picture := nil;
////    ShowMessage(Format('Erro: %d. #13#10 %s',
////                [com.resposta.valor, com.resposta.texto]));
//    end;

  FComandos.Flush(fmOpenReadWrite);

end;

procedure TfrmMainCliente.mnuDirClick(Sender: TObject);
var
  com: TComando;
  frm : TfrmUser;
  pai : array of TArquivoInfo;
  //ms : TFileStream;
  ms : TMemoryStream;
  I, q: Integer;
  strSize : string;
  _data : TDateTime;
  iSize: integer;
  ai : TArquivoInfo;
begin
  frm := TfrmUser(ActiveMDIChild);

  if not assigned(frm)  then exit;

  com := FComandos.Add;
  com.nome := COMM_STR_GETLISTDIR;

  com.params := trim( inputbox('Diretório a pesquisar', 'Diretorio:', 'c:'));

  frm.txtDir.Text := com.params;
  frm.tcpCliente.SendCmd(com.nome + ' ' + com.params);

  strSize := frm.tcpCliente.IOHandler.ReadLn;
  iSize := strtoint(trim(strSize));

  ms := TMemoryStream.Create ;
  try
    frm.tcpCliente.IOHandler.ReadStream(ms, iSize);
    ms.Position := 0;

    setLength(pai, iSize div sizeof(TArquivoInfo));

    ms.Read(pai[0], isize) ;

    frm.lvDirs.Clear;

    q := high(pai);
    for I := 0 to q do
      with frm.lvDirs.Items.Add do
        begin
        Caption := pai[i].Name;
        if pai[i].Attr and faDirectory = faDirectory then
          ImageIndex := 1
        else
          ImageIndex := 0;
        SubItems.Add( Format('%d', [pai[i].Size]) );

        _Data := FileDateToDateTime(pai[i].Time);
        SubItems.Add(DateTimeToStr(_data));
        application.ProcessMessages;
        end;

  finally
    Setlength(pai,0);
    ms.Free;
  end;

  com.Enviado := true;
  com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
  com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;

  if com.resposta.valor = RESP_OK then
    frm.Pages.Pages[3].Visible := true
  else
    begin
//    frm.Pages.Pages[3].Visible := false;
//    frm.lvDirs.Clear;
//    ShowMessage(Format('Erro: %d. #13#10 %s',
//                [com.resposta.valor, com.resposta.texto]));
    end;

  FComandos.Flush(fmOpenReadWrite);


end;

procedure TfrmMainCliente.mnuLigarClick(Sender: TObject);
begin
  Ligar;
end;

procedure TfrmMainCliente.mnuMensagemClick(Sender: TObject);
var com : TComando;
    frm : TfrmUser;
begin
  frm := TfrmUser(ActiveMDIChild);
  if not Assigned(frm) then exit;

  with TfrmMensagens.Create(self) do
  try
    if ShowModal = mrOk then
      begin
        com := FComandos.Add;
        com.nome := COMM_STR_MSG;
        com.params := memMensagem.Text + ' ';

        case rbBotoes.ItemIndex of
          0: com.params := com.params + COMM_STR_PARAMS_MSG_OKCANCEL+ ' ';
          1: com.params := com.params + COMM_STR_PARAMS_MSG_YESNO + ' ';
        end;

        com.params := com.params + inttostr(rbIcones.ItemIndex);


        frm.tcpCliente.SendCmd(com.nome + ' ' + com.params);  

        com.Enviado := true;
        com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
        com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;
      end;       
  finally
    Free;
  end;  

  FComandos.Flush(fmOpenRead);    
  
end;

procedure TfrmMainCliente.mnuRebootClick(Sender: TObject);
var com : TComando;
    frm : TfrmUser;
begin
  frm := TfrmUser(ActiveMDIChild);
  if not Assigned(frm) then exit;

  com := FComandos.Add;

  if sender = mnuReboot then
     com.nome := COMM_STR_REBOOT
  else if sender = mnuShootdown then
     com.nome := COMM_STR_SHOOTDONW
  else exit;

  try
    frm.tcpCliente.SendCmd(com.nome);
    com.Enviado := true;
    com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
    com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;
  except
    com.Enviado := false;
  end;

   FComandos.Flush(fmOpenReadWrite);
end;

procedure TfrmMainCliente.mnuSomClick(Sender: TObject);
var com : TComando;
    frm : TfrmUser;
begin
  frm := TfrmUser(ActiveMDIChild);
  if not Assigned(frm) then exit;


  com := FComandos.Add;
  com.nome := COMM_STR_SOUND;

  mnuSom.Checked := not mnuSom.Checked;

  try
    if mnuSom.Checked then
      begin
      com.params := COMM_STR_PARAMS_SOUND_START;
      if FUDPThread = nil then
        begin
        FUDPThread := TUDPClientThread.Create(frm.tcpCliente.Host,
                                               PORT_UDP_SERVER);
        FUDPThread.Connect;
        end
      else
        begin
        if not FUDPThread.Connected then
          begin
          FUDPThread.Suspend;
          FUDPThread.Connect;
          FUDPThread.Resume;
          end;
        mnuSom.Checked := true;
       // exit;
        end;
      end
    else
      begin
      com.params := COMM_STR_PARAMS_SOUND_STOP;
      if FUDPThread <> nil then
        FUDPThread.Disconnect;
      end;   

    frm.tcpCliente.SendCmd(com.nome + ' ' + com.params);
    com.Enviado := true;
    com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
    com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;
  except
    com.Enviado := false;
  end;      

  FComandos.Flush(fmOpenReadWrite);

end;

procedure TfrmMainCliente.mnuWWWClick(Sender: TObject);
var com : TComando;
    frm : TfrmUser;
    sSite : string;
begin
  frm := TfrmUser(ActiveMDIChild);
  sSite :=  InputBox('WWW','','');

  if( trim(sSite) = '' ) or
    (not Assigned(frm) )  then exit;

  com := FComandos.Add;
  com.nome := COMM_STR_WWW;
  com.params := trim(sSite);

  try
    frm.tcpCliente.SendCmd(com.nome + ' ' + com.params);
    com.Enviado := true;
    com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
    com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;
  except
    com.Enviado := false;
  end;

   FComandos.Flush(fmOpenReadWrite);
end;

procedure TfrmMainCliente.OnUDPReceive(Sender: TObject; AData: TIdBytes;
                         datasize : cardinal);
var
  FSoundDownload: cardinal;
begin
  FSoundDownload := FSoundDownload + datasize;
  statusbar.Panels[3].Text := IntToStr(FSoundDownload div 1024) + ' kb'; 
  //pegar o buffer e meter na caixa de som
end;

procedure TfrmMainCliente.mnuProgramaClick(Sender: TObject);
var com : TComando;
    frm : TfrmUser;
begin
  frm := TfrmUser(ActiveMDIChild);
  if not Assigned(frm) then exit;

  com := FComandos.Add;
  with com do
    begin
    nome := COMM_STR_RUN;
    params := InputBox('Programa a correr remotamente', '', '');
    end;

  if trim(com.params) = '' then
    begin
    FComandos.Delete(com);
    exit;
    end;

  try
    frm.tcpCliente.SendCmd(com.nome);

    com.Enviado := true;
    com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
    com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;

    frm.Pages.Pages[1].Visible := (com.resposta.valor = RESP_OK);
  except
    com.Enviado := false;
  end;     
end;

procedure TfrmMainCliente.mnuChatClick(Sender: TObject);
var com : TComando;
    frm : TfrmUser;
begin
  frm := TfrmUser(ActiveMDIChild);
  if not Assigned(frm) then exit;

  com := FComandos.Add;
  com.nome := COMM_STR_CHAT;

  try
    frm.tcpCliente.SendCmd(com.nome);
    com.Enviado := true;
    com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
    com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;

    frm.Pages.Pages[1].Visible := (com.resposta.valor = RESP_OK);
  except
    com.Enviado := false;
    frm.Pages.Pages[1].Visible := false;
  end;

  FComandos.Flush(fmOpenRead);
end;

procedure TfrmMainCliente.ConectarAosServidores;
var
  I: Integer;
begin
  for I := 0 to FListaServidores.Count - 1 do
    with TCP do
      begin
        Host := FListaServidores[i];
        try
          Connect;
          if SendCmd(COMM_STR_PING, RESP_OK ) = RESP_OK then
            begin
            lvServidores.Items[i].Caption := 'on';
            Disconnect;
            end;               
        except end;           
      end;
end;

procedure TfrmMainCliente.FormCreate(Sender: TObject);
begin
  FListaServidores :=  TStringList.Create;
  FListaServidores.Duplicates := dupIgnore;

  FComandos := TComandosClass.Create;
  
  Ligar;
  Application.ProcessMessages;
  ConectarAosServidores;      
end;

procedure TfrmMainCliente.FormDestroy(Sender: TObject);
begin
  if FUDPThread<>nil then
    FreeAndNil(FUDPThread);
  FreeAndNil(FComandos);
  FreeAndNil (FListaServidores);
end;

procedure TfrmMainCliente.Ligar;
var pass, email, hostemail: string;
  iMsg: integer;
  msg : TidMessage;  
  I: integer;
begin
  {$ifdef debug}
  FListaServidores.Add('127.0.0.1');
  with lvServidores.Items.Add do
     begin
     Caption := 'off';
     SubItems.Add(FListaServidores[0]);
     end;
  exit;
  {$endif}


  email := '';
  pass := '';
  FListaServidores.Clear;
  
  with TRegistry.Create(HKEY_LOCAL_MACHINE) do
  try
    if OpenKey('\software\docsoft\preferencias', true) then
      begin
      hostemail := ReadString('hostemail');
      email := ReadString('email');
      pass := Readstring('pass');
      end;
  finally
    Free;
  end;

  if (hostemail = '' ) or (email = '' ) or (pass = '') then
      raise Exception.Create('Configure o servidor de email');

  with POP3 do
    begin
    Host := hostemail;
    Username := email;
    Password := pass;
    msg := TIdMessage.Create(self);
    try
     Connect;
     iMsg := CheckMessages; 
     if imsg > 0  then
       if Retrieve(imsg, msg) then
         if msg.Subject = EMAIL_TITULO then
           for I := 0 to msg.Body.Count - 1 do
             FListaServidores.Add(msg.Body[i]);     
    finally
      FreeAndNil(msg);
    end; 
    end;

  for I := 0 to FListaServidores.Count - 1 do
     with lvServidores.Items.Add do
       begin
       Caption := 'off';
       SubItems.Add(FListaServidores[i]);
       end;

end;

procedure TfrmMainCliente.lvServidoresDblClick(Sender: TObject);
var
  I: Integer;
  id : integer;
  _ip : string;
begin
  id := lvServidores.ItemIndex;
  if id = -1 then exit;

  _ip := trim(lvServidores.Items[id].SubItems[0]);

  for I := 0 to  MDIChildCount - 1 do
    if MDIChildren[i].Caption = _ip then
        exit;

  with TfrmUser.Create(self) do
    try
      tcpCliente.Host := _ip;
      TCPCliente.Connect;
      caption := _ip;
      Visible := true;
      lvServidores.Items[id].Caption := 'on';
    except on E: Exception do
      begin
      Free;
      Raise Exception.Create(e.Message);
      end;
    end;
end;

procedure TfrmMainCliente.mnuMailClick(Sender: TObject);
var com : TComando;
    frm : TfrmUser;
begin
  frm := TfrmUser(ActiveMDIChild);
  if not Assigned(frm) then exit;

  com := FComandos.Add;
  com.nome := COMM_STR_SENDMAIL;

  //implementar parametros

  try
    frm.tcpCliente.SendCmd(com.nome);
    com.Enviado := true;
    com.resposta.texto := frm.tcpCliente.LastCmdResult.Text.Text;
    com.resposta.valor := frm.tcpCliente.LastCmdResult.NumericCode;

    frm.Pages.Pages[1].Visible := (com.resposta.valor = RESP_OK);
  except
    com.Enviado := false;

  end;

  FComandos.Flush(fmOpenRead);
end;

end.


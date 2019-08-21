program WinNTCom;

uses
  Forms,
  main in 'main.pas' {Form1},
  comando in 'comando.pas',
  Mensagem in 'Mensagem.pas' {frmMensagem},
  uwave in 'uwave.pas',
  uwavegsm in 'uwavegsm.pas',
  commsound in 'commsound.pas',
  uUDPgsmThread in 'uUDPgsmThread.pas',
  uGsmNet in 'uGsmNet.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

program RTO;

uses
  Forms,
  maincliente in 'maincliente.pas' {frmMainCliente},
  ufrmUser in 'ufrmUser.pas' {frmUser},
  comando in 'comando.pas',
  ufrmMensagens in 'ufrmMensagens.pas' {frmMensagens},
  uTcpThread in 'uTcpThread.pas',
  uUdpThread in 'uUdpThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMainCliente, frmMainCliente);
  Application.CreateForm(TfrmMensagens, frmMensagens);
  Application.Run;
end.

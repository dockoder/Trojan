program Som;

uses
  Forms,
  usomteste in 'usomteste.pas' {Form2},
  usrvsound in 'usrvsound.pas',
  uwave in 'uwave.pas',
  uwaverec in 'uwaverec.pas',
  uwaveplay in 'uwaveplay.pas',
  uwavegsm in 'uwavegsm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

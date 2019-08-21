unit Mensagem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmMensagem = class(TForm)
    Label1: TLabel;
    pnlRespostaSimNao: TPanel;
    Button1: TButton;
    Button4: TButton;
    pnlRespostaOKCancel: TPanel;
    Button2: TButton;
    Button3: TButton;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMensagem: TfrmMensagem;

implementation

{$R *.dfm}

procedure TfrmMensagem.Timer1Timer(Sender: TObject);
begin
close;
end;

procedure TfrmMensagem.Button1Click(Sender: TObject);
begin
close;
end;

end.

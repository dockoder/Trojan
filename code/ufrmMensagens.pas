unit ufrmMensagens;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfrmMensagens = class(TForm)
    memMensagem: TMemo;
    Label1: TLabel;
    rbBotoes: TRadioGroup;
    rbIcones: TRadioGroup;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMensagens: TfrmMensagens;

implementation

{$R *.dfm}

end.

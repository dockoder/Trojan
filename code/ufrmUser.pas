unit ufrmUser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, StdCtrls, ExtCtrls,
  ImgList;

type
  TfrmUser = class(TForm)
    tcpCliente: TIdTCPClient;
    IO: TIdIOHandlerStack;
    Pages: TPageControl;
    TabSheet1: TTabSheet;
    memLog: TMemo;
    TabSheet2: TTabSheet;
    memChat: TMemo;
    txtTexto: TEdit;
    Label1: TLabel;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    lvDirs: TListView;
    txtDir: TEdit;
    Label2: TLabel;
    imgList: TImageList;
    ScrollBox1: TScrollBox;
    imgDesk: TImage;
    pbarDownload: TProgressBar;
    TabSheet5: TTabSheet;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    IP : string;
  end;

var
  frmUser: TfrmUser;

implementation

{$R *.dfm}

procedure TfrmUser.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tcpCliente.Disconnect;
  action := cafree;
end;

end.

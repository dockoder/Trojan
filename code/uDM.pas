unit uDM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  IdBaseComponent, IdComponent, IdTCPServer;

type
  TService2 = class(TService)
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  Service2: TService2;

implementation

uses comando;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  Service2.Controller(CtrlCode);
end;

function TService2.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

end.

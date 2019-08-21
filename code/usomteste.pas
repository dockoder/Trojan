unit usomteste;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uwavegsm, StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    som : TGSMRec;
    FBuffer : array of char;
    procedure procdata (sender:TObject;
                            const Buffer:pointer;
                            const BufferSize:cardinal;
                            const BytesRecorded:cardinal)   ;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
 som.Open;
  som.Start;
end;

procedure TForm2.Button2Click(Sender: TObject);
var ms : TMemoryStream;
begin
  som.Close;
  som.Flush;
  ms := TMemoryStream.Create;
  try
    ms.Write(fbuffer, length(FBuffer));
    ms.SaveToFile('testedesom.dat');
  finally
    ms.free;

  end;

end;


procedure TForm2.FormCreate(Sender: TObject);
begin
  som := TGSMRec.Create;
  //som.Keep := true;
  som.FilePath := '123.dat';
  som.OnDataAvail := procdata;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  FreeAndNil(som);
end;

procedure TForm2.procdata(sender: TObject; const Buffer: pointer;
  const BufferSize, BytesRecorded: cardinal);
var i : integer;
begin
  i := high(FBuffer);
  setlength(FBuffer, length(Fbuffer) + BufferSize);
  CopyMemory(FBuffer, buffer, BytesRecorded);
end;

end.

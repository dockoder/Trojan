unit TComando;

interface

type
  TResposta = record
    texto : string;
    valor : integer;
  end;

  TComando = record
    nome : string;
    params : string;
    id   : integer;
    resposta : TResposta;
  end;

  TComandoClass = class
  private
    Comandos : array of TComando;
    procedure Delete(id : integer); overload;
  public
    function Add : TComando;
    procedure Delete(comm : TComando); overload;


  end;



implementation

end.
 
object frmMainCliente: TfrmMainCliente
  Left = 0
  Top = 0
  Caption = 'Remote Takeover (RTO)'
  ClientHeight = 293
  ClientWidth = 538
  Color = clAppWorkSpace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 274
    Align = alLeft
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 105
      Width = 183
      Height = 13
      Align = alTop
      Caption = 'Log:'
      ExplicitWidth = 21
    end
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 183
      Height = 13
      Align = alTop
      Caption = 'Lista de servidores:'
      ExplicitWidth = 94
    end
    object Splitter1: TSplitter
      Left = 1
      Top = 100
      Width = 183
      Height = 5
      Cursor = crVSplit
      Align = alTop
      Beveled = True
      ExplicitTop = 103
    end
    object Memo1: TMemo
      Left = 1
      Top = 118
      Width = 183
      Height = 155
      Align = alClient
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        'Memo1')
      ParentFont = False
      TabOrder = 0
    end
    object lvServidores: TListView
      Left = 1
      Top = 14
      Width = 183
      Height = 86
      Align = alTop
      Columns = <
        item
          Caption = 'Estado'
        end
        item
          Caption = 'Nome'
          Width = 104
        end>
      TabOrder = 1
      ViewStyle = vsReport
      OnDblClick = lvServidoresDblClick
    end
  end
  object statusbar: TStatusBar
    Left = 0
    Top = 274
    Width = 538
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Bevel = pbNone
        Text = 'Capturando som de:'
        Width = 110
      end
      item
        Alignment = taCenter
        Width = 100
      end
      item
        Alignment = taCenter
        Bevel = pbNone
        Text = 'Download'
        Width = 55
      end
      item
        Width = 50
      end>
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 56
    object Arquivo1: TMenuItem
      Caption = 'Arquivo'
      Hint = 'Arquivo'
      object mnuLigar: TMenuItem
        Caption = 'Ligar'
        OnClick = mnuLigarClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnuConectar: TMenuItem
        Caption = 'Conectar'
        OnClick = mnuConectarClick
      end
      object Conectartodos1: TMenuItem
        Caption = 'Conectar todos'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Desconectar1: TMenuItem
        Caption = 'Desconectar'
      end
      object Desconectartodos1: TMenuItem
        Caption = 'Desconectar todos'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Preferencias1: TMenuItem
        Caption = 'Preferencias...'
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object Sair1: TMenuItem
        Caption = 'Sair'
      end
    end
    object Comandos1: TMenuItem
      Caption = 'Comandos'
      object mnuChat: TMenuItem
        Caption = 'Chat'
        OnClick = mnuChatClick
      end
      object mnuMensagem: TMenuItem
        Caption = 'Mensagem...'
        OnClick = mnuMensagemClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object Arquivo2: TMenuItem
        Caption = 'Arquivo...'
      end
      object mnuDir: TMenuItem
        Caption = 'Diretorios'
        OnClick = mnuDirClick
      end
      object Script1: TMenuItem
        Caption = 'Script...'
      end
      object mnuPrograma: TMenuItem
        Caption = 'Programa...'
        OnClick = mnuProgramaClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object mnuReboot: TMenuItem
        Caption = 'Reiniciar sistema remoto'
        OnClick = mnuRebootClick
      end
      object mnuShootdown: TMenuItem
        Caption = 'Desligar sistema remoto'
        OnClick = mnuRebootClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object mnuDesk: TMenuItem
        Caption = 'Desktop'
        OnClick = mnuDeskClick
      end
      object CapturarRato1: TMenuItem
        Caption = 'Capturar Rato'
      end
      object LiberarRato1: TMenuItem
        Caption = 'Liberar Rato'
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mnuWWW: TMenuItem
        Caption = 'WWW...'
        OnClick = mnuWWWClick
      end
      object mnuMail: TMenuItem
        Caption = 'Mail...'
        OnClick = mnuMailClick
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object mnuSom: TMenuItem
        Caption = 'Som'
        OnClick = mnuSomClick
      end
    end
    object Ver1: TMenuItem
      Caption = 'Ver'
    end
    object Ajuda1: TMenuItem
      Caption = 'Ajuda'
    end
  end
  object SMTP: TIdSMTP
    SASLMechanisms = <>
    Left = 200
    Top = 48
  end
  object POP3: TIdPOP3
    AutoLogin = True
    SASLMechanisms = <>
    Left = 232
    Top = 48
  end
  object TCP: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 19670
    ReadTimeout = -1
    Left = 200
    Top = 16
  end
end

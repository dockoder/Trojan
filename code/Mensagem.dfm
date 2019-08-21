object frmMensagem: TfrmMensagem
  Left = 404
  Top = 338
  BorderStyle = bsDialog
  Caption = 'Mensagem'
  ClientHeight = 105
  ClientWidth = 311
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 289
    Height = 57
    AutoSize = False
    Caption = 'Label1'
    WordWrap = True
  end
  object pnlRespostaSimNao: TPanel
    Left = 0
    Top = 51
    Width = 311
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    object Button1: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 25
      Caption = 'SIM'
      ModalResult = 6
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button4: TButton
      Left = 78
      Top = 1
      Width = 75
      Height = 25
      Caption = 'N'#195'O'
      ModalResult = 7
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object pnlRespostaOKCancel: TPanel
    Left = 0
    Top = 78
    Width = 311
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    Visible = False
    object Button2: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 78
      Top = 1
      Width = 75
      Height = 25
      Caption = 'CANCELAR'
      ModalResult = 2
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object Timer1: TTimer
    Interval = 30000
    OnTimer = Timer1Timer
    Left = 200
    Top = 32
  end
end

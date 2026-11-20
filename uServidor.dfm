object frmServer: TfrmServer
  Left = 346
  Top = 241
  Width = 366
  Height = 463
  Caption = 'SERVIDOR REST SAGE V0.0'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object MemoLog: TMemo
    Left = 9
    Top = 35
    Width = 329
    Height = 378
    Lines.Strings = (
      'MemoLog')
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object btnIniciar: TButton
    Left = 7
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Iniciar'
    TabOrder = 1
    OnClick = btnIniciarClick
  end
  object btnDetener: TButton
    Left = 88
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Detener'
    TabOrder = 2
    OnClick = btnDetenerClick
  end
  object IdHTTPServer1: TIdHTTPServer
    Bindings = <>
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 144
    Top = 168
  end
end

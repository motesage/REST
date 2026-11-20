object frmCliente: TfrmCliente
  Left = 339
  Top = 176
  Width = 630
  Height = 377
  Caption = 'CLIENTE REST SAGE V0.0'
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
    Left = 15
    Top = 13
    Width = 22
    Height = 13
    Caption = 'URL'
  end
  object MemoRespuesta: TMemo
    Left = 315
    Top = 48
    Width = 289
    Height = 280
    Lines.Strings = (
      'MemoRespuesta')
    TabOrder = 0
  end
  object MemoJson: TMemo
    Left = 11
    Top = 47
    Width = 298
    Height = 281
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    Lines.Strings = (
      '{'
      '  "idOrdenMarkey": "MK-000001",'
      '  "paciente": {'
      '    "tipoDocumento": "DNI",'
      '    "numeroDocumento": "20123456",'
      '    "apellido": "PEREZ",'
      '    "nombre": "JUAN"'
      '  },'
      '  "practicas": ['
      '    {'
      '      "codigo": "904001",'
      '      "descripcion": "HEMOGRAMA"'
      '    }'
      '  ]'
      '}')
    ParentFont = False
    TabOrder = 1
    WordWrap = False
  end
  object btnEnviar: TButton
    Left = 514
    Top = 9
    Width = 75
    Height = 25
    Caption = 'Envia Msj'
    TabOrder = 2
    OnClick = btnEnviarClick
  end
  object edtURL: TEdit
    Left = 52
    Top = 11
    Width = 457
    Height = 21
    TabOrder = 3
    Text = 'http://127.0.0.1:8081/api/lis/paciente'
  end
  object IdHTTP1: TIdHTTP
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 224
    Top = 224
  end
end

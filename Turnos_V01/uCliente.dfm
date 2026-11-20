object frmCliente: TfrmCliente
  Left = 339
  Top = 176
  Width = 630
  Height = 377
  Caption = 'CLIENTE REST SAGE V0.1 - TURNOS MARKEY'
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
      '    "identificador": "1384463808A",'
      '    "fecha": "2026-08-11T00:00:00",'
      '    "ambito": "AMBULATORIO",'
      '    "observaciones": "prueba",'
      '    "urgente": false,'
      '    "confidencial": false,'
      '    "internacionUbicacion":"",'
      '    "paciente": {'
      '        "codigo": "347029",'
      '        "fechaNacimiento": "2000-01-01",'
      '        "sexo": "M",'
      '        "tipoDocumento": "DNI",'
      '        "numeroDocumento": "95652495",'
      '        "nombres": "MARCIAL JOSE",'
      '        "apellidoPaterno": "DURAN SALAZAR",'
      '        "contacto": {'
      '            "telefono": "54-11-11111111",'
      '            "email": "marcialduran@gmail.com",'
      
        '            "domicilio": "PANAMERICANA KM 49 COUNTRY MAPUCHE LOT' +
        'E 33 33"'
      '        },'
      '        "importePaciente":"",'
      '        "importeMutual":"",'
      '        "importeTotal":""'
      '    },'
      '    "obraSocial": {'
      '        "codigo": "123",'
      '        "nombre": "PARTICULAR",'
      '        "plan": "UNICO",'
      '        "numeroAfiliado": ""'
      '    },'
      '    "medico": {'
      '        "codigo": "276582",'
      '        "tipoDocumento": "DNI",'
      '        "numeroDocumento": "45430279",'
      '        "apellidoPaterno": "ROVEDA",'
      '        "nombres": "MATEO",'
      '        "contacto": {'
      '            "telefono": "54-11-12345678",'
      '            "Email": "not@gmail.com",'
      '            "domicilio": ""'
      '        },'
      '        "matricula": {'
      '            "numero": "13384",'
      '            "provincia": "BUENOS AIRES",'
      '            "tipo": "MP"'
      '        }'
      '    },'
      '    "UbicacionSolicitante": {'
      '        "codigo": "10005",'
      '        "nombre": "HOSPITAL GERIATRICO RODRIGUEZ ORTEGA",'
      '        "contacto": {'
      '            "telefono": "",'
      '            "domicilio": "Mariano Pellliza",'
      '            "email": ""'
      '        }'
      '    },'
      '    "practicas": ['
      '        {'
      '            "codigo": "412",'
      '            "nombre": "GLUCEMIA",'
      '            "importePaciente":"",'
      '            "importeMutual":"",'
      '            "importeTotal":""'
      '        }'
      '    ]'
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
    Text = 'http://200.41.170.126:8081/api/lis/turnos'
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

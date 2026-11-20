object frmLabRest: TfrmLabRest
  Left = 240
  Top = 150
  ClientWidth = 650
  ClientHeight = 405
  Caption = 'SageLab - Terminal liviana (demostracion)'
  Position = poScreenCenter
  object lblPuesto: TLabel
    Left = 16
    Top = 60
    Caption = 'Puesto: -'
  end
  object lblOrden: TLabel
    Left = 16
    Top = 84
    Caption = 'Orden: -'
  end
  object lblPaciente: TLabel
    Left = 16
    Top = 108
    Caption = 'Paciente: -'
  end
  object lblMedico: TLabel
    Left = 16
    Top = 132
    Caption = 'Medico: -'
  end
  object lblInstitucion: TLabel
    Left = 16
    Top = 156
    Caption = 'Institucion: -'
  end
  object lblPracticas: TLabel
    Left = 16
    Top = 187
    Caption = 'Practicas'
  end
  object lblEntrega: TLabel
    Left = 16
    Top = 302
    Caption = 'Fecha de entrega'
  end
  object lblEstado: TLabel
    Left = 16
    Top = 371
    Caption = 'Cargue una orden de demostracion.'
  end
  object lvPracticas: TListView
    Left = 16
    Top = 207
    Width = 618
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        Caption = 'Codigo'
        Width = 100
      end
      item
        Caption = 'Practica'
        Width = 470
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object dtpEntrega: TDateTimePicker
    Left = 123
    Top = 298
    Width = 120
    Height = 21
    Enabled = False
    TabOrder = 2
    OnChange = dtpEntregaChange
  end
  object btnCargar: TButton
    Left = 16
    Top = 16
    Width = 192
    Height = 25
    Caption = 'Cargar orden de demostracion'
    TabOrder = 0
    OnClick = btnCargarClick
  end
  object btnConfirmar: TButton
    Left = 256
    Top = 296
    Width = 140
    Height = 25
    Caption = 'Confirmar entrega'
    Enabled = False
    TabOrder = 3
    OnClick = btnConfirmarClick
  end
  object btnTalon: TButton
    Left = 16
    Top = 333
    Width = 140
    Height = 25
    Caption = 'Simular talon'
    Enabled = False
    TabOrder = 4
    OnClick = btnTalonClick
  end
  object btnEtiquetas: TButton
    Left = 166
    Top = 333
    Width = 140
    Height = 25
    Caption = 'Simular etiquetas'
    Enabled = False
    TabOrder = 5
    OnClick = btnEtiquetasClick
  end
end

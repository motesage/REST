unit uLabRest;

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ComCtrls;

type
  TfrmLabRest = class(TForm)
    lblPuesto: TLabel;
    lblOrden: TLabel;
    lblPaciente: TLabel;
    lblMedico: TLabel;
    lblInstitucion: TLabel;
    lblPracticas: TLabel;
    lvPracticas: TListView;
    lblEntrega: TLabel;
    dtpEntrega: TDateTimePicker;
    btnCargar: TButton;
    btnConfirmar: TButton;
    btnTalon: TButton;
    btnEtiquetas: TButton;
    lblEstado: TLabel;
    procedure btnCargarClick(Sender: TObject);
    procedure dtpEntregaChange(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnTalonClick(Sender: TObject);
    procedure btnEtiquetasClick(Sender: TObject);
  private
    FFechaRecepcion: TDateTime;
  end;

var
  frmLabRest: TfrmLabRest;

implementation

{$R *.dfm}

procedure TfrmLabRest.btnCargarClick(Sender: TObject);
var
  Practica: TListItem;
begin
  FFechaRecepcion := Date;
  lblPuesto.Caption := 'Puesto: RECEPCION-LAB-02 | Ambulatorio | Empresa 2';
  lblOrden.Caption := 'Orden: DEMO-001 | Boleta: 1001 | Version: 1';
  lblPaciente.Caption := 'Paciente: Paciente de prueba';
  lblMedico.Caption := 'Medico: Profesional de prueba';
  lblInstitucion.Caption := 'Institucion: Institucion de prueba';
  lvPracticas.Items.Clear;
  Practica := lvPracticas.Items.Add;
  Practica.Caption := 'DEMO-01';
  Practica.SubItems.Add('Hemograma');
  Practica := lvPracticas.Items.Add;
  Practica.Caption := 'DEMO-02';
  Practica.SubItems.Add('Glucemia');

  { Plazo simulado hasta incorporar el calculo de SageLab. }
  dtpEntrega.Date := FFechaRecepcion + 2;
  dtpEntrega.Enabled := True;
  dtpEntregaChange(dtpEntrega);
end;

procedure TfrmLabRest.dtpEntregaChange(Sender: TObject);
begin
  btnConfirmar.Enabled := dtpEntrega.Enabled;
  btnTalon.Enabled := False;
  btnEtiquetas.Enabled := False;
  lblEstado.Caption := 'Entrega pendiente de confirmacion.';
end;

procedure TfrmLabRest.btnConfirmarClick(Sender: TObject);
begin
  if Trunc(dtpEntrega.Date) < Trunc(FFechaRecepcion) then
  begin
    lblEstado.Caption := 'La entrega debe ser igual o posterior a la recepcion.';
    Exit;
  end;

  btnConfirmar.Enabled := False;
  btnTalon.Enabled := True;
  btnEtiquetas.Enabled := True;
  lblEstado.Caption := 'Entrega confirmada para el ' +
    DateToStr(dtpEntrega.Date) + '.';
end;

procedure TfrmLabRest.btnTalonClick(Sender: TObject);
begin
  btnTalon.Enabled := False;
  lblEstado.Caption := 'Emision del talon simulada.';
end;

procedure TfrmLabRest.btnEtiquetasClick(Sender: TObject);
begin
  btnEtiquetas.Enabled := False;
  lblEstado.Caption := 'Emision de etiquetas simulada.';
end;

end.

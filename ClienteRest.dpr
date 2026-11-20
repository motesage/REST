program ClienteRest;

uses
  ExceptionLog,
  Forms,
  uCliente in 'uCliente.pas' {frmCliente};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmCliente, frmCliente);
  Application.Run;
end.

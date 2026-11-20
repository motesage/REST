program ServidorRest;

uses
  ExceptionLog,
  Forms,
  uServidor in 'uServidor.pas' {frmServer};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmServer, frmServer);
  Application.Run;
end.

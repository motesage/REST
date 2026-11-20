program ServidorRest;

uses
  ExceptionLog,
  Forms,
  uFiltroEurekaIndy in 'uFiltroEurekaIndy.pas',
  uServidor in 'uServidor.pas' {frmServer};

{$R *.res}

begin
  ConfigurarFiltroEurekaIndy;
  Application.Initialize;
  Application.CreateForm(TfrmServer, frmServer);
  Application.Run;
end.

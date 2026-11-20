unit uFiltroEurekaIndy;

interface

procedure ConfigurarFiltroEurekaIndy;

implementation

uses ExceptionLog, ECore;

procedure AgregarFiltro(const Clase: string);
var
  Filtro: PEurekaExceptionFilter;
begin
  New(Filtro);
  Filtro^.Active := True;
  Filtro^.ExceptionClassName := Clase;
  Filtro^.ExceptionMessage := '';
  Filtro^.ExceptionType := fetAll;
  Filtro^.DialogType := fdtNone;
  { EurekaLog 6 devuelve el control al manejador original de Indy.
    No usar fhtNone: impediria que Indy invoque nuestro OnException. }
  Filtro^.HandlerType := fhtRTL;
  Filtro^.ActionType := fatNone;
  CurrentEurekaLogOptions.ExceptionsFilters.Insert(0, Filtro);
end;

procedure ConfigurarFiltroEurekaIndy;
begin
  if not IsEurekaLogActive then Exit;
  AgregarFiltro('EIdConnClosedGracefully');
  AgregarFiltro('EIdHTTPErrorParsingCommand');
end;

end.

unit uFiltroEurekaIndy;

interface

procedure ConfigurarFiltroEurekaIndy;

implementation

uses ExceptionLog, ECore;

procedure ConfigurarFiltroEurekaIndy;
var
  Filtro: PEurekaExceptionFilter;
begin
  if not IsEurekaLogActive then Exit;
  New(Filtro);
  Filtro^.Active := True;
  Filtro^.ExceptionClassName := 'EIdConnClosedGracefully';
  Filtro^.ExceptionMessage := '';
  Filtro^.ExceptionType := fetAll;
  Filtro^.DialogType := fdtNone;
  { EurekaLog 6 devuelve el control al manejador original de Indy.
    No usar fhtNone: impediria que Indy invoque nuestro OnException. }
  Filtro^.HandlerType := fhtRTL;
  Filtro^.ActionType := fatNone;
  CurrentEurekaLogOptions.ExceptionsFilters.Insert(0, Filtro);
end;

end.

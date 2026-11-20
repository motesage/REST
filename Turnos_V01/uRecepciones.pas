unit uRecepciones;

interface

uses Windows, SysUtils, Classes;

type
  TRecepciones = class
  private
    FCritica: TRTLCriticalSection;
    FBase, FArchivo: string;
    FDatos: TStringList;
    procedure Explorar(const Carpeta, Prefijo, Tipo: string);
    procedure Actualizar;
  public
    constructor Create(const Base: string);
    destructor Destroy; override;
    function Consultar(const Desde: string): string;
  end;

implementation

constructor TRecepciones.Create(const Base: string);
begin
  inherited Create;
  InitializeCriticalSection(FCritica);
  FDatos := TStringList.Create;
  FBase := IncludeTrailingPathDelimiter(Base) + 'Logs' + PathDelim;
  FArchivo := FBase + 'Recepciones.idx';
end;

destructor TRecepciones.Destroy;
begin
  FDatos.Free;
  DeleteCriticalSection(FCritica);
  inherited Destroy;
end;

procedure TRecepciones.Explorar(const Carpeta, Prefijo, Tipo: string);
var
  SR: TSearchRec;
  Nombres: TStringList;
  I, J, Busqueda: Integer;
  Nombre, Fecha, Id: string;
  Existe: Boolean;
begin
  Nombres := TStringList.Create;
  try
    Busqueda := FindFirst(FBase + Carpeta + PathDelim + Prefijo + '_*.json', faAnyFile, SR);
    if Busqueda = 0 then
    begin
      try
        repeat
          if (SR.Attr and faDirectory = 0) and (SR.Size > 0) then
            Nombres.Add(SR.Name);
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end
    else if (Busqueda <> ERROR_FILE_NOT_FOUND) and
      (Busqueda <> ERROR_PATH_NOT_FOUND) and (Busqueda <> ERROR_NO_MORE_FILES) then
      raise Exception.Create('No se pudo consultar carpeta RAW: ' + Carpeta);
    Nombres.Sort;
    for I := 0 to Nombres.Count - 1 do
    begin
      Nombre := Nombres[I];
      { Solo nombres generados por el receptor; nunca contenido del RAW. }
      Id := Copy(Nombre, Length(Prefijo) + 22, 36);
      if (Length(Nombre) <> Length(Prefijo) + 62) or
         (Copy(Nombre, Length(Prefijo) + 58, 5) <> '.json') then Continue;
      try
        StringToGUID('{' + Id + '}');
      except
        Continue;
      end;
      Existe := False;
      for J := 1 to FDatos.Count - 1 do
        if Pos('"archivo":"' + Nombre + '"', FDatos[J]) > 0 then
        begin
          Existe := True;
          Break;
        end;
      if Existe then Continue;
      Fecha := Copy(Nombre, Length(Prefijo) + 2, 4) + '-' +
        Copy(Nombre, Length(Prefijo) + 6, 2) + '-' +
        Copy(Nombre, Length(Prefijo) + 8, 2) + 'T' +
        Copy(Nombre, Length(Prefijo) + 11, 2) + ':' +
        Copy(Nombre, Length(Prefijo) + 13, 2) + ':' +
        Copy(Nombre, Length(Prefijo) + 15, 2) + '.' +
        Copy(Nombre, Length(Prefijo) + 18, 3);
      FDatos.Add('{"id":' + IntToStr(FDatos.Count) + ',"tipo":"' + Tipo +
        '","fechaHoraLocal":"' + Fecha + '","archivo":"' + Nombre + '"}');
    end;
  finally
    Nombres.Free;
  end;
end;

procedure TRecepciones.Actualizar;
var
  Id: TGUID;
  Anterior: Integer;
begin
  { Recargar disco en cada consulta: tras un fallo no se publica un cursor
    que todavia no haya sido persistido. El lock serializa consultas. }
  FDatos.Clear;
  if FileExists(FArchivo) then FDatos.LoadFromFile(FArchivo);
  if FDatos.Count = 0 then
  begin
    if CreateGUID(Id) <> 0 then raise Exception.Create('No se pudo crear instancia');
    FDatos.Add(Copy(GUIDToString(Id), 2, 36));
  end;
  StringToGUID('{' + FDatos[0] + '}');
  Anterior := FDatos.Count;
  Explorar('Turnos', 'Turno', 'TURNO');
  Explorar('Ordenes', 'Orden', 'ORDEN');
  if (FDatos.Count <> Anterior) or not FileExists(FArchivo) then
  begin
    if not ForceDirectories(FBase) then raise Exception.Create('No se pudo crear Logs');
    FDatos.SaveToFile(FArchivo + '.tmp');
    if not MoveFileEx(PChar(FArchivo + '.tmp'), PChar(FArchivo),
      MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
      RaiseLastOSError;
  end;
end;

function TRecepciones.Consultar(const Desde: string): string;
var
  Cursor: Int64;
  I, Ultimo, Siguiente: Integer;
  Lista, Mas: string;
begin
  EnterCriticalSection(FCritica);
  try
    Actualizar;
    Ultimo := FDatos.Count - 1;
    if Desde = '' then Cursor := Ultimo
    else if not TryStrToInt64(Desde, Cursor) then
      raise EConvertError.Create('Cursor invalido');
    if (Cursor < 0) or (Cursor > Ultimo) then
      raise EConvertError.Create('Cursor fuera de rango');
    Siguiente := Integer(Cursor);
    Lista := '';
    for I := Integer(Cursor) + 1 to Ultimo do
    begin
      if I > Cursor + 100 then Break;
      if Lista <> '' then Lista := Lista + ',';
      Lista := Lista + FDatos[I];
      Siguiente := I;
    end;
    Mas := 'false';
    if Siguiente < Ultimo then Mas := 'true';
    Result := '{"ok":true,"instancia":"' + FDatos[0] +
      '","ultimoId":' + IntToStr(Ultimo) + ',"siguienteId":' +
      IntToStr(Siguiente) + ',"hayMas":' + Mas + ',"recepciones":[' + Lista + ']}';
  finally
    LeaveCriticalSection(FCritica);
  end;
end;

end.

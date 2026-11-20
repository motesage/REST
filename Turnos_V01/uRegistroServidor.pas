unit uRegistroServidor;

interface

uses Windows, SysUtils, Classes;

type
  TRegistroServidor = class
  private
    FCritica: TRTLCriticalSection;
    FPendientes: TStringList;
    FRuta: string;
  public
    constructor Create(const RutaBase: string);
    destructor Destroy; override;
    procedure Anotar(const Texto: string);
    procedure Extraer(Destino: TStrings);
  end;

implementation

constructor TRegistroServidor.Create(const RutaBase: string);
begin
  inherited Create;
  InitializeCriticalSection(FCritica);
  FPendientes := TStringList.Create;
  FRuta := IncludeTrailingPathDelimiter(RutaBase) + 'Logs' + PathDelim;
end;

destructor TRegistroServidor.Destroy;
begin
  FPendientes.Free;
  DeleteCriticalSection(FCritica);
  inherited Destroy;
end;

procedure TRegistroServidor.Anotar(const Texto: string);
var
  Linea, Archivo, Bytes: string;
  F: TFileStream;
begin
  EnterCriticalSection(FCritica);
  try
    Linea := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' ' +
      StringReplace(StringReplace(Texto, #13, ' ', [rfReplaceAll]),
        #10, ' ', [rfReplaceAll]);
    try
      if not ForceDirectories(FRuta) then
        raise Exception.Create('No se pudo crear ' + FRuta);
      Archivo := FRuta + 'Servidor_' + FormatDateTime('yyyymmdd', Now) + '.log';
      if FileExists(Archivo) then
        F := TFileStream.Create(Archivo, fmOpenReadWrite or fmShareDenyWrite)
      else
        F := TFileStream.Create(Archivo, fmCreate);
      try
        F.Seek(0, soFromEnd);
        Bytes := UTF8Encode(WideString(Linea + #13#10));
        F.WriteBuffer(Bytes[1], Length(Bytes));
      finally
        F.Free;
      end;
    except
      on E: Exception do
        Linea := Linea + ' [ERROR LOG DISCO: ' + E.Message + ']';
    end;
    { La cola es acotada. Los eventos completos quedan en disco. }
    if FPendientes.Count >= 2000 then FPendientes.Delete(0);
    FPendientes.Add(Linea);
  finally
    LeaveCriticalSection(FCritica);
  end;
end;

procedure TRegistroServidor.Extraer(Destino: TStrings);
begin
  EnterCriticalSection(FCritica);
  try
    Destino.Assign(FPendientes);
    FPendientes.Clear;
  finally
    LeaveCriticalSection(FCritica);
  end;
end;

end.

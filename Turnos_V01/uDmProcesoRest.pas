unit uDmProcesoRest;

interface

uses
  Classes, SysUtils, SqlExpr, uSqlServer;

type
  TProcesoRest = class(TSQLFileClass)
  private
    FNUI: Integer;
    FSistemaOrigen: string;
    FTransaccionId: string;
    FOrdenMedicaId: string;
    FVersionTurno: Integer;
    FEmpresa: string;
    FBoleta: Integer;
    FSedeId: string;
    FTerminalId: string;
    FFechaAlta: TDateTime;
    FFechaProcesada: TDateTime;
    FProcesada: Boolean;
    function NuevaConsulta: TSQLQuery;
    procedure CargaRegistro(Qry: TSQLQuery);
  protected
    function CrearTabla: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AseguraTabla;
    procedure Clear;
    procedure Graba(const ASistemaOrigen, ATransaccionId, AOrdenMedicaId: string;
      AVersionTurno: Integer; const AEmpresa: string; ABoleta: Integer;
      const ASedeId, ATerminalId: string);
    function BuscaTransaccion(const ASistemaOrigen, ATransaccionId: string): Boolean;
    function LeePendiente(const ASedeId, ATerminalId: string): Boolean;
    function MarcaProcesada(ANUI: Integer; const ASedeId, ATerminalId: string): Boolean;
    property Existe: Boolean read FExiste;
    property NUI: Integer read FNUI;
    property SistemaOrigen: string read FSistemaOrigen;
    property TransaccionId: string read FTransaccionId;
    property OrdenMedicaId: string read FOrdenMedicaId;
    property VersionTurno: Integer read FVersionTurno;
    property Empresa: string read FEmpresa;
    property Boleta: Integer read FBoleta;
    property SedeId: string read FSedeId;
    property TerminalId: string read FTerminalId;
    property FechaAlta: TDateTime read FFechaAlta;
    property Procesada: Boolean read FProcesada;
    property FechaProcesada: TDateTime read FFechaProcesada;
  end;

  TdmProcesoRest = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FProcesoRest: TProcesoRest;
  public
    property ProcesoRest: TProcesoRest read FProcesoRest;
  end;

var
  dmProcesoRest: TdmProcesoRest;

implementation

{$R *.dfm}

procedure TdmProcesoRest.DataModuleCreate(Sender: TObject);
begin
  FProcesoRest := TProcesoRest.Create(Self);
  FProcesoRest.AseguraTabla;
end;

constructor TProcesoRest.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TableName := 'Procesar_Rest';
end;

function TProcesoRest.NuevaConsulta: TSQLQuery;
begin
  if not ExisteDatosBase then
    raise Exception.Create('Proceso REST: conexion SageLab no inicializada.');
  Result := fDatosBase.CreateQuery;
end;

procedure TProcesoRest.AseguraTabla;
begin
  CrearTabla;
end;

function TProcesoRest.CrearTabla: Boolean;
var
  Qry: TSQLQuery;
begin
  Qry := NuevaConsulta;
  try
    with Qry.SQL do
    begin
      Add('IF OBJECT_ID(N''' + TableName + ''', N''U'') IS NULL');
      Add('BEGIN');
      Add('CREATE TABLE ' + TableName + ' (');
      Add('NUI INT IDENTITY(1,1) NOT NULL PRIMARY KEY,');
      Add('SistemaOrigen VARCHAR(50) NOT NULL,');
      Add('TransaccionId VARCHAR(100) NOT NULL,');
      Add('OrdenMedicaId VARCHAR(100) NOT NULL,');
      Add('VersionTurno INT NOT NULL,');
      Add('Empresa VARCHAR(10) NOT NULL,');
      Add('Boleta INT NOT NULL,');
      Add('SedeId VARCHAR(100) NOT NULL,');
      Add('TerminalId VARCHAR(100) NOT NULL,');
      Add('FechaAlta DATETIME NOT NULL DEFAULT (GETDATE()),');
      Add('Procesada BIT NOT NULL DEFAULT (0),');
      Add('FechaProcesada DATETIME NULL,');
      Add('CONSTRAINT UQ_Procesar_Rest_Transaccion UNIQUE (SistemaOrigen, TransaccionId))');
      Add('CREATE INDEX IX_Procesar_Rest_Puesto ON ' + TableName);
      Add('(SedeId, TerminalId, Procesada, NUI)');
      Add('END');
    end;
    Qry.ExecSQL(True);
    Result := True;
  finally
    Qry.Free;
  end;
end;

procedure TProcesoRest.Clear;
begin
  FExiste := False;
  FNUI := 0;
  FSistemaOrigen := '';
  FTransaccionId := '';
  FOrdenMedicaId := '';
  FVersionTurno := 0;
  FEmpresa := '';
  FBoleta := 0;
  FSedeId := '';
  FTerminalId := '';
  FFechaAlta := 0;
  FProcesada := False;
  FFechaProcesada := 0;
end;

procedure TProcesoRest.CargaRegistro(Qry: TSQLQuery);
begin
  if Qry.Eof then
    Exit;
  FNUI := Qry.FieldByName('NUI').AsInteger;
  FSistemaOrigen := Qry.FieldByName('SistemaOrigen').AsString;
  FTransaccionId := Qry.FieldByName('TransaccionId').AsString;
  FOrdenMedicaId := Qry.FieldByName('OrdenMedicaId').AsString;
  FVersionTurno := Qry.FieldByName('VersionTurno').AsInteger;
  FEmpresa := Qry.FieldByName('Empresa').AsString;
  FBoleta := Qry.FieldByName('Boleta').AsInteger;
  FSedeId := Qry.FieldByName('SedeId').AsString;
  FTerminalId := Qry.FieldByName('TerminalId').AsString;
  FFechaAlta := Qry.FieldByName('FechaAlta').AsDateTime;
  FProcesada := Qry.FieldByName('Procesada').AsBoolean;
  if not Qry.FieldByName('FechaProcesada').IsNull then
    FFechaProcesada := Qry.FieldByName('FechaProcesada').AsDateTime;
  FExiste := True;
end;

procedure TProcesoRest.Graba(const ASistemaOrigen, ATransaccionId,
  AOrdenMedicaId: string; AVersionTurno: Integer; const AEmpresa: string;
  ABoleta: Integer; const ASedeId, ATerminalId: string);
var
  Qry: TSQLQuery;
begin
  Qry := NuevaConsulta;
  try
    Qry.SQL.Add('INSERT INTO ' + TableName);
    Qry.SQL.Add('(SistemaOrigen, TransaccionId, OrdenMedicaId, VersionTurno,');
    Qry.SQL.Add(' Empresa, Boleta, SedeId, TerminalId)');
    Qry.SQL.Add('VALUES (:Origen, :Transaccion, :Orden, :Version,');
    Qry.SQL.Add(' :Empresa, :Boleta, :Sede, :Terminal)');
    Qry.ParamByName('Origen').AsString := ASistemaOrigen;
    Qry.ParamByName('Transaccion').AsString := ATransaccionId;
    Qry.ParamByName('Orden').AsString := AOrdenMedicaId;
    Qry.ParamByName('Version').AsInteger := AVersionTurno;
    Qry.ParamByName('Empresa').AsString := AEmpresa;
    Qry.ParamByName('Boleta').AsInteger := ABoleta;
    Qry.ParamByName('Sede').AsString := ASedeId;
    Qry.ParamByName('Terminal').AsString := ATerminalId;
    Qry.ExecSQL;
  finally
    Qry.Free;
  end;
end;

function TProcesoRest.BuscaTransaccion(const ASistemaOrigen,
  ATransaccionId: string): Boolean;
var
  Qry: TSQLQuery;
begin
  Clear;
  Qry := NuevaConsulta;
  try
    Qry.SQL.Add('SELECT * FROM ' + TableName);
    Qry.SQL.Add('WHERE SistemaOrigen = :Origen AND TransaccionId = :Transaccion');
    Qry.ParamByName('Origen').AsString := ASistemaOrigen;
    Qry.ParamByName('Transaccion').AsString := ATransaccionId;
    Qry.Open;
    CargaRegistro(Qry);
    Result := Existe;
  finally
    Qry.Free;
  end;
end;

function TProcesoRest.LeePendiente(const ASedeId, ATerminalId: string): Boolean;
var
  Qry: TSQLQuery;
begin
  Clear;
  Qry := NuevaConsulta;
  try
    Qry.SQL.Add('SELECT TOP 1 * FROM ' + TableName);
    Qry.SQL.Add('WHERE SedeId = :Sede AND TerminalId = :Terminal AND Procesada = 0');
    Qry.SQL.Add('ORDER BY NUI');
    Qry.ParamByName('Sede').AsString := ASedeId;
    Qry.ParamByName('Terminal').AsString := ATerminalId;
    Qry.Open;
    CargaRegistro(Qry);
    Result := Existe;
  finally
    Qry.Free;
  end;
end;

function TProcesoRest.MarcaProcesada(ANUI: Integer;
  const ASedeId, ATerminalId: string): Boolean;
var
  Qry: TSQLQuery;
begin
  Qry := NuevaConsulta;
  try
    Qry.SQL.Add('UPDATE ' + TableName);
    Qry.SQL.Add('SET Procesada = 1, FechaProcesada = GETDATE()');
    Qry.SQL.Add('WHERE NUI = :NUI AND SedeId = :Sede');
    Qry.SQL.Add('AND TerminalId = :Terminal AND Procesada = 0');
    Qry.ParamByName('NUI').AsInteger := ANUI;
    Qry.ParamByName('Sede').AsString := ASedeId;
    Qry.ParamByName('Terminal').AsString := ATerminalId;
    Result := Qry.ExecSQL = 1;
  finally
    Qry.Free;
  end;
end;

end.

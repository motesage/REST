unit uServidor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uRegistroServidor, uRecepciones, IniFiles, IdException,
  IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdCustomHTTPServer, IdHTTPServer, IdTCPServer, IdContext;

type
  TfrmServer = class(TForm)
    IdHTTPServer1: TIdHTTPServer;
    MemoLog: TMemo;
    btnIniciar: TButton;
    btnDetener: TButton;
    procedure btnIniciarClick(Sender: TObject);
    procedure btnDetenerClick(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FRegistro: TRegistroServidor;
    FRecepciones: TRecepciones;
    FTokenMonitor: string;
    FTimer: TTimer;
    FSequencia: Integer;
    procedure ConsultarRecepciones(ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure ActualizarLog(Sender: TObject);
    procedure Conectado(AContext: TIdContext);
    procedure Desconectado(AContext: TIdContext);
    procedure ErrorConexion(AContext: TIdContext; AException: Exception);
    function Origen(AContext: TIdContext): string;
    function LeerPostStream(AStream: TStream): string;
    function GuardarMensajeRecibido(const CuerpoJSON, Carpeta, Prefijo: string): string;
    procedure ProcesarPaciente(
      const CuerpoJSON: string;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure ProcesarOrden(
      const CuerpoJSON: string;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure ProcesarTurno(
      const CuerpoJSON: string;
      AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmServer: TfrmServer;

implementation

uses ExceptionLog;

{$R *.dfm}

constructor TfrmServer.Create(AOwner: TComponent);
var
  Config: TIniFile;
begin
  inherited Create(AOwner);
  FRegistro := TRegistroServidor.Create(ExtractFilePath(Application.ExeName));
  FRecepciones := TRecepciones.Create(ExtractFilePath(Application.ExeName));
  Config := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    FTokenMonitor := Trim(Config.ReadString('Monitor', 'Token', ''));
  finally
    Config.Free;
  end;
  if Length(FTokenMonitor) < 32 then
  begin
    FTokenMonitor := '';
    FRegistro.Anotar('MONITOR deshabilitado: configurar Token de al menos 32 caracteres en ServidorRest.ini');
  end;
  if IsEurekaLogActive then
    FRegistro.Anotar('EUREKALOG activo; filtros de desconexion y comando HTTP invalido instalados')
  else
    FRegistro.Anotar('AVISO EurekaLog no activo en este ejecutable');
  IdHTTPServer1.OnConnect := Conectado;
  IdHTTPServer1.OnDisconnect := Desconectado;
  IdHTTPServer1.OnException := ErrorConexion;
  IdHTTPServer1.OnCommandOther := IdHTTPServer1CommandGet;
  FTimer := TTimer.Create(Self);
  FTimer.Interval := 250;
  FTimer.OnTimer := ActualizarLog;
end;

destructor TfrmServer.Destroy;
begin
  FTimer.Free;
  { Detener y esperar a los hilos antes de liberar el registro. }
  if Assigned(IdHTTPServer1) then IdHTTPServer1.Active := False;
  FRecepciones.Free;
  FRegistro.Free;
  inherited Destroy;
end;

procedure TfrmServer.ActualizarLog(Sender: TObject);
var
  Pendientes: TStringList;
begin
  Pendientes := TStringList.Create;
  try
    FRegistro.Extraer(Pendientes);
    MemoLog.Lines.BeginUpdate;
    try
      MemoLog.Lines.AddStrings(Pendientes);
      while MemoLog.Lines.Count > 1000 do MemoLog.Lines.Delete(0);
    finally
      MemoLog.Lines.EndUpdate;
    end;
  finally
    Pendientes.Free;
  end;
end;

function TfrmServer.Origen(AContext: TIdContext): string;
begin
  Result := 'origen=desconocido';
  if Assigned(AContext.Binding) then
    Result := 'origen=' + AContext.Binding.PeerIP + ':' +
      IntToStr(AContext.Binding.PeerPort);
end;

procedure TfrmServer.Conectado(AContext: TIdContext);
begin
  FRegistro.Anotar('CONEXION ' + Origen(AContext));
end;

procedure TfrmServer.Desconectado(AContext: TIdContext);
begin
  FRegistro.Anotar('DESCONEXION ' + Origen(AContext));
end;

procedure TfrmServer.ErrorConexion(AContext: TIdContext; AException: Exception);
var
  Tipo: string;
begin
  if AException is EIdConnClosedGracefully then
    Tipo := 'CIERRE_REMOTO'
  else if AException is EIdHTTPErrorParsingCommand then
    Tipo := 'SOLICITUD_DESCARTADA'
  else
    Tipo := 'ERROR_CONEXION';
  FRegistro.Anotar(Tipo + ' ' + Origen(AContext) + ' ' +
    AException.ClassName + ': ' + AException.Message);
end;

procedure TFrmServer.BtnIniciarClick(Sender: TObject);
begin
  if IdHTTPServer1.Active then Exit;
  try
    IdHTTPServer1.DefaultPort := 8081;
    IdHTTPServer1.Active := True;
    FRegistro.Anotar('INICIO puerto=8081; /api/lis/turnos y /api/lis/ordenes confirman RECEPCION, sin alta SQL');
  except
    on E: Exception do
      FRegistro.Anotar('ERROR_INICIO ' + E.ClassName + ': ' + E.Message);
  end;
  btnIniciar.Enabled := not IdHTTPServer1.Active;
  btnDetener.Enabled := IdHTTPServer1.Active;
end;

procedure TfrmServer.btnDetenerClick(Sender: TObject);
begin
  try
    IdHTTPServer1.Active := False;
    FRegistro.Anotar('DETENIDO');
  except
    on E: Exception do
      FRegistro.Anotar('ERROR_DETENCION ' + E.ClassName + ': ' + E.Message);
  end;
  btnIniciar.Enabled := not IdHTTPServer1.Active;
  btnDetener.Enabled := IdHTTPServer1.Active;
end;

function TFrmServer.LeerPostStream(AStream: TStream): string;
var
  L: Integer;
begin
  Result := '';

  if not Assigned(AStream) then
    Exit;

  AStream.Position := 0;
  L := AStream.Size;

  if L <= 0 then
    Exit;

  SetLength(Result, L);
  AStream.ReadBuffer(Result[1], L);
end;

procedure TFrmServer.IdHTTPServer1CommandGet(
  AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  CuerpoJSON: string;
  Pedido: string;
begin
  Pedido := IntToStr(InterlockedIncrement(FSequencia));
  FRegistro.Anotar('SOLICITUD id=' + Pedido + ' hilo=' + IntToStr(GetCurrentThreadId) + ' ' + Origen(AContext) + ' ' +
    ARequestInfo.Command + ' ' + ARequestInfo.Document);
  try
    CuerpoJSON := '';

    try
      { Configuracion comun de todas las respuestas }
      AResponseInfo.ContentType := 'application/json';
      AResponseInfo.CharSet := 'utf-8';

      if SameText(ARequestInfo.Document, '/api/lis/recepciones') then
      begin
        ConsultarRecepciones(ARequestInfo, AResponseInfo);
        Exit;
      end;

      { Para estos endpoints solamente aceptamos POST }
      if not SameText(ARequestInfo.Command, 'POST') then
      begin
        AResponseInfo.ResponseNo := 405;
        AResponseInfo.ContentText :=
          '{"ok":false,' +
          '"codigo":"METODO_NO_PERMITIDO",' +
          '"mensaje":"Este endpoint solamente admite solicitudes POST"}';
        Exit;
      end;

      { Leemos el JSON enviado en el cuerpo de la solicitud }
      CuerpoJSON := LeerPostStream(ARequestInfo.PostStream);
      FRegistro.Anotar('CUERPO id=' + Pedido + ' bytes=' + IntToStr(Length(CuerpoJSON)));

      { Enrutamiento }
      if SameText(ARequestInfo.Document, '/api/lis/paciente') then
        ProcesarPaciente(CuerpoJSON, AResponseInfo)

      else if SameText(ARequestInfo.Document, '/api/lis/ordenes') then
        ProcesarOrden(CuerpoJSON, AResponseInfo)

      else if SameText(ARequestInfo.Document, '/api/lis/turnos') then
        ProcesarTurno(CuerpoJSON, AResponseInfo)

      else
      begin
        AResponseInfo.ResponseNo := 404;
        AResponseInfo.ContentText :=
          '{"ok":false,' +
          '"codigo":"ENDPOINT_INEXISTENTE",' +
          '"mensaje":"El endpoint solicitado no existe"}';
      end;

    except
      on E: Exception do
      begin
        FRegistro.Anotar('ERROR_SOLICITUD id=' + Pedido + ' ' + E.ClassName + ': ' + E.Message);
        AResponseInfo.ResponseNo := 500;
        AResponseInfo.ContentType := 'application/json';
        AResponseInfo.CharSet := 'utf-8';
        AResponseInfo.ContentText :=
          '{"ok":false,' +
          '"codigo":"ERROR_INTERNO",' +
          '"mensaje":"Error interno del servidor"}';
      end;
    end;
  finally
    FRegistro.Anotar('RESPUESTA_PREPARADA id=' + Pedido + ' HTTP=' +
      IntToStr(AResponseInfo.ResponseNo) + ' (no confirma entrega al cliente)');
  end;
end;

procedure TfrmServer.ConsultarRecepciones(
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.CustomHeaders.Values['Cache-Control'] := 'no-store';
  if FTokenMonitor = '' then
  begin
    AResponseInfo.ResponseNo := 503;
    AResponseInfo.ContentText := '{"ok":false,"codigo":"MONITOR_NO_CONFIGURADO"}';
    Exit;
  end;
  if ARequestInfo.RawHeaders.Values['X-SAGE-Monitor-Key'] <> FTokenMonitor then
  begin
    AResponseInfo.ResponseNo := 401;
    AResponseInfo.ContentText := '{"ok":false,"codigo":"NO_AUTORIZADO"}';
    Exit;
  end;
  if not SameText(ARequestInfo.Command, 'GET') then
  begin
    AResponseInfo.ResponseNo := 405;
    AResponseInfo.ContentText := '{"ok":false,"codigo":"METODO_NO_PERMITIDO"}';
    Exit;
  end;
  try
    AResponseInfo.ContentText := FRecepciones.Consultar(ARequestInfo.Params.Values['desde']);
    AResponseInfo.ResponseNo := 200;
  except
    on E: EConvertError do
    begin
      AResponseInfo.ResponseNo := 409;
      AResponseInfo.ContentText := '{"ok":false,"codigo":"CURSOR_INVALIDO"}';
    end;
  end;
end;

procedure TFrmServer.ProcesarPaciente(
  const CuerpoJSON: string;
  AResponseInfo: TIdHTTPResponseInfo);
begin
  AResponseInfo.ResponseNo := 201;
  AResponseInfo.ContentText :=
    '{"ok":true,' +
    '"mensaje":"Paciente recibido correctamente"}';
end;

procedure TFrmServer.ProcesarOrden(
  const CuerpoJSON: string;
  AResponseInfo: TIdHTTPResponseInfo);
begin
  if Trim(CuerpoJSON) = '' then
  begin
    AResponseInfo.ResponseNo := 400;
    AResponseInfo.ContentText :=
      '{"ok":false,' +
      '"codigo":"JSON_VACIO",' +
      '"mensaje":"El cuerpo JSON esta vacio"}';
    Exit;
  end;

  { Recepcion RAW de ordenes: sin interpretar el contenido ni generar
    protocolos, boletas o altas en la base de datos del LIS. }
  FRegistro.Anotar('RAW_GUARDADO hilo=' + IntToStr(GetCurrentThreadId) +
    ' archivo=' + GuardarMensajeRecibido(CuerpoJSON, 'Ordenes', 'Orden'));

  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentText :=
    '{"ok":true,' +
    '"mensaje":"Orden recibida correctamente por SAGE",' +
    '"estado":"RECIBIDO"}';
end;

function TFrmServer.GuardarMensajeRecibido(
  const CuerpoJSON, Carpeta, Prefijo: string): string;
var
  Ruta: string;
  NombreArchivo: string;
  F: TFileStream;
  Identificador: TGUID;
begin
  Ruta := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
          'Logs' + PathDelim + Carpeta + PathDelim;

  if not ForceDirectories(Ruta) then
    raise Exception.Create('No se pudo crear ' + Ruta);

  if CreateGUID(Identificador) <> 0 then
    raise Exception.Create('No se pudo generar identificador del archivo');
  NombreArchivo := Ruta + Prefijo + '_' +
    FormatDateTime('yyyymmdd_hhnnss_zzz', Now) + '_' +
    Copy(GUIDToString(Identificador), 2, 36) + '.json';

  F := TFileStream.Create(NombreArchivo + '.part', fmCreate);
  try
    if Length(CuerpoJSON) > 0 then
      F.WriteBuffer(CuerpoJSON[1], Length(CuerpoJSON));
  finally
    F.Free;
  end;
  { Publicar solo un RAW cerrado correctamente. Las consultas ignoran .part. }
  if not MoveFileEx(PChar(NombreArchivo + '.part'), PChar(NombreArchivo),
    MOVEFILE_WRITE_THROUGH) then RaiseLastOSError;
  Result := NombreArchivo;
end;

procedure TFrmServer.ProcesarTurno(
  const CuerpoJSON: string;
  AResponseInfo: TIdHTTPResponseInfo);
begin
  if Trim(CuerpoJSON) = '' then
  begin
    AResponseInfo.ResponseNo := 400;
    AResponseInfo.ContentText :=
      '{"ok":false,' +
      '"codigo":"JSON_VACIO",' +
      '"mensaje":"El cuerpo JSON esta vacio"}';
    Exit;
  end;

  { En esta primera etapa no interpretamos ni grabamos el turno en SageLab.
    Guardamos exactamente el payload recibido para validar la integracion
    Markey -> SAGE sin afectar la base de datos. }
  FRegistro.Anotar('RAW_GUARDADO hilo=' + IntToStr(GetCurrentThreadId) +
    ' archivo=' + GuardarMensajeRecibido(CuerpoJSON, 'Turnos', 'Turno'));

  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentText :=
    '{"ok":true,' +
    '"mensaje":"Turno recibido correctamente por SAGE",' +
    '"estado":"RECIBIDO"}';
end;

procedure TfrmServer.FormShow(Sender: TObject);
begin
  btnIniciarClick(self);
end;

procedure TfrmServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  btnDetenerClick(self);
end;

end.

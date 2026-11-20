unit uServidor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
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
    function LeerPostStream(AStream: TStream): string;
    procedure GuardarTurnoRecibido(const CuerpoJSON: string);
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
    { Public declarations }
  end;

var
  frmServer: TfrmServer;

implementation

{$R *.dfm}

procedure TFrmServer.BtnIniciarClick(Sender: TObject);
begin
  IdHTTPServer1.DefaultPort := 8081;
  IdHTTPServer1.Active := True;
  MemoLog.Lines.Add('Servidor iniciado en el puerto 8081');
  MemoLog.Lines.Add('POST /api/lis/paciente');
  MemoLog.Lines.Add('POST /api/lis/ordenes');
  MemoLog.Lines.Add('POST /api/lis/turnos');
end;

procedure TfrmServer.btnDetenerClick(Sender: TObject);
begin
  IdHTTPServer1.Active := False;
  MemoLog.Lines.Add('Servidor detenido');
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
begin
  CuerpoJSON := '';

  try
    { Configuracion comun de todas las respuestas }
    AResponseInfo.ContentType := 'application/json';
    AResponseInfo.CharSet := 'utf-8';

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
      AResponseInfo.ResponseNo := 500;
      AResponseInfo.ContentType := 'application/json';
      AResponseInfo.CharSet := 'utf-8';
      AResponseInfo.ContentText :=
        '{"ok":false,' +
        '"codigo":"ERROR_INTERNO",' +
        '"mensaje":"Error interno del servidor"}';
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
  AResponseInfo.ResponseNo := 201;
  AResponseInfo.ContentText :=
    '{"ok":true,' +
    '"mensaje":"Orden recibida correctamente",' +
    '"protocoloSageLab":"PRUEBA-000001"}';
end;

procedure TFrmServer.GuardarTurnoRecibido(const CuerpoJSON: string);
var
  Ruta: string;
  NombreArchivo: string;
  F: TFileStream;
begin
  Ruta := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
          'Logs' + PathDelim + 'Turnos' + PathDelim;

  ForceDirectories(Ruta);

  NombreArchivo := Ruta + 'Turno_' +
    FormatDateTime('yyyymmdd_hhnnss_zzz', Now) + '.json';

  F := TFileStream.Create(NombreArchivo, fmCreate);
  try
    if Length(CuerpoJSON) > 0 then
      F.WriteBuffer(CuerpoJSON[1], Length(CuerpoJSON));
  finally
    F.Free;
  end;
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
  GuardarTurnoRecibido(CuerpoJSON);

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

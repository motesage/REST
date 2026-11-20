unit uServidor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdCustomHTTPServer, IdHTTPServer, IdTCPServer,IdContext ;

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
  private
    procedure ProcesarPaciente(
      const CuerpoJSON: string;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure ProcesarOrden(
      const CuerpoJSON: string;
      AResponseInfo: TIdHTTPResponseInfo);    { Private declarations }
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
end;

procedure TfrmServer.btnDetenerClick(Sender: TObject);
begin
  IdHTTPServer1.Active := False;
  MemoLog.Lines.Add('Servidor detenido');
end;

procedure TFrmServer.IdHTTPServer1CommandGet(
  AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo;
  AResponseInfo: TIdHTTPResponseInfo);
var
  CuerpoJSON: string;
  StreamAux: TStringStream;
begin
  CuerpoJSON := '';

  try
    { Configuración común de todas las respuestas }
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
    if Assigned(ARequestInfo.PostStream) then
    begin
      ARequestInfo.PostStream.Position := 0;

      StreamAux := TStringStream.Create('');
      try
        StreamAux.CopyFrom(ARequestInfo.PostStream, 0);
        CuerpoJSON := StreamAux.DataString;
      finally
        StreamAux.Free;
      end;
    end;

    { Enrutamiento }
    if SameText(ARequestInfo.Document, '/api/lis/paciente') then
      ProcesarPaciente(CuerpoJSON, AResponseInfo)

    else if SameText(ARequestInfo.Document, '/api/lis/ordenes') then
      ProcesarOrden(CuerpoJSON, AResponseInfo)

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
        '"mensaje":"' + E.Message + '"}';
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

end.

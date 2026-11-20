unit uCliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP;

type
  TfrmCliente = class(TForm)
    MemoRespuesta: TMemo;
    MemoJson: TMemo;
    btnEnviar: TButton;
    IdHTTP1: TIdHTTP;
    edtURL: TEdit;
    Label1: TLabel;
    procedure btnEnviarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCliente: TfrmCliente;

implementation

{$R *.dfm}

procedure TFrmCliente.BtnEnviarClick(Sender: TObject);
var
  Peticion: TStringStream;
  Respuesta: TStringStream;
  URL: string;
begin
  URL := edtURL.Text;

  // http://127.0.0.1:8081/api/lis/paciente
  // http://127.0.0.1:8081/api/lis/ordenes
  // http://127.0.0.1:8081/api/lis/turnos
  // http://127.0.0.1:8081/api/lis/inexistente

  Peticion := TStringStream.Create(MemoJson.Text);
  Respuesta := TStringStream.Create('');

  try
    IdHTTP1.Request.ContentType := 'application/json';
    IdHTTP1.Request.CharSet := 'utf-8';

    try
      IdHTTP1.Post(URL, Peticion, Respuesta);

      MemoRespuesta.Lines.Text := Respuesta.DataString;
    except
      on E: Exception do
        MemoRespuesta.Lines.Text :=
          'Error enviando solicitud: ' + E.Message;
    end;
  finally
    Respuesta.Free;
    Peticion.Free;
  end;
end;

end.

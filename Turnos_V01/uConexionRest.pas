unit uConexionRest;

interface

uses
  Classes;

procedure IniciarConexionRest(AOwner: TComponent);

implementation

uses
  SysUtils, IniFiles, JvJCLUtils, udmCentral, uSqlServer, uMain;

procedure IniciarConexionRest(AOwner: TComponent);
var
  ArchivoIni: string;
  ArchivoEfectivo: string;
  Ini: TIniFile;
begin
  ArchivoIni := AppPath + 'SQLDir.ini';
  ArchivoEfectivo := AppPath + GetComputerName + '_sqlDir.Conf';
  if not FileExists(ArchivoEfectivo) then
    ArchivoEfectivo := ArchivoIni;

  if not FileExists(ArchivoEfectivo) then
    raise Exception.Create('No se encontro la configuracion SQL: ' + ArchivoEfectivo);

  { Evita que el constructor del LIS use valores de respaldo si faltan claves. }
  Ini := TIniFile.Create(ArchivoEfectivo);
  try
    if (Trim(Ini.ReadString('SQLSERVER', 'server', '')) = '') or
       (Trim(Ini.ReadString('SQLSERVER', 'database', '')) = '') or
       (Trim(Ini.ReadString('SQLSERVER', 'user', '')) = '') or
       not Ini.ValueExists('SQLSERVER', 'password') then
      raise Exception.Create('Configuracion SQL incompleta en: ' + ArchivoEfectivo);
  finally
    Ini.Free;
  end;

  BaseConn := TDatosBaseSQL.Create(AOwner, '', '', '', '', ArchivoIni);
  try
    BaseConn.Active := True;
    { Abre la base configurada, con la misma conexion dbExpress que usa LAB. }
    if not BaseConn.ConexionBase.Connected then
      raise Exception.Create('Conexion SQL inactiva.');
  except
    FreeAndNil(BaseConn);
    raise Exception.Create('No se pudo abrir la base configurada en: ' + ArchivoEfectivo);
  end;

  BaseVersiones := TVersionTabla.CreateWithConnection(AOwner, BaseConn);
  ConectoBaseOK := True;
end;

end.

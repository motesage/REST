# SAGE REST V0.5 - Consulta de recepciones y monitor desde tu PC

Fecha: 04/11/2026.

## 1. Instalar en la clinica

1. Cerrar ServidorRest y conservar el ejecutable anterior.
2. Copiar juntos `entrega_v05\ServidorRest.exe` y `entrega_v05\ServidorRest.ini` a la carpeta del servidor instalado. Conservar su carpeta `Logs` existente.
3. Iniciar el servidor: la ventana debe indicar V0.5. El puerto sigue siendo 8081.

El INI contiene una clave aleatoria de consulta, emparejada con la configuracion del monitor. No compartir estos archivos con Markey ni agregar la clave a una URL. Sin token de al menos 32 caracteres, la consulta devuelve 503; Turnos y Ordenes siguen disponibles.

No se modificaron reglas de red. La consulta usa el mismo servidor/puerto publicado. La clave viaja en un encabezado; con la URL HTTP actual el transporte no esta cifrado. Puede utilizarse HTTPS si Sistemas publica ese acceso; cambiar entonces la URL del monitor.

## 2. Iniciar en tu PC

1. Mantener juntos los tres archivos de `monitor_recepciones`: `IniciarMonitor.cmd`, `MonitorRecepciones.ps1` y `MonitorRecepciones.json`.
2. Ejecutar `IniciarMonitor.cmd`. Usa Windows PowerShell 5.1, incluido en Windows; no requiere Python ni instalar bibliotecas.
3. Dejar la consola abierta, si se desea minimizada. Ctrl+C finaliza el monitor.

La URL configurada es `http://200.41.170.126:8081/api/lis/recepciones` y el intervalo es 60 segundos. Ambos pueden modificarse en `MonitorRecepciones.json`. La consulta tiene timeout de 15 segundos. El intervalo se cuenta desde que finaliza cada ronda; no es un servicio instalado ni se inicia automaticamente con Windows.

La primera consulta correcta guarda el punto de partida sin avisar sobre recepciones anteriores. Conviene ejecutar el monitor ANTES de las pruebas o de esperar nuevos envios. A partir de ese momento, cada RAW nuevo genera un mensaje verde en consola, sonido y un aviso de bandeja si Windows lo permite. Si Windows silencia los avisos, permanece el historial local.

Para verificar una sola vez, sin sonido ni bandeja:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\MonitorRecepciones.ps1 -UnaVez -SinAviso
```

No se configuro envio de emails. El historial local permite agregar ese mecanismo mas adelante desde tu PC.

## 3. Prueba operativa recomendada

1. Instalar V0.5 en la clinica e iniciar el monitor en tu PC.
2. Esperar el mensaje de punto de partida guardado y consulta correcta.
3. Enviar un Turno y una Orden desde el cliente.
4. Esperar la siguiente consulta: deben aparecer dos avisos, uno TURNO y otro ORDEN.
5. Cerrar y volver a abrir el monitor: esos avisos no deben repetirse.
6. Opcional: con el monitor cerrado, enviar otro RAW y volver a abrirlo; debe recuperar esa novedad.

## 4. Historial y continuidad

El monitor crea `EstadoMonitor` junto a su configuracion:

- `estado.json`: URL, instancia del registro y ultimo identificador consultado.
- `Avisos\*.pendiente.json`: notificaciones por emitir.
- `Avisos\*.notificado.json`: historial de avisos emitidos.
- `estado.json.bak`: estado anterior como respaldo.
- `monitor.lock`: impide dos monitores simultaneos sobre la misma carpeta.

Conservar esta carpeta para continuar el seguimiento. No borrarla para resolver un error de conexion: borrarla hace que el siguiente inicio tome un nuevo punto de partida y omita el historial anterior.

Los eventos se guardan localmente antes de avanzar el cursor y emitir avisos. Una interrupcion exactamente durante la emision puede repetir un aviso; su identificador permanece estable. En el funcionamiento normal no se renotifican los eventos ya registrados. Un reenvio que genera otro archivo RAW cuenta como otra recepcion.

Sin conexion, la consola informa error y vuelve a intentar. Al recuperarse, consulta las recepciones pendientes mientras el registro y los RAW se conserven en el servidor. No confunde error de consulta con ausencia de novedades. Si cambia la instancia del registro o el cursor es invalido, no reinicia el seguimiento silenciosamente: requiere revision.

## 5. Registro en el servidor

La consulta enumera los RAW completos de `Logs\Turnos` y `Logs\Ordenes` y mantiene `Logs\Recepciones.idx`. Conservar este indice durante reemplazos del EXE y respaldos: contiene la instancia y la secuencia estable de identificadores. No editarlo ni borrarlo durante el seguimiento.

Los RAW se escriben primero con extension `.json.part` y se publican como `.json` despues de completar y cerrar la escritura. Las consultas ignoran `.part`, archivos vacios y nombres ajenos al formato del receptor. Un fallo de escritura no genera una novedad exitosa. Los archivos incompletos pueden conservarse para diagnostico.

El indice se actualiza bajo exclusion mutua y reemplazo atomico; las recepciones se recuperan a partir de archivos completos aunque el servidor reinicie antes de la proxima consulta. Los RAW antiguos de V0.4 tambien se incorporan. Los IDs expresan orden de incorporacion al indice, no necesariamente orden cronologico entre ambos tipos de mensajes.

Este mecanismo esta previsto para la etapa actual de pruebas y bajo volumen. Consulta nombres de archivos y persiste el indice cuando encuentra novedades; no lee ni analiza el contenido clinico. No eliminar ni mover RAW nuevos antes de que el monitor los haya consultado.

## 6. Endpoint

`GET /api/lis/recepciones`

Encabezado obligatorio: `X-SAGE-Monitor-Key: <clave configurada>`.

Sin `desde`: establece punto de partida; devuelve cursor actual y lista vacia.
Con `?desde=N`: devuelve hasta 100 recepciones posteriores a N. Para continuar se usa `siguienteId`; `hayMas` indica paginas adicionales. `desde=0` permite recuperar el historial indexado completo.

```json
{
  "ok": true,
  "instancia": "identificador-estable-del-registro",
  "ultimoId": 2,
  "siguienteId": 2,
  "hayMas": false,
  "recepciones": [
    {
      "id": 2,
      "tipo": "ORDEN",
      "fechaHoraLocal": "2026-11-04T12:30:00.123",
      "archivo": "Orden_20261104_123000_123_GUID.json"
    }
  ]
}
```

La fecha corresponde al reloj local del servidor y se obtiene del nombre generado al guardar. No se transmiten contenido del JSON, identificadores de pacientes ni rutas completas.

Respuestas: 200 consulta correcta; 401 clave ausente/incorrecta; 405 metodo distinto de GET con clave correcta; 409 cursor invalido; 503 monitor sin configurar; 500 fallo interno/de acceso al registro. Se indica `Cache-Control: no-store`. El token nunca se registra en el log.

## 7. Recepcion de Turnos y Ordenes

Se mantienen los POST de V0.4 y sus respuestas genericas. HTTP 200 confirma RAW guardado; no confirma validez JSON, alta SQL, impresion ni aceptacion funcional del LIS. El monitor es independiente de la interpretacion y del futuro procesamiento.

Compilacion con Delphi 7 / EurekaLog. Fuentes: `uServidor.pas`, `uServidor.dfm`, `uRecepciones.pas`. Respaldo previo: `backup_antes_v05`. Pruebas locales: `build_v05\verificar_servidor.py`. La entrega no modifica el EXE instalado en la clinica ni inicia el monitor contra el servidor real.

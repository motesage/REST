# Bitácora de integración Markey / HIS ↔ SageLab / LIS

Registro local de intercambios aportados por Marcelo. Las transcripciones no se verificaron directamente en WhatsApp. Fechas y horas referidas a Argentina; se indican las que no fueron informadas. Este archivo no modifica documentos compartidos ni envía mensajes.

## 22/09/2026 — Conformidad comunicada por WhatsApp

Hora informada: 16:55, ambos mensajes. Nombre y rol del emisor no confirmados.

Transcripción aportada:

> En realidad está todo aceptado salvo por la  fecha entrega que no o tenemos aún implementada así que eso debería ser fase 2
>
> Y lo de muestra

Lectura de trabajo, no acuerdo adicional: expresa aceptación general sin identificar versión documental. Propone fecha de entrega para fase 2. El alcance de la excepción sobre muestra queda ambiguo. No consta aquí aceptación del laboratorio a esas postergaciones ni fecha de primer envío. Marcelo informa que el único aporte adicional fue el JSON de Turnos ya utilizado en las pruebas.

## 07/10/2026 — Solicitud de respuesta previa a reunión del laboratorio

Fecha contextual: el mensaje anuncia la reunión de mañana jueves 8/10/2026. Hora de envío no informada. Autor: Marcelo. Canal informado: grupo de WhatsApp de nueve participantes, siete de Markey, uno de Sistemas de la clínica y Marcelo.

Transcripción aportada por Marcelo como mensaje enviado:

> Estimados.
> Buenos días.
> Les informo que mañana jueves 8 por la mañana tenemos una reunión con la dirección y la coordinación técnica del laboratorio para analizar los avances de la integración, y no contamos aun con una respuesta respecto al envío de turnos.
> Para nosotros este paso es fundamental para:
> 1. confirmar que el servicio funciona (recibe los datos y responde en forma correcta)
> 2. analizar el contenido, para determinar si cuenta con los datos necesarios para generar de nuestro lado la orden, imprimir el talón de recepción y las etiquetas, y poder hacer los pedidos de ajustes necesarios.
> Independientemente de esto, sería importante contar con un cronograma de pasos para la integración, ya que de nuestro lado respondemos en forma agil pero contamos con recursos limitados.
>
> Desde ya agradezco respuesta a este mensaje, y si no es este el canal adecuado, que me informen por donde debo gestionarlo.

### Pendientes expresados

- Respuesta sobre el envío de turnos desde Markey, con el contexto de la reunión del 8/10 por la mañana.
- Validar recepción y respuesta del servicio mediante el envío del HIS.
- Evaluar suficiencia del contenido para la futura creación de orden, talón y etiquetas; solicitar ajustes si corresponde.
- Contar con un cronograma de pasos de integración considerando la disponibilidad de recursos de SAGE.
- Confirmar el canal de gestión si el grupo no es el adecuado.

Estado al incorporar este mensaje: no se ha aportado una respuesta posterior de Markey. El mensaje no establece una hora límite explícita ni acredita recepción o lectura individual de los participantes.

## Contexto técnico para la reunión

Según las pruebas previas y lo informado por Marcelo, el receptor V0.3 funciona, se verificó desde la red interna y desde una conexión externa y ya no presenta los errores conocidos por comandos ajenos al protocolo. Al 07/10 Marcelo informa que no recibió turnos de Markey.

HTTP 200 / RECIBIDO confirma recepción y guardado del cuerpo; no implica alta de una orden en SageLab. Parseo funcional, validación, persistencia SQL, talón y etiquetas no forman parte de la recepción actualmente implementada.

La revisión de Drive del 07/10 está documentada en Revision_Drive_Markey_20261007.md. Debe leerse junto con estos intercambios: la aceptación del 22/09 ocurrió fuera de Drive.

## 04/11/2026 - Monitor de recepciones RAW (V0.5)

Se implemento GET /api/lis/recepciones con clave de consulta en encabezado,
indice persistente de recepciones, cursor y paginacion de 100 eventos.
Devuelve exclusivamente tipo, fecha local, ID y nombre de archivo RAW.
Los POST conservan el comportamiento de recepcion sin interpretacion ni SQL;
el RAW se publica despues de completar la escritura mediante .part y renombrado.

Se preparo un monitor PowerShell para la PC externa, con intervalo de 60 segundos,
punto de partida sin historial, estado y avisos persistentes, consola/sonido/bandeja,
recuperacion tras reinicios y diferenciacion entre error de conexion y sin novedades.
No se configuro correo ni inicio automatico con Windows.

Entrega en entrega_v05; instrucciones en LEEME_v05.md.
Clave de servidor y monitor emparejada, no incluida en esta bitacora.
Pruebas locales con EurekaLog activo: recepcion de ambos tipos, RAW exacto,
concurrencia, errores de escritura, consulta protegida, paginacion de 105 novedades,
monitor PowerShell sin duplicacion normal, reinicio del servidor, recuperacion,
y conservacion del cursor ante desconexion, cambio de instancia o fallo del indice.
Se conservaron los filtros de conexiones y comandos invalidos.
Pendiente instalar V0.5 en clinica e iniciar el monitor en la PC del usuario.
No se realizaron consultas ni cambios al servidor real.

## 19/11/2026 - Preparación de la integración funcional

Markey informó que revisará lo solicitado y dará explicaciones o correcciones.
La especificación SAGE sigue como base de trabajo. Pendientes los ejemplos corregidos
y la confirmación técnica de cardinalidad y unicidad de ordenMedicaId. La propuesta
SAGE es usarlo como referencia estable de la orden, conservando identificador para
el Turno y transaccionId para el mensaje. Resolver el caso de reprogramación.

SageLabWin está en C:\DelphiWork\SageLabWin y usa dbExpress Devart con MSSQL.
Revisión estática de uBoletasV2, uDmCabezales y udmLocks: el formulario llama a
CabezalActual.Graba y coordina numeración, paciente, caja, auditoría e impresión.
Usa MarcaBoleta al abrir una boleta existente y claves Boleta0 o Boleta<número>
al grabar. BeginTransaction puede devolver False y el formulario no comprueba ese
retorno. GrabaPacPantalla corre antes del inicio de esa transacción.

Markey usa los códigos Sage de prácticas. Las homologaciones residirán en bases
SAGE accesibles al servidor. Se prevé que el REST pueda actualizar pacientes,
médicos e instituciones identificados. Pendientes los campos permitidos, las
reglas de identidad y si el REST también podrá dar de alta esos maestros.

Punto de retomada:
1. Observar un alta manual en base de prueba con paciente existente, numeración
   automática y varias prácticas. Definir empresa y ámbito y verificar caja,
   bonos, fechas, límites de la transacción y comportamiento de udmLocks
   al abrir la misma boleta desde un segundo puesto.
2. En paralelo, preparar el validador con datos sintéticos. Distinguir JSON o
   campo obligatorio inválido (400), código desconocido (422), conflicto (409),
   indisponibilidad (503) y operación aplicada o reintento idéntico (200).
   Probar la distinción entre o105 y O105.
3. Diseñar grabación sin interfaz, reutilizando la lógica del LIS. Dejar abierta
   la decisión de alojarla en el REST o en otro EXE. Verificar si boleta,
   vinculación, registro del reintento y tarea de terminal pueden confirmarse
   juntos en MSSQL.
4. Precisar el alcance del EXE liviano dirigido por sedeId y terminalId.
   Pendientes la validación final, el ajuste de fechas, las correcciones
   permitidas y el tratamiento de observaciones posteriores al 200. Se propuso
   una cola persistente para revisión, talones y etiquetas.

Estado al pausar: revisión estática completada. El alta observada y los cambios
de código quedan pendientes.

## 20/11/2026 - Definiciones para la prueba de concepto

Piloto AMBULATORIO, empresa 2 de LAB.EXE, sobre las copias locales de las
bases de Clínica Monte Grande en el entorno de desarrollo. Caja y Bonos
quedan fuera: cobranza y facturación corresponden a Markey.

La terminal liviana recibe avisos de órdenes aprobadas por el REST y
asignadas a su puesto. Visualiza datos básicos y prácticas, calcula la
entrega y permite confirmarla o ajustarla a mano antes de imprimir.
Las inconsistencias del pedido se corrigen en Markey, que remite un nuevo
JSON referenciado a la misma orden. Mantener las reglas de versión y
transacción de la especificación según si la operación previa se aplicó.

Maestros: quedan en evaluación la intervención de la terminal o la
aplicación automática por el REST con auditoría en base. Para el piloto
se propone aplicar en el REST solo altas o cambios inequívocos autorizados,
mostrar opcionalmente un aviso informativo en el puesto y devolver a
Markey los casos ambiguos. Pendiente acordar las reglas por maestro.

Revisión estática: CalculaYMuestraFechaEntrega en uBoletasV2 delega el
cálculo en CabezalActual.CalculaFechaEntrega. Pendiente comprobar con un
alta manual cómo guardar la boleta con fechas pendientes y cómo confirmar
las fechas desde el puesto. No se ejecutó el alta ni se modificaron bases.

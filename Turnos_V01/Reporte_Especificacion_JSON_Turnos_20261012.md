# Especificación documental del JSON de turnos y solicitudes de cambios

**Fecha de corte:** 12 de octubre de 2026. **Destino:** revisión de Marcelo y base de actualización conjunta con Markey y CMG. **Estado:** consolidación documental; no constituye un nuevo contrato aprobado.

La documentación ofrece una base de trabajo, pero no una especificación única y definitiva. Conviven el modelo original `OrdenMedica`, un ejemplo simplificado denominado Turno y propuestas de SAGE para completar datos y controlar mensajes. La matriz y el ejemplo simplificado no coinciden en todos los campos. La aceptación de SAGE del 11/09 fue preliminar y condicionada.

Dos conclusiones responden a las nuevas consultas de Marcelo: **no se encontró un identificador de terminal de recepción en los mensajes de turnos revisados**, y **no está demostrada la independencia entre el identificador de orden médica y el de turno en el modelo actual**. La interfaz original sí describía un código de orden médica, pero la matriz posterior lo equipara al identificador de Turno. Se necesita confirmación del modelo real de Markey.

## 1 Qué representa cada fuente

Se utiliza la siguiente clasificación para evitar que un ejemplo se transforme accidentalmente en una obligación contractual:

- **Base documental:** campo presente en el ejemplo simplificado o en su matriz. No acredita emisión actual desde Markey ni obligatoriedad aprobada.
- **Solicitud SAGE:** pedido o propuesta de Marcelo presente en documentos de julio, agosto o septiembre.
- **Requisito ratificado:** condición expresada por Marcelo para el arranque en octubre.
- **Nuevo requerimiento:** necesidad incorporada el 12/10; nombres y mecanismo por acordar.
- **Propuesta de análisis:** recomendación de este reporte, sin aprobación atribuida a otras partes.

Fuentes principales: [interfaz original de Markey](https://docs.google.com/document/d/1-O2ggtmmnHCGRevejj9-8SWNM56KdH_T/edit), [revisión SAGE v0.2](https://docs.google.com/document/d/15QUxMTMsBdOn5BM4oDHydWSPhu1KA880/edit), [interfaz simplificada v0.3](https://docs.google.com/document/d/1AiH53hOwwxjsTv6z3ritHlsZwaMU0zMqHS2yM-_4aDU/edit), [propuesta REST JSON](https://docs.google.com/document/d/1Y_qqR4xB9NnLUvevR70M-WFmaxNttVZL/edit) y [respuesta SAGE del 11/09](https://docs.google.com/document/d/1D2dXM8LGvDTyglxleWnnpJpbpMImyOaQ/edit).

## 2 Estructura simplificada disponible

El ejemplo documental es un objeto en la raíz con esta estructura conceptual:

```text
objeto raíz denominado Turno en la documentación
├── identificador
├── fecha
├── ambito
├── observaciones
├── urgente
├── confidencial
├── paciente
│   ├── codigo, fechaNacimiento, sexo, tipoDocumento, numeroDocumento
│   ├── nombres, apellidoPaterno
│   └── contacto: telefono, email, domicilio
├── obraSocial: codigo, nombre, plan, numeroAfiliado
├── medico
│   ├── codigo, tipoDocumento, numeroDocumento, nombres, apellidoPaterno
│   ├── contacto: telefono, Email, domicilio
│   └── matricula: numero, provincia, tipo
├── laboratorio: codigo, nombre, contacto
└── practicas[]: codigo, nombre
```

**Aclaración estructural:** aunque se escriban rutas como `Turno.paciente`, el ejemplo no contiene un envoltorio literal `{"Turno": {...}}`. Tampoco contiene el encabezado `transaccionId`/`datos` propuesto por SAGE en agosto. Debe acordarse una forma de mensaje única antes de implementar validación estricta.

## 3 Diccionario consolidado de campos actuales

Los tipos de esta sección reflejan la matriz o los valores del ejemplo. La obligatoriedad definitiva debe acordarse campo por campo; «presente en el ejemplo» no equivale a «obligatorio».

### Identificación y contexto

| Ruta en el ejemplo | Tipo | Situación y observaciones |
|---|---|---|
| `identificador` | String | Base documental. Mapeado a `OrdenMedica.ortuCodigo`. SAGE pide estabilidad, unicidad y conservación sin transformaciones. No demuestra IDs separados de orden y turno. |
| `fecha` | String de fecha/hora ISO | Presente en el ejemplo; la matriz usa `fechaInicio`. Precisar si es fecha de cita, orden o recepción; no agruparlas si son eventos distintos. |
| `ambito` | String | Ejemplo AMBULATORIO. Confirmar catálogo AMBULATORIO/INTERNADO/GUARDIA y coherencia con endpoint. |
| `observaciones` | String | Comentario general. Definir cómo se conserva y qué se imprime. |
| `urgente` | Boolean | Aceptable para SAGE; efecto sobre prioridad y trabajo por acordar. |
| `confidencial` | Boolean | Aceptable con regla acumulativa: false no elimina restricciones propias de las prácticas en Sage. |

### Paciente

| Ruta | Tipo | Situación y observaciones |
|---|---|---|
| `paciente.codigo` | String | Identificador HIS. Modelo anterior lo expresaba como Integer. No confundir con documento ni ID LIS. |
| `paciente.tipoDocumento` | String | Presente en ejemplo. SAGE pide tipos RN1/RN2/RN3 con documento de la madre según regla del laboratorio y catálogo completo. |
| `paciente.numeroDocumento` | String | Identificación funcional junto con tipo. Definir conflictos, pacientes sin documento y corrección posterior. |
| `paciente.nombres` | String | Ejemplo; matriz usa `paciente.nombre`. Unificar. |
| `paciente.apellidoPaterno` | String | Ejemplo; matriz usa `paciente.apellido`. Confirmar tratamiento de otros apellidos y nombre completo. |
| `paciente.fechaNacimiento` | String de fecha ISO | Precisar formato fecha sin hora y tratamiento de desconocido. |
| `paciente.sexo` | String | Confirmar valores admitidos y significado para identificación y rangos cuando corresponda. |
| `paciente.contacto.telefono` | String | Aceptado como contacto; el pedido inicial de campo WhatsApp separado fue retirado en la respuesta del 11/09. |
| `paciente.contacto.email` | String | Presente. Regla de actualización y vacío por acordar. |
| `paciente.contacto.domicilio` | String | Presente. Regla de actualización por acordar. |

La interfaz antigua agregaba historia clínica, código interno, código postal, provincia y partido. No aparecen en el ejemplo simplificado. Algunas descripciones de provincia/partido se marcaron irrelevantes para Sage. No reintroducir automáticamente todo campo histórico: confirmar necesidad y equivalencia.

### Cobertura

| Ruta | Tipo | Situación y observaciones |
|---|---|---|
| `obraSocial.codigo` | String | El ejemplo lo deja vacío; SAGE exige código válido incluso PARTICULAR/SIN COBERTURA, tomado de matriz acordada. |
| `obraSocial.nombre` | String | Descripción; no sustituye código. |
| `obraSocial.plan` | String | Presente; precisar si representa código, descripción o ambos. Modelo anterior distinguía código y descripción. |
| `obraSocial.numeroAfiliado` | String | Condición dependiente de cobertura. No exigir afiliado inexistente para PARTICULAR. |

SAGE pidió usar código de cobertura en lugar de CUIT para el mapeo. La respuesta de septiembre cita 9000 para SIN COBERTURA; es una referencia de esa matriz, no un código universal ni evidencia de catálogo ya sincronizado.

### Médico solicitante

| Ruta | Tipo | Situación y observaciones |
|---|---|---|
| `medico.codigo` | String | Código del maestro; modelo anterior Integer. Definir autoridad y desconocidos. |
| `medico.tipoDocumento`, `medico.numeroDocumento` | String | Presentes en ejemplo; obligatoriedad por acordar. |
| `medico.nombres`, `medico.apellidoPaterno` | String | Ejemplo; matriz usa nombre/apellido. Unificar. |
| `medico.contacto.telefono`, `domicilio` | String | Contactos del profesional. |
| `medico.contacto.Email` | String | E mayúscula en ejemplo; SAGE pide uniformar a email. |
| `medico.matricula.numero` | String | Matrícula; conservar como código. |
| `medico.matricula.provincia` | String | Jurisdicción. Confirmar catálogo/codificación. |
| `medico.matricula.tipo` | String | Ejemplo MP. La ampliación de tipo de matrícula fue solicitada por SAGE; estructura aceptable en septiembre. |

CUIT, código interno y especialidad del modelo antiguo no son obligatorios actuales demostrados; septiembre identifica especialidad como no bloqueante.

### Institución solicitante y ubicación

| Ruta | Tipo | Situación y observaciones |
|---|---|---|
| `laboratorio.codigo`, `laboratorio.nombre` | String | Identifican institución/hospital solicitante, no laboratorio receptor. SAGE propone nombre inequívoco, como `institucionSolicitante`. |
| `laboratorio.contacto.telefono`, `domicilio`, `email` | String | Presentes en ejemplo. |
| `laboratorio.cuit` | String en matriz | No aparece en ejemplo. Confirmar necesidad. |
| Ubicación de extracción | Sin estructura actual consolidada | SAGE exige habitación/cama o identificador equivalente en internados y guardia cuando sea necesario localizar al paciente. |

La prueba propia del 07/10 usa `UbicacionSolicitante` e `internacionUbicacion`, pero no demuestra adopción por Markey. Institución solicitante, ubicación física del paciente y puesto de recepción son conceptos distintos.

### Prácticas

| Ruta | Tipo | Situación y observaciones |
|---|---|---|
| `practicas[].codigo` | String | Base aceptable; conservar código exacto, incluyendo `o105` y `O105`. No convertir a número ni normalizar mayúsculas. |
| `practicas[].nombre` | String | Presente en ejemplo; matriz usa descripcion. Unificar nombre contractual. |
| `practicas[].cantidad` | Integer en matriz | Ausente en ejemplo. SAGE admite evaluar omisión/default 1 solo si Markey confirma que siempre corresponde. |
| `practicas[].observaciones` | String en matriz | Ausente en ejemplo; SAGE pide mantenerlas cuando existan. |
| `practicas[].muestra` | Boolean en matriz | Ausente en ejemplo; solicitado como dato crítico. Modelo anterior `procMuestra` era String con descripción «El paciente trajo la muestra?». Precisar semántica y momento de captura. |
| Importes por práctica | Sin nombres actuales acordados | Solicitados en v0.2 como `procImportePaciente` y `procImporteMutual`; no están en el ejemplo simplificado. Confirmar si se mantienen junto con totales. |

Un Boolean no identifica tipo de material, recipiente, toma efectiva ni fecha de extracción. El indicador solicitado no debe reemplazar esas dimensiones del circuito. La hoja de ruta propone un identificador de ítem para prácticas repetidas y cambios selectivos; no está incorporado en el ejemplo actual.

### Datos documentados pero ausentes del ejemplo

| Dato | Antecedente y pedido SAGE | Definición necesaria |
|---|---|---|
| Diagnóstico | Modelo original lo incluye; matriz simplificada menciona codigo, CodigoInterno y descripcion, con observaciones equivocadas sobre institución | Confirmar incorporación y obligatoriedad; corregir matriz; no mapearlo como institución |
| Total a cargo del paciente | `importeTotalPaciente`; julio lo ubicaba bajo paciente | Incorporar; septiembre propone nodo administrativo del Turno |
| Total cobertura | `importeTotalMutual` | Incorporar y precisar significado y precisión monetaria |
| Cobrado | `importeCobrado` | Distinguir de total a cobrar y total factura |
| Entrega 1 y eventual entrega 2 | Julio pide FechaEntrega1; septiembre detalla una o dos fechas | Resolver cálculo/confirmación y devolución a Markey; no necesariamente ambas entran desde HIS |
| Fecha de creación/vencimiento de orden | Presentes en el modelo original | Confirmar si se conservan y diferenciar de cita y recepción |
| Terminal de recepción | Nuevo pedido 12/10 | Incorporar identificación y circuito de impresión |
| ID independiente de orden médica | Antecedente de código de orden; actual identificación ambigua | Confirmar en Markey y representarlo separado del turno cuando son entidades distintas |

## 4 Registro de solicitudes y evolución

| Tema | Solicitud y evolución | Estado documental al corte |
|---|---|---|
| Turno como entidad | Septiembre: conformidad técnica preliminar con simplificación | Aceptable para SAGE; contrato completo sin cierre demostrado |
| Identificación | Código estable; transacción separada; versiones; octubre distingue orden/turno/boleta | Requisito de arranque; independencia y cardinalidades pendientes |
| Cobertura | Código en vez de CUIT; no vacío; desconocidos sin alta automática por defecto | Pedido documentado; falta prueba del mensaje y maestro actual |
| RN e identidad | Tipos RN y conflictos de paciente | Reglas solicitadas; validar generación real |
| Muestra | Condición por práctica; octubre ratifica que no va a fase 2 | Requisito de arranque; semántica exacta pendiente |
| Entrega | Julio pide fecha; septiembre propone cálculo en Sage y devolución de una/dos fechas; octubre rechaza postergación | Requisito de arranque; modalidad aún por acordar |
| Importes | Totales, cobrado y pedidos previos por práctica | Solicitudes vigentes a confirmar en contrato consolidado |
| Códigos de práctica | Octubre confirma sensibilidad a mayúsculas | Requisito de arranque; probar extremo a extremo |
| Institución | Renombrar laboratorio; distinguir cobertura/origen | Solicitud documental; nuevo nombre no confirmado |
| Ubicación | Julio marcaba numerosos campos como irrelevantes; septiembre exige ubicación cuando hay extracción en internación/guardia | Prevalece necesidad operativa posterior; no trasladar el descarte antiguo a todos los ámbitos |
| Confidencialidad | Restricciones acumulativas de HIS y LIS | Propuesta explícita SAGE; validar visibilidad en Markey |
| Maestros | Revisar altas automáticas; autoridad del laboratorio en prácticas y sincronización | Necesita regla por entidad y evidencia de sincronización |
| Operación y errores | Altas/cambios/cancelación, rechazo funcional y reenvíos sin duplicación | Propuesta desde agosto y análisis de octubre; no presentes en ejemplo simplificado |
| Endpoints por ámbito | Acuerdo informado de reunión 09/10 | Diferenciación definida según relato; rutas y contratos aún sin documentar |
| Terminal e impresión | Nuevo pedido de Marcelo 12/10 | Incorporado como necesidad; implementación y nombres por acordar |

La aceptación informal del 22/09 no identifica inequívocamente una versión y exceptúa fecha de entrega y «lo de muestra». No permite marcar cada pedido como aprobado o implementado. El memo de octubre ratifica que muestra, entrega, identidad y cambios deben quedar resueltos para arrancar.

## 5 Identificación de orden médica y turno

**Respuesta a la consulta:** el modelo original documentaba `OrdenMedica.ortuCodigo` como código único de orden médica y `ortuCodigoInterno` como código interno. No presentaba simultáneamente una entidad Turno independiente. El modelo simplificado incorpora `identificador` y lo mapea al código anterior. La propuesta SAGE `idOrdenMarkey` tampoco prueba que Markey exponga dos identificadores distintos.

Por lo tanto, no se puede afirmar que el actual JSON conserve el ID de la prescripción original, ni que turno y orden sean la misma entidad. La fuente histórica MAJOR/OPTIMI y un PDF de arquitectura que describe Innova son antecedentes distintos; sus códigos no se adoptan automáticamente como contrato actual de Markey.

Preguntas concretas para Markey:

1. ¿La orden/prescripción tiene un ID propio, independiente de cita, turno o admisión? ¿Cuál es su nombre exacto y ámbito de unicidad?
2. ¿Qué entidad identifica el actual `identificador`? ¿Es el mismo valor que el `turnId` del envío mínimo o son campos distintos?
3. ¿Un turno puede incluir varias órdenes médicas? ¿Una orden puede atenderse en varios turnos, re-citaciones o boletas?
4. ¿Qué ID se conserva al reprogramar, agregar/retirar prácticas o pasar de guardia a internación?
5. ¿Con qué ID espera Markey recibir resultados: prescripción, turno, ítem u otra entidad? ¿Necesita varios para asociarlos inequívocamente?

**Propuesta de representación, no contrato aprobado:** conservar identificadores separados de orden médica y turno, además de transacción e ID de boleta generado por Sage. Si hay relaciones múltiples, usar vínculos/colecciones en vez de forzar una única pareja. Una respuesta aceptada debe devolver la correlación necesaria para consultas y resultados.

## 6 Terminal de recepción y destino de impresión

**Nuevo requisito de Marcelo:** la terminal que efectúa la recepción administrativa debe ser identificable para que Sage emita allí etiquetas y talón. Esta necesidad no estaba resuelta por la pantalla mínima de SAGE propuesta en septiembre.

Se propone incluir un contexto de recepción con ID estable de puesto/terminal, sede o sector que delimite su unicidad, usuario y fecha/hora de confirmación. Los nombres siguientes son ilustrativos, no campos ya aceptados:

```json
{
  "recepcion": {
    "terminalId": "RECEPCION-LAB-02",
    "sedeId": "CMG",
    "usuarioId": "OPERADOR-017",
    "fechaHora": "2026-10-12T10:30:00-03:00"
  }
}
```

Este bloque es una extensión conceptual, no un payload completo para enviar. Debe definirse si el puesto lógico de recepción es también el destino de impresión o si se requieren dos referencias distintas. Puede haber una PC con dos impresoras, sesiones remotas o varias terminales compartiendo impresoras.

- [ ] Definir si terminal significa PC física, sesión de usuario, puesto lógico o caja. Elegir una identidad estable que Markey pueda enviar y Sage pueda reconocer.
- [ ] Capturar el puesto que **confirma la recepción**, aunque la prescripción se haya creado antes desde otra PC o el envío REST salga de un servidor central.
- [ ] Mapear en configuración SAGE/CMG el puesto hacia impresora de etiquetas y de talón. Como propuesta, evitar transportar rutas libres de impresora si basta un puesto conocido.
- [ ] Definir el mecanismo: cliente Sage abierto en el puesto que obtiene los trabajos, servicio/agente de impresión o impresión central a colas configuradas. El campo terminalId solo no ejecuta una impresión.
- [ ] Acordar evento de impresión: aceptación funcional y confirmación de fechas, impresión automática o acción del operador. Un reenvío de alta no debe volver a imprimir por defecto.
- [ ] Conservar destino original durante reintentos. Cambio de puesto/reimpresión requiere acción explícita y motivo, sin generar nueva boleta.
- [ ] Si el puesto es desconocido, está cerrado o la impresora falla, registrar impresión pendiente y avisar al operador; decidir si esto impide aceptación o solo impresión. No elegir otra terminal silenciosamente.
- [ ] Correlacionar boleta, versión y trabajo de impresión; separar alta, envío a cola y verificación operativa de salida. Si no se puede confirmar impresión física, no etiquetar una simple entrega al spooler como prueba de impresión.

**La IP del POST no identifica de manera fiable la terminal:** puede corresponder al servidor Markey, proxy o salida compartida. `sistemaOrigen: MARKEY` identifica la aplicación, no el puesto; `usuarioId` identifica al operador y tampoco sustituye al puesto.

Pruebas mínimas: dos recepciones simultáneas desde puestos diferentes imprimen en sus respectivos destinos; respuesta perdida no duplica impresión; puesto sin cliente activo conserva pendientes; reimpresión autorizada desde otro puesto conserva auditoría y no crea boleta nueva.

## 7 Control de mensajes y respuesta del LIS

La propuesta SAGE de agosto contiene `transaccionId`, `fechaHora`, `sistemaOrigen`, `versionMensaje`, `operacion`, `idOrdenMarkey` y `versionOrden`. Son campos propuestos; no aparecen en el ejemplo simplificado actual. Debe acordarse cómo integrarlos sin duplicar IDs con significados ambiguos.

Reglas propuestas documentadas: mismo mensaje durante reintento; nueva versión para cambio; respuesta original para retransmisión ya procesada; conflicto si la misma orden/versión llega con contenido diferente; modificación aceptable o rechazable según estado real.

Respuesta de éxito propuesta: ok, identificador de transacción, código/mensaje, identificador externo y protocolo SageLab. Error propuesto: ok false, transacción y código funcional. Catálogo inicial: mensaje inválido, obligatorio faltante, paciente conflictivo, orden conflictiva, práctica no homologada, modificación no admitida, orden no encontrada y error interno.

El servicio local revisado registra recepción RAW y el LEEME V0.3 explica que HTTP 200/RECIBIDO no implica alta SQL. No deben confundirse esas respuestas con el éxito funcional propuesto. Las rutas históricas `/apiMarkeyV2/ordenes` y `/api/v1/ordenes` tampoco prueban despliegue: la URL de recepción de prueba informada es `/api/lis/turnos` en el puerto 8081. Las tres rutas nuevas por ámbito requieren confirmación.

## 8 Evidencia disponible y diferencias con la prueba propia

El JSON de 1.883 bytes de las 12:32 del 07/10 fue enviado por Marcelo desde un cliente REST remoto. Agrega `internacionUbicacion`, cambia `laboratorio` a `UbicacionSolicitante` e incluye `importePaciente`, `importeMutual` e `importeTotal` vacíos en paciente/práctica. Es material útil de prueba, pero no certifica nombres o valores aceptados por Markey. Esos importes tampoco demuestran el dato separado `importeCobrado` solicitado.

El envío de las 15:05 solo contiene `turnId:12`. No corresponde a la estructura completa documental y no permite inferir equivalencia con `identificador`. El primer POST de la tarde estaba vacío. Al último estado informado por Marcelo, el 11/10, seguía pendiente un JSON completo emitido por el flujo actual de Markey; este reporte no supone una nueva entrega no informada.

## 9 Lista priorizada para cerrar la especificación

1. Obtener JSON completo generado por Markey, versión emisora y contexto de recepción, conservando IDs y estructura con datos de homologación.
2. Confirmar ID de orden médica, ID de turno, cardinalidades y correlación con boleta e ítems de prácticas.
3. Acordar ID del puesto de recepción y circuito de impresión; demostrar dos puestos simultáneos y reintentos.
4. Unificar raíz/envoltorio, nombres, tipos y versiones. Definir obligatorios, condicionales, null, ausencia, vacío y valores por defecto.
5. Cerrar muestra por práctica y campos de ubicación por ámbito; distinguir situación administrativa de toma efectiva.
6. Cerrar fecha de entrega 1/2, quién calcula y confirma y cómo Sage devuelve las definitivas a Markey.
7. Incorporar importes y precisar si se requieren por práctica, totales y cobrado; acordar moneda y precisión.
8. Conciliar maestros y catálogo sensible a mayúsculas; establecer tratamiento de referencias desconocidas.
9. Acordar aceptación/rechazo, cambio/anulación, versiones y reenvío, con errores visibles para quien los resuelve.
10. Publicar una versión consolidada de contrato y ejemplos por ámbito, y una matriz de pruebas aprobada por las partes antes del arranque.

## 10 Alcance de la revisión y fuentes complementarias

Se consultaron 31 archivos de Drive identificados por búsqueda y carpetas relacionadas: documentos del proyecto, copias de interfaz, fuentes históricas y plantillas operativas. Se relevaron carpetas y se revisaron textos disponibles por el conector; no se hizo una auditoría de todo Drive, de cada revisión histórica ni de comentarios en esta actualización. No se modificaron documentos compartidos.

Se tomaron como apoyo [minuta de julio](https://docs.google.com/document/d/1CN6t9VS7IfE9IJlSaaN-2rWHrxea_UW_/edit), [respuesta de Marcelo a esa minuta](https://docs.google.com/document/d/1GXx1VLU32XCmo0kBBJcRjM5TsM5lUnvpiDJAbV7zAh8/edit), [catálogo homologado](https://docs.google.com/document/d/10r2Zh_Aa-YUrCU0jG80wlOrutnCOu0it/edit), [alcance inicial](https://docs.google.com/document/d/1FiSiE-Fc-KC5sAlq7a7GPBIAqIxSuZ5R/edit), [estados](https://docs.google.com/document/d/1vE96BbNuOE48kEVGb99G6oYuzKfDzcGf/edit) y [contratos API de julio](https://docs.google.com/document/d/1mZAMUoZC8tWSvncKRg9TyiPaywfzpw2J/edit). El estado «Aprobado» de una plantilla no llena sus campos pendientes ni acredita un contrato funcional implementado.

También se consultaron el índice, responsables, pedido formal, capacidades, alternativas, registros de APIs/conectores/catálogos, seguridad, monitoreo, manual, soporte y documentos de puesta en marcha. No aportan un campo de terminal en el JSON de turnos. Como antecedentes separados se leyeron [interfaz MAJOR OPTIMI](https://docs.google.com/document/d/1RC6Y62Hdq-aKipsNTNrAsins_fSfrpat-3LynU7jteI/edit) y su copia DOCX, y [arquitectura Innova](https://drive.google.com/file/d/1U4SGDq9nj-ngF_Y7tmiHNxysQV8mHOVw/view). Este último distingue solicitud, evento, episodio y orden de trabajo, pero no demuestra el modelo vigente de Markey.

Fuentes locales: [bitácora](C:/DelphiWork/REST/Turnos_V01/Bitacora_Integracion_Markey.md), [memo del 08/10](C:/DelphiWork/REST/Turnos_V01/Memo_Reunion_Integracion_20261008.md), [minuta del 11/10](C:/DelphiWork/REST/Turnos_V01/Minuta_Interna_Reuniones_20261008_09.md), [hoja de ruta](C:/DelphiWork/REST/Turnos_V01/Hoja_de_Ruta_Integracion_Markey_Sage_20261011.md), [prueba propia](C:/DelphiWork/REST/Turnos_V01/Logs/Turnos/Turno_20261007_123216_391_5248E29D-6511-482F-936B-F4CA301A7115.json), [JSON mínimo](C:/DelphiWork/REST/Turnos_V01/Logs/Turnos/Turno_20261007_150514_922_76A6F8F5-1363-4140-9F2E-279E6C2F93A5.json), código del receptor y LEEME V0.3. Las conversaciones aportadas por Marcelo se consideran contexto informado, no actas multilaterales aprobadas.

# Respuesta SAGE al documento ResumenDefinicionesMarkeySage.pdf

**Fecha:** 16/10/2026. **Versión:** 1.1, respuesta SAGE a Markey.

En respuesta al resumen de la reunión del 09/10/2026, se presentan las definiciones, respuestas, consultas y pedidos de SAGE siguiendo la numeración del mapa mental (01 a 09) y de las reglas pendientes (P1 a P8). Los puntos vinculados se remiten entre sí para mantener una única definición de cada tema.

La especificación JSON requerida por el LIS, revisión documental 1.2 del 12/10/2026, ya fue enviada a Markey. Solicitamos su devolución sobre los campos y reglas indicados, con conformidad, alternativa concreta o restricción, y ejemplos generados desde el HIS.

Los responsables del laboratorio confirmaron que los casos habituales de modificación, añadido y eliminación de prácticas están cubiertos por el catálogo analizado. Las pruebas funcionales con los JSON de Markey podrán revelar nuevos casos para incorporar. Esta confirmación del laboratorio no sustituye el acuerdo con Markey sobre los circuitos e interfaces compartidos.

Se distingue documentación elaborada, propuestas sujetas a validación y decisiones pendientes. Este documento no acredita implementación ni homologación de los circuitos descriptos. Las propuestas sobre estados, facturación y regreso del paciente necesitan validación conjunta antes de convertirse en especificaciones definitivas.

## 01. Circuitos por ámbito

**Estado:** primera propuesta para validación de Markey, laboratorio e IT CMG.

### Circuito común propuesto

1. Markey registra la solicitud, identifica paciente, orden médica, ítems y ámbito, y completa las condiciones administrativas correspondientes.
2. El evento habilitante del circuito genera el JSON hacia SAGE. En ambulatorio es el "cierre administrativo"; en guardia/internación debe precisarse el evento equivalente.
3. SAGE valida estructura, identidad, maestros, códigos, versiones y contexto operativo. Una recepción HTTP por sí sola no acredita alta funcional.
4. Si acepta, registra la boleta y conserva la correlación entre Turno, orden médica e ítems; si rechaza, devuelve el motivo para corrección en origen.
5. SAGE calcula/confirma las fechas de entrega según el circuito y dirige la emisión de comprobantes al puesto homologado. Aceptación, confirmación de fechas e impresión pueden suceder en momentos distintos.
6. El LIS registra la toma/recepción de muestras, incidencias, procesamiento y emisión de informes. Las consecuencias para Markey se comunican por el mecanismo a acordar.

| Aspecto | Ambulatorio | Guardia | Internación |
|---|---|---|---|
| Origen | Admisión y cierre administrativo en Markey. | Orden sin admisión ambulatoria; evento de envío a precisar. | Orden sin admisión ambulatoria; evento de envío a precisar. |
| Recepción LIS | Endpoint del ámbito, con convenciones comunes. | Endpoint diferenciado; confirmar ruta. | Endpoint diferenciado; confirmar ruta. |
| Destino operativo | Puesto receptor identificado por sede/terminal. | Puesto operativo/destino de impresión a acordar. | Pantalla de trabajo de extraccionistas y destino de impresión a acordar. |
| Ubicación | Cuando el circuito la requiera. | Ubicación suficiente si hay que localizar al paciente. | Ubicación vigente, habitación/cama cuando corresponda. |
| Comprobantes | Talón del paciente y etiquetas. | Talón del paciente y etiquetas, según el circuito informado por SAGE. | Etiquetas; validar necesidad y destino de otros comprobantes. |
| Continuidad | Pendientes y regreso vinculados a la solicitud original. | Definir continuidad y eventual cambio de ámbito/episodio. | Actualizar ubicación y precisar relación con el episodio asistencial. |



**Responsabilidades y pendiente:** Markey e IT CMG deben completar la documentación de los procesos por ámbito antes del desarrollo técnico. SAGE participa validando los pasos y datos que afectan al LIS. Las definiciones específicas de guardia e internación se retoman en 07 y P6.

## 02. Admisión ambulatoria

**Respuesta SAGE:** el cierre administrativo de Markey origina el envío del JSON. SAGE valida la información, acepta o rechaza funcionalmente y, si acepta, registra la boleta y su correlación. El circuito completo se describe en 01; el contrato y las pruebas, en 05.

**No aplica a SAGE:** completar la valorización administrativa y los triggers de recepción/cierre dentro de Markey; son tareas de Markey. SAGE debe validar la recepción y los efectos en el LIS. Los importes por ítem, totales y cobrado deben respetar la semántica del contrato enviado.

**Pendiente de Markey:** generar el JSON completo desde el circuito de admisión y confirmar el evento exacto de envío y el tratamiento de la respuesta funcional.

## 03. Etiquetas y talones

### Impresión y recuperación

- SAGE asocia `recepcion.sedeId` y `recepcion.terminalId` con el destino de impresión; no lo infiere de la IP del servidor que envía el REST.
- Un puesto no homologado impide aceptar el alta que requiere impresión dirigida, conforme al contrato solicitado.
- Una falla temporal de impresora en un puesto homologado deja la impresión pendiente, conservando la boleta aceptada.
- Reenviar el mismo mensaje no debe generar otra boleta ni una nueva impresión automática. La reimpresión se gestiona como operación propia del LIS.

**Devolución solicitada:** confirmar disparadores por ámbito, puestos y destinos, tratamiento de órdenes internas/externas concurrentes, relación orden/Turno/episodio y necesidad de accesos diferenciados por centro. La asignación de endpoints por centro debe resolverse con Markey e IT CMG.

**Responsabilidades y pendiente:** SAGE configura y valida la impresión; Markey identifica el puesto real de recepción y CMG valida puestos, impresoras y destinos. Los destinos por ámbito se detallan en 01 y se retoman en P6.

## 04. Catálogo y cobertura

**Respuesta SAGE:** se debe mantener la interoperabilidad basada en procedimientos y formalizar su correspondencia con las prácticas del LIS y los conceptos facturables. Se deben distinguir estudio solicitado, trabajo técnico del laboratorio y concepto facturable, según se desarrolla en 06.

El contrato enviado conserva el arreglo `practicas`; cualquier cambio de nomenclatura debe acordarse explícitamente. No se presupone equivalencia automática entre procedimientos, prácticas y conceptos de facturación.

**Devolución solicitada a Markey y laboratorio:** confirmar equivalencias de procedimientos/prácticas, coberturas, médicos e instituciones; la preservación de los códigos como String, incluidos ceros y mayúsculas/minúsculas, y la distinción extremo a extremo de `o105` y `O105`. Las coberturas, copagos y reglas de valorización dependen de los convenios vigentes y requieren definición de los responsables administrativos.

**Participación SAGE:** validar las correspondencias utilizadas por el LIS. Las reglas de nomenclador y facturación se retoman en 08 y P4.

## 05. JSON e identificadores

**Estado:** especificación SAGE elaborada y enviada a Markey; pendiente de devolución, aprobación conjunta y homologación.

**Referencia:** Especificación del JSON de turnos requerida por SAGE, revisión documental 1.2 del 12/10/2026, enviada a Markey. La revisión documental es 1.2; la versión de contrato solicitada en `versionMensaje` es 1.0. Se conserva el objeto Turno en la raíz y el arreglo `practicas`; cualquier cambio de nomenclatura debe acordarse explícitamente.

La especificación ya incluye:

- Identificadores separados para Turno, orden médica, transacción e ítem, y control de versión del Turno.
- Operaciones ALTA, MODIFICACION y CANCELACION; instantánea completa para modificaciones, validación del conjunto sin aplicación parcial y reintentos sin duplicación.
- Contexto de recepción: sede, terminal, usuario, fecha/hora y síntomas cuando se registren.
- Paciente, cobertura, solicitante, institución, diagnóstico y ubicación bajo las condiciones previstas.
- Códigos como String, preservando ceros y mayúsculas/minúsculas; diferenciación de `o105` y `O105`.
- Indicador de muestra por práctica, importes por ítem, totales y cobrado; su semántica debe confirmarse. El indicador inicial de disponibilidad de muestra no acredita por sí mismo una toma efectiva registrada por el LIS.
- Respuesta funcional inmediata, correlación con boleta SAGE y devolución posterior de una o dos fechas de entrega.
- Errores funcionales, conflictos de versión y separación entre alta aceptada e impresión física.

### Confirmaciones prioritarias

| Tema | Respuesta necesaria de Markey |
|---|---|
| Identificadores | Entidad identificada, unicidad, estabilidad y relación entre órdenes, turnos y boletas; cómo representa varias órdenes o regresos. |
| Códigos y maestros | Preservación extremo a extremo de mayúsculas; equivalencias de procedimientos/prácticas, coberturas, médicos e instituciones. |
| Recepción | Captura del puesto real y destino operativo cuando no exista recepción convencional. |
| Ciclo de vida | Emisión de altas/cambios/cancelaciones; tratamiento de rechazo, conflicto, reintento y secuencia. |
| Fechas | Endpoint receptor en Markey, almacenamiento y actualización de las fechas calculadas por SAGE. |
| Operación técnica | Rutas, autenticación, tamaños, timeout y mecanismo de consulta/conciliación. |

**Pruebas propuestas:** JSON completo generado por Markey; alta válida; rechazo con corrección; reenvío sin otra boleta ni impresión; agregado/retiro de ítems; cancelación; versión obsoleta; dos puestos de recepción; distinción `o105`/`O105`; falla de impresión y recuperación; devolución de fechas; recepción de guardia e internación.

Estas pruebas deben verificar el circuito funcional completo. No se presenta la conectividad probada como homologación operativa.

**Pendiente principal de Markey:** responder al contrato enviado y producir ejemplos completos desde el HIS. SAGE consolidará las observaciones y participará en la homologación conjunta. Ver también P3 y P7.

## 06. Cambios postextracción

**Estado:** casos habituales de modificación, añadido y eliminación de prácticas confirmados por los responsables del laboratorio. Permanece pendiente el acuerdo de interfaces y circuitos compartidos con Markey. Las pruebas funcionales con los JSON de Markey podrán revelar nuevos casos para incorporar.

### Distribución propuesta

- Markey administra cambios en la solicitud y sus condiciones administrativas: estudios solicitados, cobertura, autorizaciones, importes y conceptos facturables.
- SAGE administra la ejecución: toma y recepción de materiales, rechazo, pendientes, métodos, repeticiones, procesamiento y resultados.
- Un cambio con efectos en ambas dimensiones requiere coordinación. Su origen en el laboratorio no determina por sí solo dónde debe aplicarse.

Se deben distinguir estudio solicitado, trabajo técnico del laboratorio y concepto facturable. Una corrección contable no debe agregar o borrar trabajo técnico ni resultados.

| Situación | Tratamiento propuesto |
|---|---|
| Paciente acepta un estudio inicialmente rechazado o se detecta uno omitido. | Markey actualiza la solicitud y sus condiciones; envía MODIFICACION. SAGE valida y determina muestras/etiquetas adicionales. |
| Desistimiento o baja de un estudio. | Markey solicita modificación/cancelación. SAGE acepta o rechaza según el avance real, conservando antecedentes. |
| Extracción imposible/incompleta; material faltante o inadecuado. | SAGE registra incidencia, motivo y prácticas pendientes. Markey coordina el regreso y admisión cuando corresponda. |
| Adición sobre muestra conservada. | Markey registra la ampliación solicitada. SAGE verifica aptitud, disponibilidad y necesidad de nueva toma antes de aceptar. |
| Cambio de código interno, repetición o complemento técnico incluido. | SAGE lo registra preservando la correspondencia con la solicitud. Si cambia el estudio o agrega un cargo, se coordina con Markey. |
| Corrección de nomenclador o convenio sin cambio del estudio. | Se resuelve en el circuito administrativo acordado, con Markey como responsable propuesto de esa representación; se sincroniza lo que el LIS utilice. |
| Corrección de un informe ya emitido. | SAGE conserva la historia y emite una nueva versión; definir notificación a Markey. |

### Regreso del paciente

Para extracción incompleta, material faltante, material rechazado o nueva toma necesaria:

1. SAGE registra lo obtenido, lo pendiente/rechazado y la acción requerida.
2. Se comunica a Markey la necesidad de regreso por la vía a acordar.
3. Markey gestiona recitación y admisión de continuidad, cuando corresponda, vinculadas a la orden original.
4. El regreso se comunica a SAGE, que registra la nueva toma/entrega y emite las etiquetas necesarias conservando la historia previa.

**Una nueva visita o admisión no implica necesariamente nueva orden médica ni nuevo cargo.** Si Markey genera otro Turno, debe definirse cómo se vincula con la orden, Turno e ítems previos. El contrato enviado plantea esta cardinalidad como confirmación pendiente; no se presume que ya resuelva el evento de regreso.

La conservación de códigos de barras se evaluará según si se reutiliza una muestra existente o se obtiene una nueva. No se propone reutilizar indiscriminadamente la identificación de tubos.

### Reglas de aceptación

Los cambios respetarán los identificadores, versiones y auditoría del contrato enviado. Una modificación completa de Markey no debe sobrescribir hechos técnicos del LIS. SAGE valida el conjunto y lo acepta o rechaza sin aplicación parcial. Una práctica ejecutada o informada conserva su historia aunque se modifique su tratamiento administrativo.

**Devolución solicitada:** acordar representación de regresos, vinculación de ítems, notificación LIS → Markey, autorizaciones por tipo de cambio y efecto sobre talones/etiquetas. Los casos del catálogo cuentan con la confirmación de los responsables del laboratorio; resta formalizar el acuerdo operativo con Markey y ampliar el catálogo si las pruebas funcionales revelan nuevos casos.

## 07. Guardia e internación

**Respuesta SAGE:** las órdenes se reciben por endpoints diferenciados por ámbito con convenciones comunes, sin requerir una admisión ambulatoria. Los datos de ubicación, internación o emergencia que correspondan deben formar parte de la orden.

La matriz de 01 detalla la recepción, destino operativo, ubicación, comprobantes y continuidad. SAGE debe contemplar estas órdenes en la pantalla de trabajo de extraccionistas. Para internación se prevén etiquetas y se debe validar la necesidad y destino de otros comprobantes; para guardia, talón y etiquetas según el circuito informado.

**Pendiente de Markey y SAGE:** precisar el evento habilitante del envío, método/ruta API y variabilidad de estudios; confirmar ubicación suficiente, actualización de habitación/cama, relación con el episodio y tratamiento de cambios de ámbito. Cuando no exista recepción convencional, acordar el puesto operativo y destino de impresión, sin inventar un puesto.

**Validación conjunta:** laboratorio e IT CMG deben participar en la definición del circuito operativo. Ver P6 para cierre administrativo y eventual contrato adicional.

## 08. Facturación y estados

**Estado:** propuesta funcional inicial. Falta relevar su correspondencia con los estados disponibles en SAGE y acordar su transmisión. No es un contrato JSON adicional aprobado.

Se propone distinguir estado de integración, estado de ejecución por ítem, estado de muestras, estado de informe y condición administrativa. Una orden puede tener estudios informados y otros pendientes al mismo tiempo.

| Dimensión | Hechos/estados candidatos | Finalidad |
|---|---|---|
| Integración | Operación aceptada, rechazada o ya procesada; versión aplicada. | Confirmar sincronización y evitar duplicaciones. |
| Muestras | Pendiente, toma/recepción registrada, rechazo, nueva toma requerida. | Coordinar continuidad y regreso. |
| Ejecución por ítem | Pendiente, en proceso, realizado, no realizado, cancelación aceptada. | Informar cumplimiento sin perder antecedentes. |
| Informe | Sin informe, parcial, final, corregido/ampliado. | Identificar disponibilidad y versión de la información. |
| Administración | Elegible, diferido, excluido, facturado o ajustado, si esas categorías se acuerdan. | Aplicar reglas del laboratorio/facturación; no derivarlas automáticamente de un estado técnico. |

### Eventos candidatos LIS → Markey

Además de la respuesta inmediata y la devolución de fechas ya especificadas, evaluar notificaciones de muestra pendiente/rechazada, necesidad de regreso, cumplimiento/no realización de ítems y emisión/corrección de informes.

Cada evento debería correlacionar Turno, orden médica y boleta; identificar los ítems/muestras afectados cuando corresponda; y llevar ID de evento, fecha/hora, versión y motivo. La estructura, entrega, confirmación y consulta de estos eventos quedan por acordar. Esta propuesta no modifica los campos del contrato JSON enviado.

### Decisiones de negocio pendientes

- Hecho habilitante para facturar: admisión, toma de muestra, realización o informe, y posibles diferencias por ámbito/convenio.
- Tratamiento de informes parciales y prácticas realizadas sin informe final.
- Regla del corte del día 27: hora de corte, universo de casos, definición de “sin informe”, exclusiones y período al que se difieren.
- Tratamiento de rechazos, nuevas tomas, cancelaciones y correcciones después de facturar.
- Equivalencias entre procedimientos/prácticas del LIS y conceptos del nomenclador facturable.

SAGE propone aportar los hechos técnicos y de informes disponibles. Laboratorio y facturación deben confirmar cómo esos hechos determinan inclusión, exclusión o diferimiento; Markey debe confirmar su representación y aplicación administrativa.

### Conciliación propuesta

Comparar al corte las órdenes e ítems de Markey con boletas, ejecución e informes de SAGE. Identificar aceptados no reflejados, rechazos pendientes, duplicaciones, diferencias de versión y casos diferidos con motivo. Acordar responsable de resolución y seguimiento hasta el siguiente período, mediante consulta, reporte o interfaz según la solución definida.

**Pendientes y responsables:** SAGE releva y propone los hechos técnicos disponibles; laboratorio/facturación define el hecho facturable y las reglas de inclusión, exclusión y diferimiento; Markey coordina la postanalítica y confirma su representación administrativa y las interfaces. Ver P4 y P5.

## 09. Infraestructura y eventos

**No aplica a SAGE:** completar los procedimientos y activadores de órdenes de Markey, la configuración de Service Broker o decidir la arquitectura de servidores de Markey/CMG. Esas tareas corresponden a Markey e IT CMG.

**Participación SAGE:** aportar los requisitos del receptor LIS y participar en pruebas de transacciones, recepción, reintentos y transiciones de estados, procesando órdenes y sus ítems. Las pruebas funcionales se detallan en 05 y los eventos candidatos LIS → Markey, en 08.

**Pendiente de Markey e IT CMG:** completar procedimientos/activadores y evaluar endpoints por centro, accesos e infraestructura. Confirmar con SAGE rutas, autenticación, tamaños, timeout y mecanismos de consulta/conciliación. La conectividad JSON ambulatoria probada no equivale a homologación funcional. Ver P7 y P8.

## P1. Altas después de extracción

**Respuesta SAGE:** los casos habituales del catálogo están confirmados por los responsables del laboratorio. Se mantiene la distribución de responsabilidades, los casos, el circuito de regreso y las reglas de aceptación de 06.

**Pendiente de acuerdo con Markey:** representación de la ampliación o del regreso como continuidad del Turno o nuevo Turno vinculado; relación con la orden original, ítems, boleta, muestras y resultados; conservación de identificación de tubos cuando corresponda, nueva identificación para nuevas muestras y prevención de duplicación de estudios/cargos.

SAGE valida la viabilidad según el estado real del trabajo y conserva lo ya extraído, procesado o informado. La confirmación del catálogo no cierra estas decisiones de integración. Los nuevos casos que aparezcan en las pruebas se incorporarán al catálogo.

## P2. Órdenes internas + externas

**No aplica a SAGE:** resolver la carga administrativa en Markey cuando coinciden órdenes internas y externas; la revisión del escenario corresponde a Markey con el laboratorio.

**Participación SAGE:** validar los efectos sobre la correlación de órdenes, Turnos e ítems y el tratamiento de modificaciones que lleguen al LIS. La carga manual previa al cierre figura como propuesta del documento de origen, no como decisión aprobada.

**Devolución solicitada a Markey:** describir el circuito y confirmar si un Turno agrupa varias órdenes o una orden produce varios Turnos/boletas. Si existe interfaz de cambios posterior al cierre, acordarla respetando 05 y 06; no asumir que está implementada.

## P3. Contrato JSON completo

**Respuesta SAGE:** la especificación requerida ya fue elaborada y enviada. Su contenido, confirmaciones y pruebas están en 05. Incluye la separación de identificadores, datos condicionales por ámbito y relación con los ítems; conserva el objeto Turno en la raíz y el arreglo `practicas`.

**Pendiente de Markey:** devolución por campo/regla, con conformidad, alternativa o restricción y ejemplos generados desde el HIS; confirmación de cardinalidades y de la información de guardia/internación. La interfaz de facturación y los eventos adicionales deben definirse conjuntamente según 08; no se consideran aprobados por el envío de la especificación de turnos.

## P4. Facturación / postanalítica

**Respuesta SAGE:** se mantiene íntegra la propuesta de dimensiones, estados y eventos de 08, incluida la distinción entre ejecución, muestras, informe y condición administrativa. Un informe parcial no equivale automáticamente a orden terminada ni determina por sí solo su facturabilidad.

**Pendiente de laboratorio/facturación con Markey:** hecho facturable, tratamiento de parciales y de prácticas realizadas sin informe final, exclusiones, mapeo de nomenclador y ajustes posteriores a facturar. Markey coordina la definición postanalítica.

**Pendiente de SAGE y Markey:** relevar los estados disponibles, acordar los eventos y su estructura, entrega, confirmación y consulta, conservando las correlaciones y versiones indicadas en 08. Esta propuesta no modifica el contrato JSON ya enviado.

## P5. Regla de exclusión mensual

**Respuesta SAGE:** aportar los hechos técnicos y de informes disponibles y participar en la conciliación descripta en 08.

**No aplica a SAGE:** aprobar la regla comercial de exclusión o diferimiento. Corresponde al laboratorio y al equipo de facturación, con su implementación administrativa en Markey.

**Definición solicitada:** hora y universo del corte del día 27; significado de “sin informe”, tratamiento de parciales, casos excluidos y período de diferimiento. Acordar cómo se identifican y notifican esos casos, quién resuelve diferencias y cómo se siguen hasta el siguiente período, mediante consulta, reporte o interfaz.

## P6. Etiquetado e internación

**Respuesta SAGE:** impresión y recuperación según 03; circuito de guardia/internación y pantalla de extraccionistas según 01 y 07.

**Pendiente de Markey, SAGE y laboratorio:** confirmar el contexto de recepción/destino operativo, etiquetas y otros comprobantes, y precisar qué significa el cierre administrativo en internación, quién lo realiza y qué evento comunica la orden al LIS. Markey y SAGE deben aclarar la necesidad y alcance del eventual contrato adicional mencionado en el documento de origen. No se presupone que esa definición esté cerrada.

## P7. Eventos de integración

**No aplica a SAGE:** desarrollar los triggers de cierre/recepción y firma de orden internos de Markey; esa tarea está asignada a Markey.

**Participación SAGE:** validar que los mensajes representen órdenes e ítems y su ciclo de vida, y no solo Turnos. Participar en las pruebas de alta, modificación, cancelación, rechazo, reintento, secuencia y transición de estados de 05. Los hechos técnicos del LIS no deben sobrescribirse con una modificación administrativa.

**Pendiente de Markey:** completar los disparadores e informar qué evento emite cada mensaje. Los eventos de vuelta LIS → Markey y la conciliación se acuerdan según 08.

## P8. Centros y acceso

**No aplica a SAGE:** decidir la arquitectura y necesidad de endpoints independientes de Canning y Clínica; la evaluación corresponde a Markey e IT CMG. El documento de origen indica infraestructuras separadas y Canning solo ambulatorio.

**Participación SAGE:** aportar requisitos del receptor, identificación/correlación por centro y puestos de impresión, y participar en pruebas de los accesos acordados.

**Pendiente de Markey e IT CMG:** confirmar endpoints por centro y su relación con endpoints por ámbito, accesos, autenticación y conectividad. Mantener la identificación de sede/terminal y la unicidad de identificadores acordadas. Ver 03, 05 y 09.

## Respuestas necesarias para cerrar esta primera etapa

| Parte | Devolución esperada |
|---|---|
| Markey | Respuesta al contrato enviado; ejemplos generados desde HIS; disparadores por ámbito; gestión del regreso; receptor de fechas y mecanismo de eventos/conciliación. |
| Laboratorio CMG | Casos habituales del catálogo de cambios confirmados. Resta acordar pendientes/regresos, destino de comprobantes y reglas de ejecución compartidas, e incorporar nuevos casos si aparecen durante las pruebas. |
| Facturación / Laboratorio CMG | Hecho facturable, exclusiones, informes parciales y regla de corte/diferimiento. |
| IT CMG con Markey | Centros, accesos, endpoints e infraestructura para pruebas. |
| SAGE | Consolidar las devoluciones, relevar estados disponibles y ajustar especificaciones y pruebas del LIS. |

## Referencias documentales

- Resumen de definiciones Markey / SAGE de la reunión del 09/10/2026.
- Especificación del JSON de turnos requerida por SAGE, revisión documental 1.2 del 12/10/2026, enviada a Markey.

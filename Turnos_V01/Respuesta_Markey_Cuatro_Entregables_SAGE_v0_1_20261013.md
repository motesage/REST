# Integración Markey / SAGE: primera respuesta funcional

**Fecha:** 13/10/2026. **Versión:** 0.1, borrador para revisión SAGE.

Este documento reúne cuatro entregables para responder al resumen de la reunión del 09/10/2026. Distingue documentación elaborada, propuestas sujetas a validación y decisiones pendientes. No acredita implementación ni homologación de los circuitos descriptos.

## Texto de presentación sugerido

En respuesta al resumen de la reunión del 9 de octubre, compartimos una primera consolidación desde SAGE de los circuitos de integración, el estado del contrato JSON, el tratamiento de cambios posteriores a la recepción y los eventos necesarios para la continuidad operativa y la facturación.

La especificación JSON requerida por el LIS, revisión documental 1.2 del 12/10/2026, ya fue enviada a Markey. Solicitamos su devolución sobre los campos y reglas indicados, con conformidad, alternativa concreta o restricción, y ejemplos generados desde el HIS.

También hemos analizado un catálogo de cambios posteriores a la recepción, incluidas las adiciones tras la extracción. Sus criterios están pendientes del visto bueno de los usuarios del laboratorio y del acuerdo con Markey sobre los circuitos compartidos. Presentamos aquí su síntesis para anticipar los puntos de coordinación.

Los cuatro apartados siguientes permiten avanzar en esas definiciones. Las propuestas sobre estados, facturación y regreso del paciente necesitan validación conjunta antes de convertirse en especificaciones definitivas.

## Entregable 1. Matriz funcional de circuitos por ámbito

**Estado:** primera propuesta para validación de Markey, laboratorio e IT CMG.

### Circuito común propuesto

1. Markey registra la solicitud, identifica paciente, orden médica, ítems y ámbito, y completa las condiciones administrativas correspondientes.
2. El evento habilitante del circuito genera el JSON hacia SAGE. En ambulatorio es el cierre administrativo; en guardia/internación debe precisarse el evento equivalente.
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

### Impresión y recuperación

- SAGE asocia `recepcion.sedeId` y `recepcion.terminalId` con el destino de impresión; no lo infiere de la IP del servidor que envía el REST.
- Un puesto no homologado impide aceptar el alta que requiere impresión dirigida, conforme al contrato solicitado.
- Una falla temporal de impresora en un puesto homologado deja la impresión pendiente, conservando la boleta aceptada.
- Reenviar el mismo mensaje no debe generar otra boleta ni una nueva impresión automática. La reimpresión se gestiona como operación propia del LIS.

**Devolución solicitada:** confirmar disparadores por ámbito, puestos y destinos, tratamiento de órdenes internas/externas concurrentes, relación orden/Turno/episodio y necesidad de accesos diferenciados por centro. La asignación de endpoints por centro debe resolverse con Markey e IT CMG.

## Entregable 2. Estado del contrato JSON y plan de homologación

**Estado:** especificación SAGE elaborada y enviada a Markey, según confirmación de SAGE del 13/10/2026; pendiente de devolución, aprobación conjunta y homologación.

**Referencia:** `Especificacion_JSON_Turnos_Requerida_SAGE_v1_2_20261012.md`. La revisión documental es 1.2; la versión de contrato solicitada en `versionMensaje` es 1.0. Se conserva el objeto Turno en la raíz y el arreglo `practicas`; cualquier cambio de nomenclatura debe acordarse explícitamente.

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

## Entregable 3. Criterios para cambios y adiciones posteriores a la recepción

**Estado:** análisis realizado en SAGE; pendiente de visto bueno de los usuarios del laboratorio y acuerdo de interfaces/circuitos con Markey.

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

**Devolución solicitada:** acordar representación de regresos, vinculación de ítems, notificación LIS → Markey, autorizaciones por tipo de cambio y efecto sobre talones/etiquetas. El catálogo detallado se formalizará después de la validación de los usuarios del laboratorio.

## Entregable 4. Propuesta de estados/eventos y conciliación de facturación

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

Cada evento debería correlacionar Turno, orden médica y boleta; identificar los ítems/muestras afectados cuando corresponda; y llevar ID de evento, fecha/hora, versión y motivo. La estructura, entrega, confirmación y consulta de estos eventos quedan por acordar. No se agregan campos al contrato enviado mediante este borrador.

### Decisiones de negocio pendientes

- Hecho habilitante para facturar: admisión, toma de muestra, realización o informe, y posibles diferencias por ámbito/convenio.
- Tratamiento de informes parciales y prácticas realizadas sin informe final.
- Regla del corte del día 27: hora de corte, universo de casos, definición de “sin informe”, exclusiones y período al que se difieren.
- Tratamiento de rechazos, nuevas tomas, cancelaciones y correcciones después de facturar.
- Equivalencias entre procedimientos/prácticas del LIS y conceptos del nomenclador facturable.

SAGE propone aportar los hechos técnicos y de informes disponibles. Laboratorio y facturación deben confirmar cómo esos hechos determinan inclusión, exclusión o diferimiento; Markey debe confirmar su representación y aplicación administrativa.

### Conciliación propuesta

Comparar al corte las órdenes e ítems de Markey con boletas, ejecución e informes de SAGE. Identificar aceptados no reflejados, rechazos pendientes, duplicaciones, diferencias de versión y casos diferidos con motivo. Acordar responsable de resolución y seguimiento hasta el siguiente período, mediante consulta, reporte o interfaz según la solución definida.

## Respuestas necesarias para cerrar esta primera etapa

| Parte | Devolución esperada |
|---|---|
| Markey | Respuesta al contrato enviado; ejemplos generados desde HIS; disparadores por ámbito; gestión del regreso; receptor de fechas y mecanismo de eventos/conciliación. |
| Laboratorio CMG | Validación del catálogo de cambios, pendientes/regresos, destino de comprobantes y reglas de ejecución. |
| Facturación / Laboratorio CMG | Hecho facturable, exclusiones, informes parciales y regla de corte/diferimiento. |
| IT CMG con Markey | Centros, accesos, endpoints e infraestructura para pruebas. |
| SAGE | Consolidar las devoluciones, relevar estados disponibles y ajustar especificaciones y pruebas del LIS. |

## Fuentes de preparación

- Resumen Markey de la reunión del 09/10/2026, proporcionado por SAGE.
- Especificación JSON requerida por SAGE, revisión documental 1.2 del 12/10/2026.
- Análisis del chat “Armar catálogo de cambios LIS”, incluida la corrección sobre recitación y nueva admisión y su estado pendiente de visto bueno del laboratorio.
- Confirmación de SAGE del 13/10/2026 de que la especificación JSON ya fue enviada a Markey.

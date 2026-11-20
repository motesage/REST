# Especificación del JSON de turnos requerida por SAGE

**Integración:** Markey HIS → SageLab LIS. **Emisor de esta especificación:** SAGE. **Versión documental:** 1.2 propuesta, 12/10/2026. **Versión de contrato solicitada:** 1.0, en revisión. **Estado:** diseño solicitado para confirmación e implementación conjunta con Markey y CMG.

SAGE solicita el siguiente contrato para recibir turnos, validar el pedido, generar la boleta de laboratorio y dirigir la emisión de etiquetas y talón al puesto de recepción correspondiente. El contrato incluye trazabilidad, modificaciones, cancelaciones y devolución de fechas de entrega. Los requisitos necesarios para operar deben estar disponibles desde el inicio.

El diseño conserva el objeto denominado Turno en la raíz, sin envoltorio `Turno` ni `datos`, y extiende el ejemplo simplificado con los datos requeridos. Se basa en la [respuesta SAGE del 11/09/2026](https://docs.google.com/document/d/1D2dXM8LGvDTyglxleWnnpJpbpMImyOaQ/edit?usp=sharing), complementada con los requerimientos posteriores. Es una especificación solicitada por SAGE; no atribuye aprobación ni implementación a Markey.

La lectura de los cambios frente a la última respuesta entregada a Markey se encuentra en la sección 14: terminal y contexto de recepción, identificadores separados de orden médica y Turno, síntomas y concreción de operaciones ya propuestas.

## 1 Clasificación y convenciones

La columna **Clasificación** utiliza exclusivamente:

- **Existente (Markey):** dato presente en el ejemplo simplificado documental de Markey. No acredita emisión operativa ni aprobación de todas las reglas de esta especificación.
- **Pendiente solicitado previamente:** incorporación, ajuste de nombre o regla solicitada anteriormente por SAGE y sin confirmación suficiente en el contrato consolidado.
- **Nuevo requerido Sage:** nuevo dato o concreción estructural requerida por SAGE en este diseño.

La columna **Confirmación Markey** identifica explícitamente lo que debe validar el proveedor, aun cuando el campo ya exista. **S** = obligatorio; **C** = obligatorio bajo la condición indicada; **N** = opcional. La obligatoriedad de las tablas de solicitud se refiere a ALTA y MODIFICACION; CANCELACION tiene el cuerpo reducido definido en la sección 9.

Formato: JSON UTF-8, `Content-Type: application/json; charset=utf-8`, método POST. Las fechas sin hora son `YYYY-MM-DD`; las fechas/hora incluyen offset, por ejemplo `2026-10-12T10:30:00-03:00`. Booleanos reales, sin cadenas «true»/«false». Códigos e identificadores como String, sin perder ceros, cambiar mayúsculas ni convertir a número.

Campos S: no se admite ausencia, null ni cadena vacía. Campos C: el objeto/dato debe existir y ser válido si se cumple su condición. Campos N: pueden omitirse; las cadenas opcionales pueden usar `""`; no se usa null salvo donde se autoriza expresamente. Un campo omitido no se interpreta como instrucción de borrar información en maestros. En MODIFICACION se envía la instantánea completa de la versión, no un parche; las bajas de prácticas quedan identificadas por la comparación de ítems y sujetas a validación funcional.

Cada fila enumera una ruta. Los objetos contenedores se indican en el título de cada tabla y en el ejemplo; no poseen un valor escalar adicional. Los límites de longitud, tamaño y timeout deberán completarse con Markey antes de aprobar la versión final.

## 2 Identificación y control del mensaje

Campos a nivel raíz.

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 01 | `identificador` | String | S | ID estable del Turno Markey; único en el ámbito institucional acordado; no se reutiliza | Existente (Markey) | **CONFIRMAR** entidad, unicidad, persistencia al reprogramar y relación con turnId |
| 02 | `ordenMedicaId` | String | S | ID independiente de la orden/prescripción que origina este pedido; no confundir con Turno ni boleta | Nuevo requerido Sage | **CONFIRMAR NUEVO** ID disponible, nombre de origen y cardinalidad |
| 03 | `transaccionId` | String | S | ID único del mensaje lógico; se conserva en cada reintento idéntico | Pendiente solicitado previamente | **CONFIRMAR** generación y reutilización en reintentos |
| 04 | `versionMensaje` | String | S | Versión del contrato; valor solicitado para esta propuesta `1.0` | Pendiente solicitado previamente | **CONFIRMAR** aceptación y evolución compatible |
| 05 | `versionTurno` | Integer | S | 1 en alta; incremento secuencial al modificar/cancelar | Pendiente solicitado previamente | **CONFIRMAR** secuencia; concreta el versionado previamente propuesto |
| 06 | `operacion` | String | S | `ALTA`, `MODIFICACION` o `CANCELACION`; reenvío conserva operación original | Pendiente solicitado previamente | **CONFIRMAR** eventos y emisión de novedades |
| 07 | `fechaHoraMensaje` | String fecha/hora | S | Generación del mensaje, con offset; distinta de fecha de atención | Pendiente solicitado previamente | **CONFIRMAR** captura; concreta la trazabilidad fechaHora propuesta |
| 08 | `sistemaOrigen` | String | S | Valor `MARKEY` | Pendiente solicitado previamente | **CONFIRMAR** inclusión |
| 09 | `motivoOperacion` | String | C | No vacío en modificación o cancelación; puede omitirse en alta | Nuevo requerido Sage | **CONFIRMAR NUEVO** captura y autorización |

La relación de trabajo para este payload es **una orden médica de origen por mensaje de Turno**. Markey debe confirmar si su circuito cumple esa relación y si una orden puede producir varios turnos/boletas. Si un turno reúne varias órdenes, debe acordarse una representación por orden e ítem antes de aprobar el contrato; no se concatenarán IDs en un String ni se tomará solo uno. La devolución de SAGE conservará las referencias independientes.

## 3 Datos generales del turno

| Nº | Campo raíz | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 10 | `fecha` | String fecha/hora | S | Fecha/hora de atención prevista del Turno; en atención inmediata, fecha/hora de recepción asistencial acordada | Existente (Markey) | **CONFIRMAR** esta semántica y unificación con fechaInicio |
| 11 | `ambito` | String | S | `AMBULATORIO`, `INTERNADO` o `GUARDIA`; coincide con endpoint invocado | Existente (Markey) | **CONFIRMAR** catálogo y rutas por ámbito |
| 12 | `observaciones` | String | N | Observación general del pedido, conservada en la boleta | Existente (Markey) | Confirmar captura y continuidad en cambios |
| 13 | `urgente` | Boolean | S | Prioridad operativa; no sustituye ámbito | Existente (Markey) | Confirmar criterio de origen |
| 14 | `confidencial` | Boolean | S | true restringe la orden; false no levanta restricciones de prácticas del LIS | Existente (Markey) | **CONFIRMAR** regla acumulativa y aplicación en HIS |

`fecha` no representa fecha de toma ni de entrega. SAGE solicita conservar el nombre del ejemplo y retirar `fechaInicio` de la matriz para este contrato.

## 4 Paciente cobertura y médico

### Objeto paciente obligatorio

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 15 | `paciente.codigo` | String | S | ID del paciente en HIS; se conserva como referencia externa | Existente (Markey) | **CONFIRMAR** estabilidad y conciliación con identidad documental |
| 16 | `paciente.tipoDocumento` | String | S | Código del catálogo acordado; contempla RN1, RN2, RN3 y tipos temporales autorizados | Existente (Markey) | **CONFIRMAR** catálogo y emisión RN |
| 17 | `paciente.numeroDocumento` | String | S | Junto con tipo identifica al paciente; RN usa documento materno conforme a regla del laboratorio | Existente (Markey) | **CONFIRMAR** RN y regla explícita para pacientes sin documento; no inventar DNI |
| 18 | `paciente.nombres` | String | S | Nombre(s) completo(s); nombre contractual del ejemplo | Existente (Markey) | Confirmar sustitución de nombre en matriz |
| 19 | `paciente.apellidoPaterno` | String | S | Apellido(s) necesarios para identificar/imprimir; sin pérdida de apellidos de origen | Existente (Markey) | **CONFIRMAR** correspondencia con apellido y tratamiento de otros apellidos |
| 20 | `paciente.fechaNacimiento` | String fecha | S | Fecha válida, no futura; excepción por dato desconocido requiere regla autorizada antes de operar | Existente (Markey) | **CONFIRMAR** disponibilidad y excepciones |
| 21 | `paciente.sexo` | String | S | Valor del catálogo acordado con SAGE; no inferido del nombre | Existente (Markey) | **CONFIRMAR** valores y correspondencia |
| 22 | `paciente.contacto.telefono` | String | N | Contacto para re-citación; enviar si está disponible | Existente (Markey) | Confirmar actualización y disponibilidad |
| 23 | `paciente.contacto.email` | String | N | Correo de contacto | Existente (Markey) | Confirmar actualización |
| 24 | `paciente.contacto.domicilio` | String | N | Domicilio registrado | Existente (Markey) | Confirmar actualización |

`paciente.contacto` es opcional. No se solicita campo WhatsApp separado. Conflictos entre código HIS y tipo/número de documento requieren rechazo o revisión explícita, sin sobrescribir identidad silenciosamente. Las excepciones por desconocimiento de datos no se resuelven enviando fechas o documentos ficticios.

### Objeto obraSocial obligatorio

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 25 | `obraSocial.codigo` | String | S | Código válido de matriz homologada; incluye PARTICULAR y SIN COBERTURA; nunca vacío | Existente (Markey) | **CONFIRMAR CAMBIO PREVIO** regla obligatoria y matriz sincronizada |
| 26 | `obraSocial.nombre` | String | S | Descripción de cobertura; no sustituye código | Existente (Markey) | Confirmar consistencia con maestro |
| 27 | `obraSocial.plan` | String | C | Código de plan cuando cobertura lo requiere; omitir/vacío si no aplica | Existente (Markey) | **CONFIRMAR** que se transmite código; precisar equivalencias |
| 28 | `obraSocial.numeroAfiliado` | String | C | Obligatorio cuando cobertura/plan lo exige | Existente (Markey) | **CONFIRMAR** condiciones |

Cobertura desconocida no se crea automáticamente. Se responde error funcional y se corrige/homologa antes de reenviar.

### Objeto medico y matricula obligatorios

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 29 | `medico.codigo` | String | S | Código válido del maestro de solicitantes | Existente (Markey) | **CONFIRMAR** sincronización y desconocidos |
| 30 | `medico.tipoDocumento` | String | N | Tipo de documento del profesional | Existente (Markey) | Confirmar disponibilidad |
| 31 | `medico.numeroDocumento` | String | N | Documento del profesional | Existente (Markey) | Confirmar disponibilidad |
| 32 | `medico.nombres` | String | S | Nombres del solicitante | Existente (Markey) | Confirmar nombre contractual |
| 33 | `medico.apellidoPaterno` | String | S | Apellido(s) del solicitante | Existente (Markey) | Confirmar nombre contractual |
| 34 | `medico.matricula.numero` | String | S | Matrícula, sin conversión numérica | Existente (Markey) | Confirmar formato |
| 35 | `medico.matricula.provincia` | String | C | Jurisdicción obligatoria para matrícula provincial; omitible/vacía cuando no aplica | Existente (Markey) | **CONFIRMAR** catálogo y reglas por tipo |
| 36 | `medico.matricula.tipo` | String | S | Tipo de matrícula del catálogo acordado, por ejemplo MP/MN | Existente (Markey) | **CONFIRMAR** catálogo |
| 37 | `medico.contacto.telefono` | String | N | Contacto del solicitante | Existente (Markey) | Confirmar disponibilidad |
| 38 | `medico.contacto.email` | String | N | Minúscula email, uniforme con paciente | Pendiente solicitado previamente | **CONFIRMAR CAMBIO PREVIO** sustitución de Email |
| 39 | `medico.contacto.domicilio` | String | N | Domicilio del profesional | Existente (Markey) | Confirmar disponibilidad |

`medico.contacto` es opcional. Especialidad y CUIT no se requieren en este diseño.

## 5 Institución diagnóstico y ubicación del paciente

### Objeto institucionSolicitante obligatorio

Se solicita sustituir `laboratorio` por `institucionSolicitante`. Cambia el nombre del nodo, conservando los datos de institución de origen; no identifica el puesto de recepción ni la ubicación del paciente.

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 40 | `institucionSolicitante.codigo` | String | S | Código válido del maestro de instituciones/orígenes | Pendiente solicitado previamente | **CONFIRMAR CAMBIO PREVIO** equivalencia con laboratorio.codigo |
| 41 | `institucionSolicitante.nombre` | String | S | Nombre de institución solicitante | Pendiente solicitado previamente | **CONFIRMAR CAMBIO PREVIO** equivalencia con laboratorio.nombre |
| 42 | `institucionSolicitante.contacto.telefono` | String | N | Contacto de institución | Pendiente solicitado previamente | Confirmar traslado del nodo |
| 43 | `institucionSolicitante.contacto.email` | String | N | Contacto de institución | Pendiente solicitado previamente | Confirmar traslado del nodo |
| 44 | `institucionSolicitante.contacto.domicilio` | String | N | Domicilio institucional | Pendiente solicitado previamente | Confirmar traslado del nodo |

El objeto contacto es opcional. CUIT institucional no se solicita. El origen local debe usar un código homologado, no un laboratorio/financiador ficticio.

### Objeto diagnostico condicional

SAGE solicita transportar el diagnóstico cuando exista en el pedido. No será por sí solo condición obligatoria para todas las órdenes: la obligatoriedad por circuito debe confirmarse con el laboratorio y Markey.

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 45 | `diagnostico.codigo` | String | C | Si se informa diagnóstico codificado, enviar código de catálogo acordado | Pendiente solicitado previamente | **CONFIRMAR** inclusión, catálogo y tipo String |
| 46 | `diagnostico.descripcion` | String | C | No vacía si existe el objeto; permite diagnóstico textual sin código | Pendiente solicitado previamente | **CONFIRMAR** emisión y obligatoriedad por circuito |

No se adopta la observación equivocada de la matriz que identifica diagnóstico con institución. Si no hay diagnóstico, se omite el objeto; no se exige alta automática de un código desconocido.

### Objeto ubicacionPaciente condicional

Obligatorio para internados y guardia cuando el laboratorio deba localizar al paciente para extracción. Los nombres concretan el pedido previo de habitación/cama o equivalente.

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 47 | `ubicacionPaciente.codigo` | String | C | Código de ubicación vigente cuando Markey usa un maestro de ubicación | Pendiente solicitado previamente | **CONFIRMAR** origen y equivalencia |
| 48 | `ubicacionPaciente.descripcion` | String | S dentro del objeto | Ubicación suficiente para localizar al paciente; no vacía | Pendiente solicitado previamente | **CONFIRMAR** precisión y actualización |
| 49 | `ubicacionPaciente.habitacion` | String | C | Obligatoria cuando la ubicación incluye habitación | Pendiente solicitado previamente | **CONFIRMAR** dato disponible |
| 50 | `ubicacionPaciente.cama` | String | C | Obligatoria cuando hay cama asignada | Pendiente solicitado previamente | **CONFIRMAR** dato disponible y cambios |

La ubicación no identifica al paciente. Cambios posteriores deben llegar mediante modificación o mecanismo de actualización acordado. No se envía este objeto para sustituir `recepcion.terminalId`.

## 6 Datos de recepción y puesto de impresión

Objeto `recepcion` obligatorio. Identifica el puesto que confirma la recepción administrativa, aunque la prescripción se haya creado en otro equipo y el REST salga de un servidor central.

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 51 | `recepcion.terminalId` | String | S | ID estable del puesto lógico de recepción; SAGE lo asocia a impresoras de etiquetas y talón | Nuevo requerido Sage | **CONFIRMAR NUEVO** captura fiable en cliente/sesión de origen |
| 52 | `recepcion.sedeId` | String | S | Sede que delimita unicidad del puesto; código homologado | Nuevo requerido Sage | **CONFIRMAR NUEVO** catálogo y unicidad de pareja sede/terminal |
| 53 | `recepcion.usuarioId` | String | S | Operador que confirma la recepción; referencia auditable | Nuevo requerido Sage | **CONFIRMAR NUEVO** identidad de usuario |
| 54 | `recepcion.fechaHora` | String fecha/hora | S | Momento de confirmación administrativa con offset | Nuevo requerido Sage | **CONFIRMAR NUEVO** evento exacto |
| 68 | `recepcion.sintomas` | String de longitud variable | N | Síntomas recogidos en la entrevista de recepción; dato independiente de observaciones y diagnóstico | Nuevo requerido Sage | **CONFIRMAR NUEVO** captura, transmisión íntegra y límite técnico acordado |

### Síntomas recogidos durante la recepción

`recepcion.sintomas` contiene el texto obtenido en la entrevista de recepción del paciente. Es un String de longitud variable; admite Unicode y saltos de línea mediante escapes JSON. Se conserva íntegramente, sin truncamiento silencioso. No se establece un máximo funcional en esta propuesta: el límite técnico de almacenamiento y transporte debe acordarse entre Markey y SAGE antes de implementar.

Se propone como campo opcional: enviar cuando se haya registrado; puede omitirse o ser una cadena vacía si no se registró. Una cadena vacía no significa ausencia de síntomas. Si el paciente declara no tener síntomas, se transmite el texto registrado expresamente. No se genera automáticamente un diagnóstico a partir de este dato.

- `recepcion.sintomas`: relato obtenido en la entrevista de recepción.
- `observaciones`: comentario general del pedido.
- `practicas[].observaciones`: comentario de una práctica concreta.
- `diagnostico`: diagnóstico clínico informado en el pedido.

Se almacenan por separado, sin concatenarlos ni sustituir uno por otro. En MODIFICACION se reenvía el texto vigente como parte de la instantánea completa; una corrección queda auditada con el objeto cambio. Omitir o vaciar el campo en esa instantánea retira el texto vigente de esa versión, conservando el historial. El puesto, usuario y fecha de recepción original se conservan; un reintento idéntico no agrega una nueva entrevista.

El Nº 68 se incorpora conservando los números 01–67 para mantener estables las referencias de revisión.

SAGE dirige la impresión al puesto indicado, usando configuración local validada con CMG. No se deduce el puesto a partir de IP, usuario o sistemaOrigen. No se envían nombres libres de impresora en este contrato.

Si un pedido de internación/guardia se emite sin recepción en un puesto, Markey debe confirmarlo: se requiere definir el puesto operativo/destino de ese circuito antes de homologarlo; no se inventará una terminal. La recepción automatizada deberá tener un destino conocido y una regla de operador auditable acordada.

En MODIFICACION se conserva el contexto de recepción original. La auditoría del actor de cambio se informa en un objeto independiente `cambio`, obligatorio para modificación/cancelación, cuyos campos son:

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 55 | `cambio.usuarioId` | String | C | Usuario autorizado que confirma la novedad | Nuevo requerido Sage | **CONFIRMAR NUEVO** captura |
| 56 | `cambio.fechaHora` | String fecha/hora | C | Fecha/hora de la novedad funcional | Nuevo requerido Sage | **CONFIRMAR NUEVO** captura |

Una reimpresión desde otro puesto será una acción explícita de SAGE con motivo y permisos; un reenvío del Turno no ordena reimprimir.

## 7 Prácticas e importes

### Arreglo practicas obligatorio con al menos un ítem

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 57 | `practicas[].itemId` | String | S | Identifica la ocurrencia de práctica dentro del Turno; estable en modificaciones; sin reutilización | Nuevo requerido Sage | **CONFIRMAR NUEVO** ID de detalle disponible |
| 58 | `practicas[].codigo` | String | S | Código exacto del catálogo; o105 y O105 son diferentes | Existente (Markey) | **CONFIRMAR CAMBIO PREVIO** preservación sensible a mayúsculas extremo a extremo |
| 59 | `practicas[].nombre` | String | S | Descripción de la práctica; mantener nombre del ejemplo | Existente (Markey) | Confirmar unificación con descripcion en matriz |
| 60 | `practicas[].cantidad` | Integer | S | Entero positivo; enviar explícitamente 1 cuando corresponda | Pendiente solicitado previamente | **CONFIRMAR** emisión; omisión solo mediante acuerdo expreso si siempre vale 1 |
| 61 | `practicas[].observaciones` | String | N | Enviar cuando existan indicaciones de la práctica | Pendiente solicitado previamente | **CONFIRMAR** conservación |
| 62 | `practicas[].muestra` | Boolean | S | true: material aportado/disponible declarado en recepción para ese ítem; false: no disponible en ese momento | Pendiente solicitado previamente | **CONFIRMAR SEMÁNTICA** captura y aplicabilidad por circuito |
| 63 | `practicas[].importePaciente` | Number | S | Total del ítem a cargo del paciente, incluida cantidad; cero si no corresponde | Pendiente solicitado previamente | **CONFIRMAR** emisión y equivalencia con procImportePaciente |
| 64 | `practicas[].importeMutual` | Number | S | Total del ítem a cargo del financiador, incluida cantidad | Pendiente solicitado previamente | **CONFIRMAR** emisión y equivalencia con procImporteMutual |

`muestra` no afirma aptitud, toma efectiva ni aceptación técnica del material; esas validaciones corresponden al laboratorio. En una práctica sin material requerido, se solicita false y SAGE determina el circuito a partir del catálogo. Si el HIS no conoce la disponibilidad no debe convertir desconocido en false: debe resolverse captura/flujo antes del envío funcional o acordarse expresamente un tercer estado y nueva versión de contrato.

Tipo de muestra, recipientes y tomas se gestionan inicialmente por las reglas del catálogo y el circuito SAGE. Si un código de práctica no determina inequívocamente la muestra, deberá añadirse el dato correspondiente antes de homologar ese caso. El código facturable no identifica cada determinación del resultado.

### Objeto administrativo obligatorio

| Nº | Campo | Tipo | Req. | Regla SAGE | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| 65 | `administrativo.importeTotalPaciente` | Number | S | Total a cargo del paciente por los ítems enviados | Pendiente solicitado previamente | **CONFIRMAR** emisión y conciliación con suma de ítems |
| 66 | `administrativo.importeTotalMutual` | Number | S | Total a cargo del financiador por los ítems enviados | Pendiente solicitado previamente | **CONFIRMAR** emisión y conciliación con suma de ítems |
| 67 | `administrativo.importeCobrado` | Number | S | Cobrado efectivo correspondiente al pedido al momento del envío; no confundir con a cobrar | Pendiente solicitado previamente | **CONFIRMAR** asignación de cobro al pedido y actualización |

Importes en pesos argentinos, números JSON no negativos con hasta dos decimales, sin separadores de miles ni cadenas vacías; cálculo interno con precisión decimal. Los totales son la suma de los ítems de este mensaje. Si Markey aplica descuentos/ajustes que rompen esa igualdad, debe proponer campos explícitos antes de aprobación; no se ignorará la diferencia. Devoluciones u operaciones contables negativas requieren un circuito administrativo específico, no cambiar silenciosamente el significado de estos campos.

## 8 Fechas de entrega y respuesta SAGE

SAGE requiere la modalidad de cálculo y confirmación posterior a la recepción establecida como preferida en la respuesta del 11/09: Markey envía los datos anteriores; Sage calcula una o dos fechas, permite ajuste autorizado mediante pantalla operativa mínima y las devuelve al HIS. No se exige que Markey replique el cálculo del nomenclador ni envíe fechas de entrega en el request.

La aceptación funcional y la confirmación de fechas/impresión pueden ocurrir en momentos distintos. Una boleta aceptada con fechas pendientes conserva su ID. Al confirmar o modificar fechas, SAGE emitirá la devolución operativa y Markey deberá almacenarla. Ambas estructuras se enumeran por separado para no confundir request y response.

### Respuesta funcional inmediata SAGE → Markey

| Nº | Campo | Tipo | Req. | Regla | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| R01 | `ok` | Boolean | S | true solo cuando operación funcional fue aplicada durablemente; false en rechazo | Pendiente solicitado previamente | **CONFIRMAR** interpretación |
| R02 | `transaccionId` | String | C | Eco del request si pudo leerse; omitido en JSON ilegible | Pendiente solicitado previamente | **CONFIRMAR** correlación |
| R03 | `codigo` | String | S | Código funcional estable | Pendiente solicitado previamente | **CONFIRMAR** tratamiento de catálogo |
| R04 | `mensaje` | String | S | Descripción legible para operador/soporte | Pendiente solicitado previamente | Confirmar visualización |
| R05 | `identificador` | String | C | Turno si pudo identificarse | Pendiente solicitado previamente | **CONFIRMAR** correlación |
| R06 | `ordenMedicaId` | String | C | Orden origen si pudo identificarse | Nuevo requerido Sage | **CONFIRMAR NUEVO** correlación |
| R07 | `versionTurno` | Integer | C | Versión aplicada en éxito; omitida si ninguna fue aplicada | Pendiente solicitado previamente | **CONFIRMAR** control de versión |
| R08 | `boletaSageId` | String | C | Boleta correlacionada en éxito; misma en retransmisión válida | Pendiente solicitado previamente | **CONFIRMAR** equivalencia con protocoloSageLab previamente propuesto |

### Devolución operativa de fechas SAGE → Markey

Mensaje adicional después de confirmar las fechas, y al modificarlas. Endpoint receptor por definir con Markey. Este mensaje tiene objeto raíz propio, no es un Turno entrante.

| Nº | Campo | Tipo | Req. | Regla | Clasificación | Confirmación Markey |
|---|---|---|---|---|---|---|
| D01 | `transaccionId` | String | S | ID SAGE, estable al reintentar | Pendiente solicitado previamente | **CONFIRMAR** recepción idempotente |
| D02 | `versionMensaje` | String | S | `1.0` | Pendiente solicitado previamente | Confirmar versión |
| D03 | `sistemaOrigen` | String | S | `SAGELAB` | Pendiente solicitado previamente | Confirmar origen |
| D04 | `fechaHoraMensaje` | String fecha/hora | S | Fecha/hora de emisión SAGE | Pendiente solicitado previamente | Confirmar formato |
| D05 | `identificador` | String | S | Turno relacionado | Pendiente solicitado previamente | **CONFIRMAR** correlación |
| D06 | `ordenMedicaId` | String | S | Orden origen relacionada | Nuevo requerido Sage | **CONFIRMAR NUEVO** correlación |
| D07 | `boletaSageId` | String | S | Boleta relacionada | Pendiente solicitado previamente | Confirmar almacenamiento |
| D08 | `versionEntrega` | Integer | S | Versión secuencial de fechas por boleta; no sobrescribir con versión anterior | Nuevo requerido Sage | **CONFIRMAR NUEVO** control de novedades |
| D09 | `fechaEntrega1` | String fecha | S | Primera fecha confirmada para talón/HIS | Pendiente solicitado previamente | **CONFIRMAR** persistencia y visualización |
| D10 | `fechaEntrega2` | String fecha o null | S | Segunda fecha cuando aplica; null elimina una segunda fecha anterior | Pendiente solicitado previamente | **CONFIRMAR** segunda fecha y null explícito |

Markey confirma aplicación devolviendo `ok`, `transaccionId`, `codigo` y `mensaje` con los tipos anteriores. La nueva versión permite retirar una segunda fecha mediante null; omitir D10 no es válido. Entrega 2, cuando existe, no puede preceder a entrega 1. Las fechas describen compromisos de entrega, no garantizan que todos los resultados estén validados ese día.

## 9 Altas modificaciones cancelaciones y reenvíos

**ALTA:** todos los campos S de solicitud y los C aplicables; versionTurno 1; al menos una práctica. SAGE valida paciente, referencias maestras y datos administrativos antes de crear boleta y correlación.

**MODIFICACION:** mismo identificador y ordenMedicaId; nueva transaccionId y siguiente versionTurno; motivoOperacion y cambio obligatorios. Se envía el pedido completo actualizado y se conservan itemId de prácticas que continúan. Un ítem nuevo recibe un nuevo itemId; retirar uno significa que deja de figurar en la nueva instantánea. SAGE compara, verifica estado y acepta o rechaza el conjunto de cambios; no se aplica parcialmente ni se retiran prácticas ejecutadas sin regla autorizada. La última práctica no puede retirarse mediante arreglo vacío: solicitar CANCELACION.

**CANCELACION:** cuerpo reducido con los campos 01–09, `ambito` (11) y `cambio` (55–56). motivoOperacion no vacío. No requiere paciente, maestros, importes ni prácticas. SAGE conserva boleta e historial y decide según estado real. Cancelar Turno/boleta no significa borrar orden clínica ni resultados históricos; Markey debe confirmar efecto en su modelo. Cancelación parcial se expresa como modificación de ítems.

**Reenvío:** misma transaccionId y mismo contenido; no se incrementa versión ni se genera nueva boleta/impresión. Tras rechazo funcional sin aplicación, la corrección usa nueva transaccionId manteniendo la versión esperada todavía no aplicada. Si se perdió la respuesta, primero se reintenta el mismo mensaje: no asumir rechazo ni fabricar una nueva alta.

Una versión aplicada que llega con contenido diferente se rechaza por conflicto. Mensajes fuera de secuencia se rechazan y concilian; no se aplica una versión anterior sobre una posterior. Cambiar ordenMedicaId en un Turno ya aplicado requiere resolver vinculación o nueva orden, no una actualización silenciosa.

## 10 Errores y confirmaciones operativas

HTTP 200: operación funcional aplicada o retransmisión ya aplicada. HTTP 400: JSON/formato/obligatorio inválido. HTTP 401/403: autenticación/permisos. HTTP 409: identidad, estado o versión conflictivos. HTTP 422: referencia maestra o dato funcional no válido. HTTP 500/503: fallo interno/no disponibilidad. Estos códigos son el contrato solicitado; no describen el receptor RAW de prueba actual.

Catálogo funcional mínimo solicitado: `OK`, `YA_PROCESADA`, `MENSAJE_INVALIDO`, `CAMPO_OBLIGATORIO_FALTANTE`, `PACIENTE_DATOS_CONFLICTIVOS`, `ORDEN_DATOS_CONFLICTIVOS`, `VERSION_NO_ADMITIDA`, `PRACTICA_NO_HOMOLOGADA`, `COBERTURA_NO_HOMOLOGADA`, `MEDICO_NO_HOMOLOGADO`, `INSTITUCION_NO_HOMOLOGADA`, `FECHA_INVALIDA`, `AMBITO_INVALIDO`, `TERMINAL_NO_HOMOLOGADA`, `MODIFICACION_NO_ADMITIDA`, `CANCELACION_NO_ADMITIDA`, `ORDEN_NO_ENCONTRADA`, `ERROR_INTERNO`, `SERVICIO_NO_DISPONIBLE`. Markey debe mapearlos a corrección por operador o reintento técnico según corresponda.

Puesto no homologado impide aceptar el alta que necesita impresión dirigida. Un puesto homologado temporalmente desconectado o una impresora averiada permite conservar la boleta aceptada y dejar impresión pendiente visible. La respuesta funcional no certifica impresión física. El envío a cola, salida física y reimpresión tienen seguimiento propio en SAGE; no se repite el alta para resolverlos.

Los endpoints diferenciados por AMBULATORIO/INTERNADO/GUARDIA utilizarán estas convenciones comunes, con campos condicionales según circuito. URLs, autenticación, timeout, tamaños máximos y mecanismo de consulta/conciliación deben confirmarse antes de homologación integral.

## 11 Ejemplo completo de alta ambulatoria con tres prácticas

Datos ficticios para ilustrar el contrato solicitado. Se incluyen 475 Hemograma con muestra true, 481 Hepatograma con muestra true y O105 Urocultivo con muestra false. Los importes son ilustrativos, no aranceles del catálogo. Síntomas, observaciones y diagnóstico contienen textos diferentes para mostrar su independencia. Códigos de maestros y puestos deben sustituirse por valores homologados. El diagnóstico se incluye como caso opcional; ubicacionPaciente se omite por no requerirse en este ejemplo.

```json
{
  "identificador": "TURNO-000012",
  "ordenMedicaId": "OM-000640041",
  "transaccionId": "MK-20261012-000001",
  "versionMensaje": "1.0",
  "versionTurno": 1,
  "operacion": "ALTA",
  "fechaHoraMensaje": "2026-10-12T10:30:05-03:00",
  "sistemaOrigen": "MARKEY",
  "fecha": "2026-10-12T10:30:00-03:00",
  "ambito": "AMBULATORIO",
  "observaciones": "Recepción de prueba para homologación del circuito HIS/LIS.",
  "urgente": false,
  "confidencial": false,
  "paciente": {
    "codigo": "PAC-000001",
    "tipoDocumento": "DNI",
    "numeroDocumento": "00000001",
    "nombres": "PACIENTE DE PRUEBA",
    "apellidoPaterno": "HOMOLOGACION",
    "fechaNacimiento": "1980-01-01",
    "sexo": "F",
    "contacto": {
      "telefono": "",
      "email": "",
      "domicilio": ""
    }
  },
  "obraSocial": {
    "codigo": "COB-PRUEBA",
    "nombre": "PARTICULAR",
    "plan": "",
    "numeroAfiliado": ""
  },
  "medico": {
    "codigo": "MED-PRUEBA",
    "nombres": "PROFESIONAL",
    "apellidoPaterno": "DE PRUEBA",
    "matricula": {
      "numero": "00001",
      "provincia": "BUENOS AIRES",
      "tipo": "MP"
    },
    "contacto": {
      "telefono": "",
      "email": "",
      "domicilio": ""
    }
  },
  "institucionSolicitante": {
    "codigo": "INST-PRUEBA",
    "nombre": "INSTITUCION DE PRUEBA"
  },
  "diagnostico": {
    "descripcion": "Diagnóstico textual de prueba informado en el pedido."
  },
  "recepcion": {
    "terminalId": "RECEPCION-LAB-02",
    "sedeId": "CMG",
    "usuarioId": "OPERADOR-017",
    "fechaHora": "2026-10-12T10:30:00-03:00",
    "sintomas": "Durante la entrevista de recepción el paciente refiere cansancio y molestias al orinar."
  },
  "practicas": [
    {
      "itemId": "ITEM-001",
      "codigo": "475",
      "nombre": "Hemograma",
      "cantidad": 1,
      "observaciones": "",
      "muestra": true,
      "importePaciente": 1000,
      "importeMutual": 0
    },
    {
      "itemId": "ITEM-002",
      "codigo": "481",
      "nombre": "Hepatograma",
      "cantidad": 1,
      "observaciones": "",
      "muestra": true,
      "importePaciente": 2000,
      "importeMutual": 0
    },
    {
      "itemId": "ITEM-003",
      "codigo": "O105",
      "nombre": "Urocultivo",
      "cantidad": 1,
      "observaciones": "Muestra no aportada al momento de la recepción de prueba.",
      "muestra": false,
      "importePaciente": 3000,
      "importeMutual": 0
    }
  ],
  "administrativo": {
    "importeTotalPaciente": 6000,
    "importeTotalMutual": 0,
    "importeCobrado": 6000
  }
}
```

## 12 Confirmaciones solicitadas a Markey

SAGE solicita respuesta por número de campo con: conforme, alternativa concreta o restricción, junto con ejemplo generado por el circuito del HIS. Se priorizan:

1. Identificadores de orden médica/Turno e ítems; cardinalidades y estabilidad durante cambios y re-citación.
2. Identificación real del puesto de recepción y asociación con destino de impresión por ámbito.
3. Síntomas recogidos en la entrevista: transmisión íntegra en campo separado y límite técnico acordado.
4. Muestra por práctica, códigos sensibles a mayúsculas, cantidades y disponibilidad de maestros.
5. Importes por ítem y totales, cobrado y conciliación.
6. Modalidad de cálculo de fechas por SAGE y recepción de sus novedades en Markey.
7. Nombres y tipos de campos, reglas condicionales, valores especiales de paciente y ubicación.
8. Eventos de envío, modificación/cancelación, respuesta funcional y recuperación de reintentos.

La confirmación debe acompañarse de un JSON completo generado desde Markey y pruebas de alta, rechazo, reenvío sin duplicación, cambio de prácticas y recepción desde dos puestos diferentes. El arranque requiere validar el circuito funcional, incluyendo talón y etiquetas, y no solo la recepción HTTP.

## 13 Respaldo documental

Base de diseño: [respuesta técnica SAGE del 11/09/2026](https://docs.google.com/document/d/1D2dXM8LGvDTyglxleWnnpJpbpMImyOaQ/edit?usp=sharing). Respaldo del relevamiento y clasificación: [reporte documental del 12/10/2026](C:/DelphiWork/REST/Turnos_V01/Reporte_Especificacion_JSON_Turnos_20261012.md), conservado sin cambios como fuente del análisis. Este diseño concreta requisitos de SAGE y distingue nuevas incorporaciones; debe obtener confirmación conjunta antes de tratarlo como contrato aprobado.


## 14 Cambios respecto de la última respuesta entregada a Markey

**Base de comparación:** respuesta técnica SAGE del **11/09/2026**, identificada como último documento intercambiado. Este apartado compara el diseño solicitado con ese documento, no solamente con las revisiones internas 1.0 y 1.1. Las referencias a agosto indican antecedentes documentales de SAGE; no certifican aceptación o implementación por Markey.

### Nuevos requerimientos y ampliaciones

| Cambio | Campos de esta especificación | Respecto de la respuesta del 11/09 | Confirmación requerida de Markey |
|---|---|---|---|
| Terminal que confirma la recepción y destino de impresión | Nº 51 `recepcion.terminalId`; Nº 52 `recepcion.sedeId`; Nº 53 `recepcion.usuarioId`; Nº 54 `recepcion.fechaHora` | **NUEVO REQUERIDO SAGE.** El documento anterior proponía pantalla mínima e impresión, pero no identificaba el puesto receptor ni estos campos. SAGE requiere el contexto completo para dirigir etiquetas y talón a ese puesto. | Captura del puesto real, sede, operador y momento de confirmación; unicidad sede/terminal; funcionamiento en cliente local o sesión remota; destino para cada ámbito. |
| Identificador independiente de orden médica | Nº 02 `ordenMedicaId`, y eco R06/D06 | **NUEVO REQUERIDO SAGE.** El documento anterior proponía conservar Turno.identificador como referencia externa y preguntaba si Turno representaba inequívocamente una orden. No especificaba simultáneamente dos IDs independientes. Ahora se exige distinguir orden/prescripción y Turno. | ID propio de orden médica, nombre en Markey, unicidad, estabilidad y relaciones uno a uno/uno a varios; referencias que requiere para asociar resultados. |
| Identificación única y estable del Turno | Nº 01 `identificador` | **PENDIENTE SOLICITADO PREVIAMENTE EN SU REGLA.** El campo ya estaba en el ejemplo Markey y SAGE ya pedía estabilidad en reenvíos, modificaciones y cancelaciones. El diseño actual explicita unicidad y lo separa de ordenMedicaId. Su clasificación como Existente (Markey) se refiere al campo, no a confirmación de la regla. | Qué entidad identifica, ámbito de unicidad, no reutilización, permanencia al reprogramar y relación con turnId; independencia respecto de ordenMedicaId. |
| Síntomas recogidos en recepción | Nº 68 `recepcion.sintomas` | **NUEVO REQUERIDO SAGE.** String de longitud variable obtenido de la entrevista, separado de observaciones generales, observaciones de práctica y diagnóstico. | Captura y envío íntegro; tratamiento de no registrado y límite técnico sin truncamiento silencioso. |
| Identificador de cada ítem de práctica | Nº 57 `practicas[].itemId` | **NUEVO REQUERIDO SAGE.** El documento anterior aceptaba código + nombre, pero no distinguía ocurrencias de una práctica mediante un ID de detalle. | ID disponible, estabilidad y no reutilización para agregado/retiro selectivo y prácticas repetidas. |
| Motivo y auditoría de novedades | Nº 09 `motivoOperacion`; Nº 55 `cambio.usuarioId`; Nº 56 `cambio.fechaHora` | **NUEVO REQUERIDO SAGE EN ESTOS CAMPOS.** Concreta trazabilidad de quién confirma una modificación/cancelación y por qué, conservando el contexto de recepción original. | Captura y permisos; motivo obligatorio en cambios/cancelación. |
| Versión de fechas de entrega | D08 `versionEntrega` | **NUEVO REQUERIDO SAGE EN ESTE CAMPO.** La devolución de una o dos fechas ya se pedía; ahora se controla el orden de sus novedades y la eliminación explícita de una segunda fecha mediante D10 null. | Recepción idempotente, versiones y retirada de fechaEntrega2 anterior. |

### Operación ALTA y control del ciclo de vida

**La operación ALTA no aparece por primera vez en este diseño.**

- En la [propuesta técnica SAGE del 27/08/2026](https://docs.google.com/document/d/1Y_qqR4xB9NnLUvevR70M-WFmaxNttVZL/edit), el campo `operacion` estaba definido con valores `ALTA / MODIFICACION / CANCELACION`, y el ejemplo incluía `"operacion": "ALTA"` dentro de `datos`, junto con `idOrdenMarkey` y `versionOrden`.
- En la [respuesta SAGE del 11/09/2026](https://docs.google.com/document/d/1D2dXM8LGvDTyglxleWnnpJpbpMImyOaQ/edit), la sección 6 describe alta, reenvío, modificación y cancelación y presenta un ejemplo secuencial con `Mensaje 1 → ALTA`. También solicita confirmar ese flujo. No incorpora un JSON completo con el campo operacion en la raíz.
- En este diseño se concreta `operacion` en la raíz del Turno y se precisan cuerpo de cada operación, instantánea completa de modificación, cancelación reducida, versiones, tratamiento de corrección tras rechazo y reenvíos sin nueva impresión.

Por ello el Nº 06 mantiene **Pendiente solicitado previamente**. La **ubicación del campo y las reglas detalladas de esta especificación requieren confirmación actual**; el antecedente no demuestra que Markey ya los implemente. Un reenvío técnico conserva ALTA/MODIFICACION/CANCELACION y la misma transaccionId; no se agrega REENVIO como cuarta operación funcional.

### Solicitudes anteriores que se conservan y concretan

| Tema | Antecedente de la respuesta del 11/09 | Concreción en este diseño y confirmación requerida |
|---|---|---|
| Transacción independiente del Turno | Solicitada expresamente | Nº 03 y controles de mensaje 04–08; propuesta previa de agosto aporta versión/origen/fecha. Confirmar nombres, ubicación y generación. |
| Cobertura codificada | Código obligatorio incluso PARTICULAR/SIN COBERTURA; desconocidos sin alta automática | Nº 25–28; confirmar matriz, plan y condiciones. |
| Paciente y recién nacidos | Tipo + documento y RN1/RN2/RN3 con regla materna | Nº 15–24; confirmar excepciones y catálogo de identidad. |
| Institución solicitante | Renombrar laboratorio para evitar ambigüedad | Nº 40–44 bajo institucionSolicitante; confirmar equivalencia y maestro. |
| Ubicación para internación/guardia | Habitación/cama o equivalente cuando hay extracción en ubicación | Nº 47–50; concretar nombres, condiciones y actualización. |
| Muestra y observaciones por práctica | Indicador muestra obligatorio; conservar observaciones; analizar cantidad | Nº 60–62; confirmar semántica propuesta y captura, sin confundir disponibilidad con toma efectiva. |
| Importes y nodo administrativo | Totales paciente/mutual y cobrado; ubicación administrativa propuesta | Nº 65–67. Importes por ítem 63–64 recuperan solicitudes de julio; confirmar importes totales por cantidad, precisión y conciliación. |
| Una o dos fechas de entrega | Cálculo/confirmación preferida en SAGE y devolución a Markey | D09–D10; el nuevo versionEntrega se distingue arriba. Confirmar receptor y tratamiento de novedades. |
| Diagnóstico | Confirmar si se mantiene y corregir matriz | Nº 45–46, condicional y con descripción; confirmar disponibilidad y obligatoriedad por circuito. |
| Nombres consistentes y confidencialidad | Unificar fecha/fechaInicio y email/Email; conservar restricciones LIS | Nombre fecha, email uniforme y regla del Nº 14; confirmar semántica y aplicación. |

La preservación de códigos sensibles a mayúsculas (`o105`/`O105`) es un requisito comunicado posteriormente al documento del 11/09 y ratificado en octubre. El campo codigo ya existía; lo solicitado es confirmar y probar su comportamiento extremo a extremo. La diferenciación de endpoints por ámbito corresponde al acuerdo informado del 09/10, posterior a la respuesta de septiembre; sus rutas siguen por confirmar.

### Historial de revisiones internas de este diseño

- **1.0:** primera consolidación de esta especificación, con terminal/contexto de recepción, identificadores independientes, tablas y reglas operativas.
- **1.1:** incorporación de sintomas y ejemplo de tres prácticas con totales ilustrativos.
- **1.2:** corrección del alcance del apartado de cambios para comparar con la última respuesta entregada a Markey; detalle de terminal y todos sus campos, distinción de IDs y antecedentes de ALTA. No cambia el JSON de prueba de la revisión 1.1 ni renumera los campos.

El contrato solicitado 1.0 continúa en revisión conjunta. Este historial no atribuye entrega a Markey de las revisiones internas ni aprobación del proveedor. Se conservan las versiones anteriores y el reporte documental fuente.

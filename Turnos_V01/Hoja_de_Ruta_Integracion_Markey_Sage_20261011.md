# Hoja de ruta funcional de la integración Markey y SageLab

**Fecha:** 11 de octubre de 2026. **Uso:** planificación interna SAGE y base para talleres conjuntos con Laboratorio, Sistemas de CMG y Markey. **Objetivo temporal informado:** implementación prevista para febrero de 2027; falta convertir ese objetivo en un cronograma validado con esfuerzo y disponibilidad de las partes.

El propósito es construir un circuito fluido: cargar una vez la información administrativa en Markey, procesar en SageLab la operación del laboratorio y devolver estados y resultados sin exigir que los operadores concilien manualmente ambos sistemas en los casos normales. Las excepciones deben quedar visibles y asignadas a alguien que pueda resolverlas.

Esta hoja combina los antecedentes documentales leídos en Drive y el relato de las reuniones del 8 y 9 de octubre. Distingue acuerdos informados de propuestas. Los campos, nombres de estados y mecanismos técnicos sugeridos requieren validación conjunta antes de convertirse en contrato. No establece endpoints definitivos ni autoriza modificaciones sobre sistemas productivos.

## 1 Secuencia de trabajo y puntos de validación

Cada punto se cierra con una regla acordada, una prueba reproducible y evidencia de ambos sistemas cuando corresponde. Una respuesta HTTP o una demostración aislada no sustituye la validación del proceso.

| Punto | Entregable y condición de cierre | Participación propuesta |
|---|---|---|
| C0 Mensaje de origen | JSON completo generado por el circuito actual de Markey, con contexto de la operación y respuesta observada. Permite comparar documentación y emisión real. | Markey genera; SAGE analiza; CMG coordina |
| C1 Entidades y responsabilidades | Glosario, identificadores, cardinalidades y autoridad por dato/evento; ejemplos de alta, cambio y re-citación. | Markey y SAGE con Laboratorio |
| C2 Maestros | Catálogos iniciales conciliados y procedimiento demostrado para alta, cambio, inactivación y recuperación de sincronización. | Laboratorio, Administración, Markey y SAGE |
| C3 Contrato y aceptación | Mensaje, respuesta, estados, errores y persistencia acordados; aceptación y rechazo reproducibles sin duplicación. | Markey y SAGE; validación funcional del Laboratorio |
| C4 Recepción ambulatoria | Boleta, fechas, talón y etiquetas correctos; operación habitual demostrada por usuarios. | SAGE, Markey y recepción del Laboratorio |
| C5 Cambios y muestras | Cambios, anulaciones, re-citación y recolección adicional conservan relaciones y etiquetas válidas. | Laboratorio, Administración, Markey y SAGE |
| C6 Resultados | Parciales, definitivos y rectificados correctamente vinculados, recibidos y visibles según permisos. | SAGE y Markey con validadores del Laboratorio |
| C7 Internación y guardia | Circuitos completos probados en endpoints separados, con ubicación, episodio, prioridad y transferencias. | Usuarios de cada ámbito, CMG, Markey y SAGE |
| C8 Continuidad y puesta en marcha | Reintentos, conciliación, contingencia, soporte y aceptación por ámbito demostrados. | CMG, Laboratorio y ambos proveedores |

C0 es de prioridad alta y debe avanzar de inmediato. C1 y el inventario de C2 pueden trabajarse mientras llega el mensaje. C3 depende de esas definiciones. C4–C5 preceden a la aceptación del circuito ambulatorio. El diseño de C6 puede avanzar en paralelo, pero su prueba integral requiere una orden aceptada y correlacionada. El relevamiento de C7 puede comenzar temprano; no debe asumirse resuelto por completar ambulatorios. C8 se diseña desde el inicio y se prueba antes de operar.

## 2 Primer insumo de homologación

- [ ] Solicitar un mensaje completo producido por una carga real del circuito actual de Markey, en homologación y con datos de prueba o anonimizados preservando relaciones.
- [ ] Registrar ámbito, pasos de pantalla, identificadores y versión del sistema que lo generó; distinguir un JSON construido manualmente de uno emitido por la aplicación.
- [ ] Capturar request, respuesta vista por Markey y registro receptor; verificar codificación, fechas, tipos, importes y estructura.
- [ ] Comparar campo por campo con una única versión del contrato. Resolver `fecha`/`fechaInicio`, nombres y apellidos, `email`/`Email`, institución solicitante y datos administrativos.
- [ ] Mantener el ejemplo de origen como caso de prueba versionado. Agregar luego variantes y errores deliberados.

El receptor V0.3 actual guarda el cuerpo y confirma recepción técnica; no realiza aún alta SQL ni aceptación funcional. Para probar C3 deberá implementarse el procesamiento acordado o una simulación explícitamente identificada. El HTTP 200 actual no deberá conservar una semántica ambigua cuando comience la operación funcional.

## 3 Modelo de entidades y trazabilidad

| Entidad | Significado de trabajo | Definición a cerrar |
|---|---|---|
| Orden médica | Indicación clínica y sus prácticas solicitadas | Identificador, autor, origen interno/externo, vigencia y relación con episodios |
| Turno Markey | Entidad enviada por el HIS para organizar la atención | Si existe en los tres ámbitos; si representa cita, admisión, pedido o combinación |
| Boleta Sage | Registro operativo del laboratorio con numeración interna | Equivalencia exacta con protocolo/orden LIS y reglas de creación o separación |
| Ítem solicitado | Ocurrencia concreta de una práctica dentro del pedido | Identificador estable; código no basta si la práctica se repite |
| Muestra y recipiente | Material recolectado y soporte físico rotulado | Relación con prácticas, tomas, alícuotas y códigos de barras |
| Transacción | Mensaje lógico de integración | Identificador independiente, versión y correlación de respuesta/reintento |
| Resultado e informe | Publicación validada por determinación o documento | Identidad, versión, tipo parcial/definitivo/rectificado y vínculo con ítem/boleta |

- [ ] Confirmar si una orden médica puede originar varios turnos o boletas y si un turno puede reunir varias órdenes. No implementar una relación uno a uno por conveniencia sin validar estos casos.
- [ ] Determinar qué ocurre con los identificadores al reprogramar, cambiar de ámbito, generar una nueva boleta o repetir una muestra.
- [ ] Conservar los identificadores externos como cadenas sin perder ceros iniciales ni alterar mayúsculas. Precisar el ámbito de unicidad, incluyendo sede y numeraciones por atención.
- [ ] Acordar un índice de correlación consultable que vincule entidades de ambos sistemas, incluso operaciones rechazadas o pendientes.
- [ ] Registrar usuario, fecha, motivo y versión para cambios; mantener la historia de relaciones, sin reutilizar identificadores.

**Caso de discusión:** una orden con glucemia y cultivo se recibe, se toma una muestra, el cultivo requiere una nueva toma y después se agrega una práctica. Dibujar las entidades y mensajes de cada paso y demostrar que ningún resultado cambia de paciente, pedido o muestra.

## 4 Autoridad de datos y sincronización de maestros

Los documentos de julio no expresan idénticamente el gobierno del catálogo: el catálogo plantea un nomenclador común sin mapeos; la minuta atribuye al laboratorio la autoridad funcional. La propuesta de agosto también favorece esa autoridad. El taller debe convertir esas bases en una regla operativa única, sin crear equivalencias innecesarias.

- [ ] Inventariar prácticas, médicos, prestadores, instituciones solicitantes, financiadores/coberturas, planes y ubicaciones. Precisar qué significa «prestador» en cada sistema; no confundir profesional, institución y financiador.
- [ ] Por entidad, definir sistema mandante, aprobador funcional, código, campos replicados, vigencia y regla ante desconocidos. Markey es el origen administrativo previsto para pacientes, pedidos y valorizaciones; eso no le atribuye automáticamente autoridad sobre todos los maestros.
- [ ] Conciliar carga inicial y comprobar `o105`/`O105` desde selección en Markey hasta procesamiento en Sage. Evitar normalizaciones automáticas.
- [ ] Definir cómo se transmiten altas, modificaciones e inactivaciones: mensajes, consultas o lotes. Acordar frecuencia, versiones, confirmación y recuperación de actualizaciones perdidas.
- [ ] Mantener inactivos los códigos históricos; preservar lo que regía al solicitar y procesar la práctica.
- [ ] Definir conflictos simultáneos, cambios de descripción, sustituciones de código y reapertura de inactivos.
- [ ] Evitar crear automáticamente coberturas o prácticas desconocidas sin una regla aprobada. Para médicos, evaluar una excepción controlada con validación posterior si el circuito lo necesita.
- [ ] Probar que una orden enviada antes de sincronizar el maestro queda rechazable o recuperable, visible y sin duplicación.

## 5 Recepción y aceptación funcional

El flujo propuesto es: Markey registra y envía; Sage recibe, valida y decide; si acepta, persiste la boleta y su correlación y responde; el operador confirma las acciones necesarias; Sage imprime y devuelve los datos operativos acordados. Si rechaza, Markey debe mostrar una acción de corrección concreta.

- [ ] Definir el evento de envío: guardar, confirmar admisión, autorizar o finalizar carga. Evitar que cada edición incompleta dispare una orden operativa.
- [ ] Confirmar identificación del paciente y reglas para documento, RN1/RN2/RN3, pacientes sin documento y correcciones posteriores. No sobrescribir silenciosamente una identidad conflictiva.
- [ ] Validar cobertura codificada, médico y matrícula, institución/origen, prácticas vigentes, cantidades, diagnóstico cuando aplique, importes y fechas.
- [ ] Diferenciar fecha del pedido, cita, recepción, extracción, validación y entrega; acordar zona horaria y precisión.
- [ ] Definir aceptación total o parcial. Como propuesta de partida, evaluar rechazo completo si una práctica es inválida; cualquier aceptación parcial debe enumerar exactamente ítems aceptados y rechazados y ser visible al operador.
- [ ] Acordar la frontera de aceptación: respuesta después de persistencia durable o recepción asíncrona con estado consultable. Si queda pendiente, informar su resolución sin que se creen boletas duplicadas.
- [ ] Separar recepción técnica, aceptación funcional, boleta creada e impresión realizada. Un fallo de impresora después de crear la boleta debe poder recuperarse sin repetir el alta.

### Rechazos y resolución

| Situación | Acción propuesta para acordar | Evidencia de cierre |
|---|---|---|
| JSON o dato obligatorio inválido | Corregir origen; no repetir indefinidamente el mismo error | Campo y motivo visibles; reenvío corregido exitoso |
| Paciente inconsistente | Revisión autorizada de identidad y correlación | Sin paciente duplicado ni sobrescritura indebida |
| Maestro desconocido/inactivo | Corregir selección o sincronizar/homologar | Ítem y catálogo identificados; recuperación trazable |
| Fecha o ámbito incoherente | Corregir dato/ruta según regla | Error legible y operación posterior correcta |
| Cambio no permitido | Informar estado y alternativa: revisión o nueva orden vinculada | Sin cambios silenciosos en trabajo ejecutado |
| Servicio inaccesible/timeout | Reintentar con misma identidad de mensaje y consultar estado | Una sola boleta aun si se perdió la respuesta |
| Conflicto de versión/contenido | Conciliar versiones antes de aplicar | Estado final común y diferencias auditadas |

- [ ] Devolver código estable, descripción comprensible, identificadores y detalle de campo/ítem cuando sea posible.
- [ ] Definir quién ve y corrige cada error, cola de pendientes, plazo de atención y escalamiento. «Rechazado» sin responsable no cierra el proceso.
- [ ] Probar caída después de persistir pero antes de responder, doble clic del operador, reinicio del servicio y reenvío corregido.

## 6 Boleta fechas de entrega talón y etiquetas

- [ ] Definir numeración por ámbito, compatibilidad con lectores y vínculo visible con Markey.
- [ ] Validar cálculo de una o dos fechas de entrega según prácticas, ajustes autorizados y devolución de las fechas confirmadas a Markey. La propuesta SAGE existente favorece calcular en Sage y usar una pantalla mínima.
- [ ] Acordar cuándo se imprime automáticamente, cuándo se confirma y cómo recuperar impresiones fallidas.
- [ ] Aprobar contenido del talón y etiquetas con usuarios: paciente, boleta, muestra, práctica cuando corresponda, ubicación y fechas necesarias.
- [ ] Diferenciar reimpresión del mismo recipiente de creación de una nueva muestra. Registrar motivo y cantidad; controlar etiquetas obsoletas tras cambios.
- [ ] Probar una boleta con varias muestras, prácticas que comparten muestra y prácticas repetidas. Validar físicamente lectura por los equipos aplicables.

## 7 Modificaciones agregados retiros y anulaciones

La regla debe depender del estado operativo y administrativo, no solo del tiempo transcurrido. Una ventana de edición, si se adopta, complementa esas condiciones. «Cerrada» debe especificar si significa carga confirmada, muestra tomada, resultado validado o facturación realizada.

| Momento del cambio | Preguntas que deben resolverse |
|---|---|
| Antes de enviar | ¿Se edita libremente en Markey? ¿Qué evento confirma la versión final? |
| Enviado sin aceptación confirmada | ¿Cómo evitar carreras entre alta, cambio y reintento? |
| Aceptado sin toma | ¿Quién modifica? ¿Se reimprime talón? ¿Qué etiquetas se invalidan? |
| Con muestra disponible | ¿La muestra es apta y suficiente para el agregado? ¿Quién lo determina? |
| En procesamiento | ¿Qué acciones se detienen y cuáles ya no pueden retirarse? |
| Con resultados validados/informados | ¿Es agregado vinculado, nueva orden o rectificación? ¿Cómo se conserva lo publicado? |
| Con cobro/autorización/facturación | ¿Cómo se ajustan importes, autorización y conciliación de prestaciones? |

- [ ] Elegir un circuito explícito para cambios solicitados desde el laboratorio: solicitud en Sage hacia Markey, edición en Markey por un operador autorizado u otro mecanismo acordado. Evitar cambios locales sin comunicación y bucles de actualización.
- [ ] Especificar quién puede solicitar, autorizar y aplicar cada acción y qué sistema responde aceptación/rechazo.
- [ ] Usar identificadores de ítems para retirar solo la ocurrencia correcta de una práctica.
- [ ] Registrar cambios parciales, rechazo de modificación y resolución de ediciones simultáneas.
- [ ] Si corresponde nueva orden, conservar vínculos con la anterior y decidir reutilización de muestra mediante validación del laboratorio; no reutilizar etiquetas por defecto.
- [ ] Distinguir anular todo el pedido, retirar una práctica, cancelar una cita y anular una muestra. Conservar motivos y trabajo ya realizado.

## 8 Extracción incidencias y re-citación

El indicador `muestra` de la documentación no debe interpretarse automáticamente como «muestra tomada». Hay que cerrar su significado: condición declarada al solicitar, presencia de material, necesidad de extracción u otro. El tipo, recipiente y estado de la muestra son dimensiones adicionales.

- [ ] Modelar por muestra/práctica lo pendiente, tomado, recibido, rechazado y repetido, según los estados que use Sage.
- [ ] Registrar toma real, responsable, lugar, recepción del material y motivo de rechazo cuando corresponda.
- [ ] Resolver extracción fallida, muestra insuficiente, hemólisis u otras causas definidas por el laboratorio, material incorrecto, pérdida y segunda toma.
- [ ] Definir si la re-citación modifica el turno, crea otro vinculado o genera una nueva boleta; mantener resultados ya válidos y prácticas pendientes.
- [ ] Determinar quién contacta al paciente y dónde registra fecha, instrucciones y confirmación. Usar contactos actualizados y evitar promesas de entrega contradictorias.
- [ ] Recalcular entrega cuando cambia la toma; comunicarla a Markey y al operador responsable.
- [ ] Para extracción dentro de la clínica, consultar ubicación vigente y registrar intentos si el paciente se trasladó, fue dado de alta o no está disponible.
- [ ] Probar ausencia del paciente, reprogramación, varias visitas para una misma orden y toma adicional con etiquetas independientes.

## 9 Estados resultados e informes

Separar tres ejes: comunicación (pendiente/enviado/confirmado/error), trabajo del laboratorio y situación administrativa. El error técnico no debe convertir una orden válida en anulada ni marcar un resultado como no validado.

- [ ] Mapear estados de orden, práctica y determinación. Incluir recepción funcional, muestra, procesamiento, parcial, finalización y anulación, con reglas de agregación cuando existan prácticas pendientes o retiradas.
- [ ] Definir qué evento de validación habilita el envío de resultados y con qué granularidad. No enviar como publicado un dato todavía no validado.
- [ ] Relacionar cada resultado con paciente, episodio/pedido, boleta, ítem y determinación; no equiparar código facturable de práctica con código de cada resultado.
- [ ] Acordar números, texto, cualitativos, microbiología/cultivos, antibiogramas y adjuntos según el catálogo real. Incluir unidades, método y rangos contextualizados donde corresponda.
- [ ] Acordar resultados parciales, finales y rectificados, versiones, motivo, autor/fecha y tratamiento visible de la versión reemplazada.
- [ ] Definir si cada envío contiene una instantánea completa o solo cambios y cómo se procesan ausencias, retiros y mensajes fuera de orden.
- [ ] Mantener coherencia entre resultados estructurados y PDF: misma publicación o vínculo inequívoco entre versiones.
- [ ] Aplicar confidencialidad acumulativa de orden y práctica; un valor recibido en false no levanta restricciones internas de Sage. Validar acceso por paciente, médico y ámbito.
- [ ] Precisar circuito de valores críticos con el Laboratorio: notificación, destinatario y constancia de recepción. El envío REST no demuestra que una persona haya sido avisada.
- [ ] Registrar aceptación por Markey y verificar consulta y asociación correcta en su interfaz; contemplar su rechazo funcional y corrección.

## 10 Internación y guardia

Se informó el acuerdo de endpoints diferenciados para los tres tipos de atención. Se propone compartir mecanismos de trazabilidad, errores y reintentos y especializar reglas y pantallas según ámbito. Sus rutas definitivas deben documentarse conjuntamente.

**Internación:** identificar episodio, sala/habitación/cama y responsable; cambios de cama; pedidos seriados y tomas sucesivas; priorización de extracción; paciente temporalmente fuera de sector; alta/traslado con prácticas pendientes; resultados entregados después del alta; restricciones de publicación al paciente. Una cama no identifica por sí sola al paciente.

**Guardia:** identificar episodio y ubicación; urgencia y prioridades; paciente sin identificación definitiva; corrección posterior sin duplicación; órdenes adicionales; alta antes del resultado; derivación o internación; continuidad del pedido original al cambiar de ámbito; localización y responsable de recepción de resultados críticos.

- [ ] Determinar si «turno» existe conceptualmente en internación y guardia o si el mensaje representa una solicitud asociada al episodio.
- [ ] Validar rechazo cuando ámbito y endpoint no coinciden.
- [ ] Probar transferencias Guardia → Internación y otros cambios sin duplicar pedido, boleta ni resultados.
- [ ] Realizar demostración completa con usuarios de cada ámbito, incluyendo excepciones y pantalla operativa de Sage.

## 11 Continuidad conciliación y soporte

- [ ] Acordar identificador de mensaje para reintentos, versión de entidad y comportamiento ante mismo mensaje con contenido diferente. Reintento no equivale a una nueva orden.
- [ ] Preservar mensajes pendientes tras reinicios; establecer tiempos, límites y reproceso manual autorizado, sin ráfagas indefinidas.
- [ ] Disponer de consulta/conciliación que encuentre altas aceptadas sin respuesta, órdenes faltantes, versiones divergentes y resultados no confirmados.
- [ ] Definir contingencia para caída de Markey, Sage, enlace o impresoras: quién registra, cómo identifica y cómo reincorpora sin duplicar. Probar restauración y recuperación de colas.
- [ ] Acordar infraestructura de homologación y producción, autenticación, transporte seguro, certificados y permisos de consulta/reproceso. Base64 es codificación, no cifrado.
- [ ] Registrar correlación, operación, fecha, usuario cuando aplique, respuesta y motivo. Restringir acceso a datos clínicos y excluir credenciales de los logs.
- [ ] Elaborar guía breve de operación y errores por ámbito; contactos, horario y escalamiento de soporte; condiciones para detener o revertir una habilitación.

## 12 Matriz mínima de pruebas de aceptación

| Caso | Resultado que debe demostrarse |
|---|---|
| Alta completa ambulatoria | Una boleta correlacionada, fechas, talón y etiquetas correctos |
| `o105` y `O105` | Distinción preservada y muestra/práctica correcta |
| Paciente RN/sin documento y conflicto de identidad | Regla acordada; sin duplicación ni asociación equivocada |
| Cobertura/práctica/médico desconocido | Tratamiento explícito, visible y recuperable |
| Aceptación con respuesta perdida | Reintento devuelve la misma boleta |
| Mensaje inválido y corrección | Rechazo inicial y alta posterior trazables |
| Agregado antes y después de toma | Regla por estado, disponibilidad de muestra y control de etiquetas |
| Retiro/anulación con trabajo ejecutado | Preservación histórica y conciliación administrativa |
| Re-citación y segunda muestra | Pendientes y resultados previos conservados; identidad inequívoca |
| Parcial, definitivo y rectificado | Versiones correctas visibles en Markey y coherencia con PDF |
| Resultado confidencial/crítico | Permisos y circuito de aviso conforme a reglas del Laboratorio |
| Internación con traslado y guardia con identificación temporal | Ubicación/episodio y continuidad correctamente resueltos |
| Transferencia entre ámbitos | Sin duplicación ni pérdida de relaciones |
| Caída, reinicio y recuperación | Mensajes preservados y estado conciliado |
| Impresión fallida/reimpresión | Sin nueva boleta ni etiquetas ambiguas |

Cada caso debe registrar: ID, ámbito, precondiciones, datos, pasos, resultado esperado, resultado observado, identificadores en ambos sistemas, evidencias, responsable de ejecución, aprobador funcional y fecha. Un punto se cierra como aprobado, observado o no aplicable con justificación; no por ausencia de errores reportados.

## 13 Próximas acciones internas de SAGE

1. Preparar el registro de C0 y solicitar mediante el interlocutor acordado el JSON generado por Markey. No se envió ninguna comunicación como parte de esta elaboración.
2. Dibujar ejemplos de relaciones entre orden médica, turno, boleta, ítems y muestras para llevar al taller C1.
3. Inventariar reglas actuales de Sage: numeraciones, edición por estado, muestra, reimpresión, fechas, tipos de paciente, confidencialidad y formatos de resultados.
4. Preparar catálogos/versiones de prueba y un conjunto de casos que incluya códigos sensibles a mayúsculas.
5. Convertir C1–C5 en taller ambulatorio con usuarios y desarrolladores; documentar cada decisión antes de implementar la regla.
6. Estimar trabajo del receptor funcional y cliente de resultados sobre contratos acordados; incorporar después las variantes de internación y guardia y las pruebas de continuidad.
7. Construir cronograma hacia febrero de 2027 con responsables y capacidad real, reservando tiempo para homologación, capacitación, correcciones y puesta en marcha. No se asignan fechas ficticias a entregas externas.

## 14 Antecedentes consultados y uso en esta hoja

Lectura actual realizada el 11/10/2026 de siete documentos de Drive. Esta revisión es focalizada y no constituye una nueva auditoría de toda la carpeta ni de sus revisiones o comentarios.

- [Alcance inicial del 06/07](https://docs.google.com/document/d/1FiSiE-Fc-KC5sAlq7a7GPBIAqIxSuZ5R/edit): origen administrativo en Markey; estados, resultados y PDF desde Sage; relación con facturación y valores críticos. Contiene campos de plantilla y no se toma como contrato completo.
- [Catálogo homologado](https://docs.google.com/document/d/10r2Zh_Aa-YUrCU0jG80wlOrutnCOu0it/edit): nomenclador común, inactivos y trazabilidad de cambios.
- [Minuta del 21/07](https://docs.google.com/document/d/1CN6t9VS7IfE9IJlSaaN-2rWHrxea_UW_/edit): autoridad funcional del laboratorio, agregados a órdenes rotuladas, resultados contextualizados y contingencias.
- [Propuesta REST JSON del 27/08](https://docs.google.com/document/d/1Y_qqR4xB9NnLUvevR70M-WFmaxNttVZL/edit): identidad de transacciones, versiones, reintentos, maestros y separación entre estados técnicos y funcionales. Es una propuesta preliminar, no una implementación acreditada.
- [Interfaz de órdenes médicas](https://docs.google.com/document/d/1AiH53hOwwxjsTv6z3ritHlsZwaMU0zMqHS2yM-_4aDU/edit): entidad Turno, mapeo y ejemplos. Su referencia a «JSON real» se interpreta como ejemplo documental histórico, no como evidencia de un envío operativo actual.
- [Respuesta SAGE del 11/09](https://docs.google.com/document/d/1D2dXM8LGvDTyglxleWnnpJpbpMImyOaQ/edit): unicidad y cardinalidades, RN, cobertura, ubicación, muestra, importes, una o dos fechas de entrega y confidencialidad acumulativa.
- [Estados de solicitud y resultado](https://docs.google.com/document/d/1vE96BbNuOE48kEVGb99G6oYuzKfDzcGf/edit): base para mapear estados; falta operacionalizar alertas y separar aceptación funcional de recepción técnica.

Antecedentes locales: memo del 08/10, bitácora y revisión documental del 07/10. La minuta interna del 11/10 registra las nuevas reuniones y el estado informado por Marcelo. Los controles adicionales de esta hoja son propuestas de análisis para acordar con las partes, no compromisos previos atribuidos a ellas.

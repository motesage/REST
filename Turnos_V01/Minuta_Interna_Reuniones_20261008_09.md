# Minuta interna de reuniones sobre la integración Markey y SageLab

**Registro:** 11 de octubre de 2026. **Fuente de las reuniones:** relato de Marcelo. Esta minuta organiza lo informado; no es un acta aprobada por los participantes. Las propuestas de análisis se desarrollan en la hoja de ruta y no constituyen acuerdos con Markey.

## Reunión presencial del 8 de octubre de 2026

Participaron Marcelo Michalski; Carlos Scaglia, director del laboratorio; Ada García, responsable administrativa; y Leandro Lion, responsable de la integración por Sistemas de Clínica Monte Grande.

Se evaluaron los tiempos y respuestas de Markey para LIS/HIS y otros procesos, entre ellos facturación e imágenes. Según el relato, los participantes identificaron demoras generales. Leandro explicó que se había solicitado anticipar la integración del laboratorio para asegurar su implementación en la fecha prevista de febrero de 2027.

Marcelo expresó disposición a trabajar con tranquilidad, manteniendo firme el criterio de cumplir las condiciones de cada avance antes de abrir nuevos frentes. Leandro quedó en reunirse con el PM de Markey para impulsar el trabajo del responsable LIS/HIS. No se informó aquí el resultado de ese encuentro ni una fecha comprometida adicional.

## Videollamada del 9 de octubre de 2026 a las 14 horas

Convocada por Leandro con pocas horas de anticipación y con participación del grupo ampliado de Markey y Marcelo. No se dispone de nómina completa de asistentes.

Se trabajó sobre la carga de una orden médica para pacientes ambulatorios. Los circuitos de internación y guardia se abordarán en reuniones posteriores.

El circuito buscado por el laboratorio es: carga administrativa y pedido en Markey; envío REST hacia SageLab; aceptación o rechazo funcional; generación en Sage de la boleta, etiquetas para los analizadores y talón de recepción; posterior envío a Markey de resultados a medida que los estudios se finalizan y validan. Este circuito requiere precisar estados, responsabilidades, cambios y excepciones.

### Definición informada

Habrá endpoints diferenciados para ambulatorios, internados y guardia. Sage tendrá modos de trabajo diferenciados para facilitar la operación de cada grupo. No se informaron URLs ni contratos definitivos. La separación de endpoints no define por sí misma las reglas de identificación, cambios o transferencias de ámbito.

### Temas puestos a análisis

1. **Modificaciones posteriores a la aceptación.** Desde qué sistema se agregan, retiran o modifican prácticas; quién autoriza; si Markey permite cambiar una orden generada; cómo se comunica a Sage; qué sucede con las etiquetas existentes; cuándo corresponde modificar y cuándo crear una nueva orden vinculada.
2. **Relación entre entidades.** Orden médica, turno de Markey y boleta de Sage son entidades distintas. Se necesitan identificadores estables y relaciones explícitas, incluyendo reprogramaciones, múltiples prácticas y posibles nuevas boletas.
3. **Rechazo funcional.** Tratamiento de datos faltantes, paciente inconsistente, práctica desconocida, institución, médico u origen no reconocido y fechas incorrectas. Debe definirse quién ve el rechazo, lo corrige y vuelve a enviar.
4. **Incidencias de extracción.** Re-citación del paciente, cambio de fecha, localización dentro de la clínica, continuidad de las prácticas pendientes y manejo de muestras o etiquetas previas.
5. **Bases maestras.** Autoridad y sincronización de prácticas, médicos y prestadores; ampliación a coberturas, planes, instituciones y ubicaciones según el uso real de cada entidad.

## Situación informada al 11 de octubre

Marcelo indica que sigue sin recibir un JSON completo de una operación real generada desde Markey para analizar, pese a que se volvió a comprometer su envío. Debe tratarse como insumo prioritario de homologación. No se establece aquí una fecha de entrega que no haya sido informada.

Los mensajes minimalistas del 7 de octubre y la prueba propia de Marcelo desde un cliente REST externo prueban aspectos de recepción técnica; no prueban el circuito funcional descrito. Los ejemplos documentales previos tampoco sustituyen un mensaje generado por el flujo actual de Markey.

Marcelo considera que las dudas observadas podrían indicar falta de experiencia previa de Markey en una integración con este circuito. Es una apreciación personal; las reuniones no permiten afirmar que Markey nunca haya realizado integraciones LIS/HIS. La hoja de ruta se centra en demostrar el funcionamiento requerido, independientemente de los antecedentes del proveedor.

## Enfoque de trabajo propuesto por SAGE

Ordenar el proyecto por procesos y evidencias de aceptación, usando el circuito ambulatorio como primera implementación completa. Reutilizar el núcleo común en internación y guardia, pero validar sus diferencias con usuarios de cada ámbito. Mantener como requisitos iniciales identificación estable, cambios y anulaciones, muestra, fechas de entrega y códigos sensibles a mayúsculas.

La hoja de ruta adjunta amplía preguntas y escenarios. Sus responsables y soluciones son propuestas para acordar, no nuevos compromisos atribuidos a terceros.

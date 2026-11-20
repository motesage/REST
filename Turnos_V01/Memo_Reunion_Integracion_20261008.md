# Estado de la integración de turnos entre Markey y SageLab

**Fecha:** 8 de octubre de 2026  
**Para:** Dirección y coordinación técnica del laboratorio y Sistemas de la clínica  
**Asunto:** Avances comprobados, requisitos indispensables y definiciones pendientes para iniciar la operación

El objetivo de este memo es dejar una base común para evaluar el estado de la integración y acordar los próximos pasos. Mi principal preocupación es que se considere suficiente la conectividad o una aceptación general del intercambio cuando todavía necesitamos confirmar que los datos y el circuito permiten trabajar en el laboratorio.

**La unicidad e identificación estable del turno, su modificación o anulación, la toma de muestra y la fecha de entrega deben quedar resueltas en el alcance inicial. Sin estas condiciones no podemos arrancar; no corresponde postergarlas a una versión 2.** La preservación exacta de los códigos de prácticas también es indispensable.

## Avance comprobado al 7 de octubre

El punto de acceso de prueba está publicado en `http://200.41.170.126:8081/api/lis/turnos`. El receptor actual permite recibir y guardar el cuerpo de los mensajes para su análisis. Todavía no realiza la validación funcional ni el alta de una orden en la base de datos de SageLab, ni genera el talón de recepción o las etiquetas.

Ayer se recibieron los dos envíos objeto de esta revisión:

- **15:04:12:** POST sin contenido, con respuesta HTTP 400 preparada por el servidor.
- **15:05:14:** POST con el único dato `{"turnId":12}`, guardado como JSON, con respuesta HTTP 200 preparada por el servidor.

El segundo mensaje no contiene paciente, prácticas, muestra, cobertura ni fechas operativas. **Se trata de una prueba de conexión y recepción; no de un turno real ni de un conjunto representativo de turnos para analizar.** No permite determinar si podremos crear correctamente la orden, imprimir el talón y generar las etiquetas.

El HTTP 200 del receptor actual expresa recepción y guardado del cuerpo, no aceptación funcional ni creación de una orden. Además, el log registra la preparación de la respuesta y aclara que eso no confirma su entrega al cliente. Para cerrar la prueba de comunicación corresponde verificar también qué respuesta recibió y registró el emisor.

El POST de las 12:32:16, de 1.883 bytes, fue una prueba propia que realicé desde un cliente REST en mi computadora, ubicada en otra ciudad. El JSON incluye datos de paciente, cobertura, médico y una práctica, y el log acredita su recepción y guardado, con respuesta HTTP 200 preparada. Esta prueba aporta evidencia de acceso remoto al receptor desde esa conexión externa. No fue un envío generado por Markey ni valida su circuito de emisión, el contrato definitivo o el procesamiento funcional en SageLab. Por lo tanto, no sustituye el conjunto de turnos completos que necesitamos recibir desde Markey para homologar la integración.

## Requisitos y checklist para el arranque

### Identificación del turno y cambios posteriores

- [ ] Confirmar qué identificador de Markey identifica de manera única y permanente cada turno u orden y cuál es su ámbito de unicidad: institución, sede, período u otro.
- [ ] Asegurar que el identificador no se reutilice ni cambie al ajustar el turno. Si turno y orden son entidades distintas, definir su relación y los identificadores que se intercambiarán.
- [ ] Definir cómo se informan altas, modificaciones, reprogramaciones y anulaciones, siempre vinculadas al registro original.
- [ ] Acordar cómo tratar el agregado o retiro de prácticas y los cambios cuando el laboratorio ya recibió al paciente o tomó la muestra.
- [ ] Definir el tratamiento de reenvíos y mensajes duplicados para evitar órdenes duplicadas, y cómo impedir que un mensaje anterior sobrescriba una modificación posterior.

### Prácticas y sensibilidad a mayúsculas y minúsculas

Los códigos del catálogo del laboratorio **son sensibles a mayúsculas y minúsculas**. Por ejemplo, `o105` y `O105` identifican variantes de un estudio de Cultivo aplicables a muestras diferentes. Son códigos distintos y no deben convertirse automáticamente a mayúsculas o minúsculas ni considerarse equivalentes.

Hace unos días Sistemas de la clínica consultó este punto por WhatsApp y respondí que la distinción es obligatoria. Esa consulta me dejó la preocupación de que el tema pudiera no estar resuelto en Markey. **Esto es una duda pendiente de confirmación, no una incompatibilidad comprobada.**

- [ ] Obtener confirmación de que Markey conserva y distingue ambos códigos en todo el circuito: catálogo, selección, almacenamiento y envío.
- [ ] Probar `o105` y `O105` por separado y verificar que lleguen intactos y se asignen a la práctica y muestra correctas.
- [ ] Acordar la versión del catálogo, su responsable funcional, el procedimiento de actualización y el tratamiento de códigos desconocidos o inactivos.

### Toma de muestra

- [ ] Definir qué información de muestra requiere cada práctica y cómo se representa cuando una orden incluye varias prácticas o muestras.
- [ ] Acordar quién registra la toma, en qué momento, qué fecha y hora se utiliza y cómo se comunica al otro sistema cuando corresponda.
- [ ] Distinguir la fecha del turno de la toma efectiva y definir el tratamiento de muestras pendientes, aportadas por el paciente o que deban repetirse, según los circuitos aplicables.
- [ ] Validar que los datos y reglas acordados permitan generar etiquetas e identificar correctamente las muestras.

**La información y el circuito de toma de muestra necesarios para operar deben estar disponibles desde el inicio.** La mención informal a «lo de muestra» no define qué se excluye ni acredita conformidad del laboratorio para postergarlo.

### Fecha de entrega

- [ ] Definir qué representa la fecha de entrega: fecha comprometida al paciente, disponibilidad prevista del resultado u otra referencia acordada.
- [ ] Establecer quién la determina y comunica, si corresponde a toda la orden o a cada práctica y cómo se manejan distintos plazos dentro de una misma orden.
- [ ] Acordar cómo se informan cambios y asegurar que el talón de recepción muestre la información correcta.

El 22 de septiembre se comunicó por WhatsApp que la fecha de entrega aún no estaba implementada y se propuso llevarla a una fase 2. **Esa propuesta no resuelve la necesidad del laboratorio ni implica que hayamos aceptado su postergación.** Debemos acordar una solución operativa para el arranque, con responsable y prueba de aceptación.

### Contenido completo y contrato del intercambio

- [ ] Consolidar una única versión del contrato con nombres de campos, significado, obligatoriedad, formatos y reglas para valores ausentes.
- [ ] Resolver las diferencias documentales ya señaladas: `fechaInicio`/`fecha`, `nombre`/`nombres`, `apellido`/`apellidoPaterno` y laboratorio/institución solicitante.
- [ ] Confirmar identificadores y datos del paciente, tratamiento de recién nacidos y pacientes sin documento, cobertura y plan, solicitante, diagnóstico, importes y ubicación/cama cuando corresponda al circuito.
- [ ] Confirmar la disponibilidad y validación de la matriz de coberturas y demás equivalencias necesarias.
- [ ] Definir respuestas de aceptación o rechazo funcional, detalle de errores, reintentos y mecanismo de consulta o conciliación de órdenes.

Estos puntos retoman las consultas documentadas previamente. Debe acordarse cuáles aplican a cada circuito y cuáles son obligatorios, evitando completar datos faltantes mediante supuestos.

## Pruebas necesarias antes de habilitar la operación

Solicito recibir un conjunto representativo de turnos completos generado desde Markey, con datos de prueba adecuados para homologación. Debe permitir verificar:

- [ ] Alta completa y correspondencia entre turno de origen y orden en SageLab.
- [ ] Orden con varias prácticas y muestras, incluyendo la distinción `o105`/`O105`.
- [ ] Modificación, reprogramación y anulación vinculadas al registro original.
- [ ] Reenvío del mismo mensaje sin duplicación y tratamiento de mensajes fuera de orden.
- [ ] Datos incompletos o código inválido, con rechazo y corrección verificables.
- [ ] Toma de muestra, fecha de entrega, talón y etiquetas conforme al circuito del laboratorio.
- [ ] Coberturas y casos particulares de pacientes que formen parte del alcance inicial.

La recepción del conjunto de prueba permitirá revisar el contenido y solicitar ajustes. La habilitación operativa requiere además implementar y validar el circuito completo en SageLab y comprobar el comportamiento de ambos sistemas. No debe confundirse el receptor de prueba disponible con una integración funcional terminada.

### Criterio de cierre de la recepción de turnos

Necesitamos acordar qué significa dar por completada la recepción de turnos. La recepción técnica de un mensaje es un primer paso. Para cerrar esta etapa debemos recibir turnos completos generados desde Markey, validar su contenido y comprobar que permiten crear la orden en SageLab con las prácticas, muestras y fechas necesarias, además de verificar los cambios, anulaciones y reenvíos definidos en el alcance inicial.

Las pruebas recibidas hasta ahora no permiten dar esa etapa por concluida ni acreditar que estén dadas las condiciones para el circuito de resultados. Podemos avanzar en tareas técnicas independientes del envío de resultados, pero ese avance no reemplaza la validación de la recepción funcional de turnos.

## Acuerdos solicitados en la reunión

Propongo que Dirección del laboratorio y Sistemas de la clínica dejen asentados los requisitos indispensables del alcance inicial y que Sistemas gestione con Markey las confirmaciones e implementaciones pendientes. Para cada punto abierto necesitamos **un responsable, una fecha comprometida y una evidencia de cierre**.

- [ ] Ratificar que identificación estable, cambios y anulaciones, toma de muestra, fecha de entrega y códigos sensibles a mayúsculas forman parte del arranque.
- [ ] Designar un interlocutor técnico por cada parte y un canal formal donde registrar preguntas, respuestas y decisiones. Los acuerdos de WhatsApp deben trasladarse al registro del proyecto.
- [ ] Comprometer la fecha de envío del conjunto de turnos completos y la devolución de observaciones del laboratorio/SAGE.
- [ ] Acordar un cronograma de ajustes, implementación y homologación que contemple los recursos disponibles de SAGE.
- [ ] Establecer quién aprueba funcionalmente las pruebas por el laboratorio y quién autoriza la puesta en operación.
- [ ] Acordar los criterios de cierre de cada etapa y sus dependencias, en particular qué debe estar validado en la recepción de turnos para probar el circuito completo de resultados.
- [ ] Actualizar la documentación con el endpoint de prueba, contrato vigente, pendientes y resultados de validación.

Mi pedido es avanzar con estas definiciones y pruebas, y fijar la fecha de arranque sobre resultados comprobados. La conectividad es un avance concreto, pero todavía no aporta la evidencia funcional necesaria para asumir que el laboratorio puede comenzar a operar con esta integración.

## Antecedentes de respaldo

- JSON minimalista recibido el 07/10/2026 a las 15:05:14, JSON de la prueba propia desde un cliente REST remoto a las 12:32:16 y log del servidor de esa fecha. El origen de la prueba de las 12:32 fue confirmado por Marcelo.
- Bitácora local de integración: intercambio del 22/09 y solicitud de envío de turnos y cronograma del 07/10. Las transcripciones de WhatsApp fueron aportadas por Marcelo.
- Revisión documental local del 07/10: consultas pendientes de la respuesta SAGE del 11/09, diferencias del contrato y documentación de pruebas aún sin actualizar en los archivos revisados. Esa revisión no acredita ausencia de avances o respuestas por otros canales.
- Confirmación de Marcelo sobre sensibilidad de los códigos del catálogo y requisitos indispensables para el inicio, incorporada para esta reunión.

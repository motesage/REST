Revisión estructural de JSON Markey frente a la especificación SAGE v1.2

**Fecha:** 05/11/2026. **Versión:** 1.1. **Emisor:** SAGE.

## 1. Alcance y conclusión

Se revisaron dos mensajes de Turno recibidos el 05/11/2026, ambos con arreglo de prácticas, comparando su estructura con la **Especificación del JSON de turnos requerida por SAGE, revisión documental 1.2 del 12/10/2026**. 

La revisión comprende sintaxis, codificación, objetos, arreglos, nombres de campos, tipos, presencia de obligatorios, cadenas vacías, formatos de fecha y reglas de identificación/versionado observables. No se evaluaron homologaciones de códigos, identidad de pacientes, convenios, pertinencia clínica de estudios ni corrección de aranceles. La detección de un código vacío corresponde a la completitud estructural, no a la homologación del código.

**Conclusión:** ambos mensajes incluyen el detalle de una práctica y los campos obligatorios del médico con valores no vacíos. Persisten identificadores y datos de recepción ausentes/vacíos, diferencias de representación y el código de práctica vacío. Por ello, ninguno satisface todavía los requisitos solicitados para un alta funcional.

## 2. Muestras examinadas

Las referencias M1 y M2 se utilizan para evitar repetir nombres largos de archivos y no exponer datos del paciente.

| Ref. | Archivo RAW | Fecha/hora en el nombre del archivo |
|---|---|---|
| M1 | `Turno_20261105_140538_319_D98B63EB-23C9-4E7D-A5EE-CF14BFD651B6.json` | 05/11/2026 14:05:38.319 |
| M2 | `Turno_20261105_153234_653_BAF4409D-C257-420E-96DB-987C066DC927.json` | 05/11/2026 15:32:34.653 |

Ambas muestras declaran `operacion: "ALTA"`, `versionTurno: 1`, `versionMensaje: "1.0"` y `sistemaOrigen: "MARKEY"`. Por ello se aplican los requisitos de ALTA, no el cuerpo reducido previsto para CANCELACION.

## 3. Diferencias y ajustes solicitados

| Ref. de especificación | Campo o estructura | M1 | M2 | Ajuste solicitado / motivo |
|---|---|---|---|---|
| 58 | `practicas[].codigo` | Cadena vacía | Cadena vacía | Enviar el código no vacío de cada ítem. La descripción no sustituye el código. Se evaluará su equivalencia con el catálogo en otra etapa. |
| 57 | `practicas[].itemId` | Presente; significado por confirmar | Presente; significado por confirmar | Aclarar el origen y significado del valor informado `13936`: ¿identifica el renglón de la solicitud o corresponde al código de la práctica? Debe identificar una ocurrencia estable dentro del Turno, mientras que `codigo` debe contener el código del catálogo. Ver apartado 4.3. |
| 02 | `ordenMedicaId` | Ausente | Ausente | Incorporar el identificador de la orden/prescripción, independiente del Turno y de la transacción. Confirmar cardinalidad entre orden y Turno. No confundirlo con la denominación del endpoint de Órdenes para internación. |
| 51 | `recepcion.terminalId` | Ausente | Ausente | Identificar el puesto real que confirma la recepción; SAGE lo necesita, junto con la sede, para dirigir la impresión. No deducirlo de la IP del emisor. |
| 53 | `recepcion.usuarioId` | Cadena vacía | Cadena vacía | Informar el operador que confirma la recepción. Es obligatorio y no admite vacío. |
| 11 | `ambito` | `"A"` | `"A"` | La especificación solicita `AMBULATORIO`, `INTERNADO` o `GUARDIA`. Emitir el valor previsto o acordar expresamente otra representación. No incorporar una conversión implícita en el LIS. |
| 45-46; sección 5 | `diagnostico` | Objeto vacío `{}` | Objeto vacío `{}` | Si no hay diagnóstico, omitir el objeto. Si se envía, su descripción debe ser no vacía; el código es condicional cuando exista diagnóstico codificado. No se exige diagnóstico para todas las órdenes. |

**Aclaraciones:** la provincia de matrícula es condicional según su tipo. Los contactos del médico son opcionales; su omisión o una cadena vacía no constituyen por sí solas un faltante obligatorio.

## 4. Identificadores, reintentos y versiones

### 4.1 Turno y transacción

En cada muestra, `identificador` y `transaccionId` tienen el mismo valor. Que ambos coincidan en una primera ALTA no constituye por sí solo una infracción: lo que debe garantizarse es que identifican conceptos diferentes y mantienen las reglas de estabilidad y renovación previstas en los campos 01, 03 y 05 y en la sección 9.

M1 y M2 comparten identificador de Turno, transacción, operación y versión.

### 4.2 M1 y M2: misma transacción con fechas diferentes

La comparación completa de los objetos JSON de M1 y M2 muestra diferencias únicamente en:

- `fechaHoraMensaje`.
- `recepcion.fechaHora`.

El resto del contenido coincide. No se observa una ampliación estructural de M2 respecto de M1.

**Consulta a Markey:** confirmar si M2 es un reintento técnico de M1 o una nueva emisión funcional.

- **Si es un reintento:** conservar la misma `transaccionId` y el contenido original íntegro, incluidas las fechas. Cambiar fechas produce otro contenido para la misma transacción. La fecha de recepción original no debe renovarse por reenviar el mensaje.
- **Si es una modificación de un Turno ya aplicado funcionalmente:** utilizar nueva `transaccionId`, siguiente `versionTurno`, operación `MODIFICACION`, `motivoOperacion` y objeto `cambio`, enviando la instantánea completa y preservando los ítems que continúan.
- **Si se corrige un alta rechazada funcionalmente y no aplicada:** utilizar nueva `transaccionId` manteniendo la versión esperada todavía no aplicada; no convertirla automáticamente en MODIFICACION.
- **Si son ensayos independientes:** identificarlo como circuito de prueba y acordar los identificadores que permitan distinguirlos sin colisiones futuras.

La igualdad de identificadores se informa sin reproducir sus valores. En estas muestras no es posible verificar la estabilidad futura de `itemId`, el incremento de versiones, el funcionamiento de cancelaciones o los reintentos idénticos.

### 4.3 Identificación del renglón: `itemId` frente a `codigo`

SAGE solicita aclarar el significado del valor `13936` informado en `practicas[].itemId`, especialmente porque el campo separado `practicas[].codigo` está vacío. Esta combinación podría indicar una confusión entre la identificación del renglón y el código de la práctica; se plantea como consulta, no como una conclusión sobre el origen del dato.

La interpretación operativa propuesta por SAGE es utilizar una secuencia de renglones desde 1 hasta N en el ALTA inicial, siendo N la cantidad de ítems de prácticas incorporados. Cada ítem tiene su propio identificador, incluso si dos ítems corresponden al mismo código de práctica.

**Tipo del campo [57]:** aunque la especificación v1.2 propuso String, SAGE admite **String o Integer**, a elección de Markey. El tipo elegido deberá confirmarse y mantenerse uniforme en todos los mensajes, conservando las reglas de identificación estable y no reutilización. Por ejemplo, la secuencia podrá enviarse como `"1"`, `"2"`, `"3"` o como `1`, `2`, `3`, según la alternativa acordada.

La revisión v1.2 exige identificación estable y sin reutilización, pero **no prescribe que el identificador sea una secuencia de 1 a N**. Por lo tanto, esa secuencia es una propuesta para facilitar el acuerdo; un identificador de detalle propio de Markey también puede cumplir el requisito si se confirma su significado, unicidad dentro del Turno y estabilidad durante los cambios. El valor `13936` no es inválido por su magnitud.

Si se acuerda la secuencia, deben preservarse estas reglas:

- En el ALTA inicial, identificar los ítems de `"1"` a `"N"`.
- En MODIFICACION, conservar el `itemId` de los ítems que continúan, aunque cambie su posición en el arreglo.
- No renumerar los restantes al retirar un ítem ni reutilizar su identificador para otra ocurrencia. Las secuencias pueden quedar con huecos.
- Asignar a los agregados un nuevo identificador no utilizado anteriormente en ese Turno; no calcularlo únicamente como cantidad actual de ítems más uno.
- Informar siempre el código de catálogo en `practicas[].codigo`, independientemente del identificador elegido para el renglón.

**Ejemplo con String (equivalente con Integer):** un ALTA con `itemId` `"1"`, `"2"`, `"3"` que luego retira el ítem `"2"` y agrega otro queda con `"1"`, `"3"`, `"4"`. No debe convertirse en `"1"`, `"2"`, `"3"` por renumeración.

**Devolución solicitada a Markey:** confirmar qué representa `13936`, si existe un identificador propio de detalle y si se utilizará ese identificador o la secuencia propuesta, y si se transmitirá como String o Integer. Si el valor corresponde al código de la práctica, enviarlo en `codigo` y asignar a `itemId` la identificación del renglón que se acuerde.

## 5. Elementos que se ajustan estructuralmente

| Aspecto | Resultado observado | Límite de la comprobación |
|---|---|---|
| Sintaxis y codificación | Ambos archivos son JSON válidos en UTF-8, con objeto en la raíz y sin claves duplicadas detectadas. | No acredita suficiencia funcional. |
| Envoltorio | El Turno se transmite directamente en la raíz, sin `Turno` ni `datos`. | Se ajusta al diseño solicitado. |
| Nombres y tipos presentes | No se detectaron discrepancias de tipo en los campos escalares presentes de las tablas de solicitud. Identificadores/códigos presentes son String; banderas son Boolean; versiones/cantidades son Integer; importes son Number. | Un String vacío sigue siendo inválido si el campo es obligatorio. |
| Control de ALTA | Operación ALTA, versión de Turno 1, versión de contrato 1.0 y origen MARKEY. | Las pruebas no cubren otros estados del ciclo de vida. |
| Fechas | Las fechas/hora presentes tienen formato ISO con offset. La fecha de nacimiento tiene formato de fecha válido. | No confirma que cada campo represente el evento de negocio previsto. |
| Paciente | Campos obligatorios presentes con los tipos previstos. | Sin validar identidad ni datos maestros. |
| Médico solicitante | Código, nombres, apellido y matrícula obligatoria presentes como String no vacíos; objeto `medico.matricula` presente. | Sin validar homologación ni contenido de la matrícula. |
| Cobertura | Objeto y campos de cobertura presentes como String; plan y número de afiliado informados. | Sin homologar código/plan ni evaluar condiciones del convenio. |
| Institución solicitante | Objeto `institucionSolicitante` con código y nombre String no vacíos. | Sin validar equivalencia del maestro. |
| Recepción | `sedeId` y `fechaHora` presentes con sus tipos previstos. | Faltan terminal y usuario efectivo, según el cuadro de diferencias. |
| Práctica en M1/M2 | Cada ítem incluye las ocho rutas previstas: `itemId`, `codigo`, `nombre`, `cantidad`, `observaciones`, `muestra`, `importePaciente` e `importeMutual`. Los tipos son correctos; cantidad es positiva, `itemId` y nombre son no vacíos. | `codigo` está vacío. La presencia y tipo de `itemId` no confirman su significado: ver 4.3. Un único ítem no permite probar su identificación en pedidos múltiples. |
| Indicador `muestra` en M1/M2 | Se transmite como Boolean real. | Falta confirmar captura y significado operativo; no certifica toma efectiva ni aptitud de la muestra. |
| Importes | Objeto administrativo presente con sus tres Number. En M1/M2, las sumas por ítem coinciden con los totales paciente y mutual. No se detectaron valores negativos ni más de dos decimales en los importes examinados. | Se verificó representación y consistencia aritmética, no aranceles, convenios ni cobros. |

## 6. Ausencias que no se deben presentar como errores de estas ALTAS

- `observaciones` generales y `recepcion.sintomas` son opcionales. Su omisión no incumple por sí sola esta estructura; deben transmitirse cuando existan datos que corresponda comunicar.
- `motivoOperacion` y el objeto `cambio` son obligatorios para modificación/cancelación, no para estas ALTAS.
- No se exige `ubicacionPaciente` para toda alta ambulatoria. Debe evaluarse en los escenarios de guardia/internación que requieran localizar al paciente.
- `boletaSageId`, las fechas de entrega y `versionEntrega` pertenecen a las respuestas/devoluciones de SAGE; no son campos faltantes del Turno entrante.
- Los contactos opcionales de médico e institución pueden omitirse. No deben confundirse con datos obligatorios del solicitante.

## 7. Confirmaciones y próximas muestras solicitadas

1. Completar los faltantes/vacíos del cuadro del apartado 3 y confirmar la representación de `ambito` y el tratamiento del objeto `diagnostico`.
2. Confirmar si las emisiones M1/M2 son reintentos o nuevas operaciones y ajustar la gestión de transacciones y fechas según el apartado 4.
3. Confirmar la semántica de `fecha`: ambas muestras usan medianoche e informan el día anterior al envío. Esto es una consulta de negocio, no un error de formato; precisar si representa atención prevista o recepción asistencial según el contrato.
4. Confirmar que `recepcion.fechaHora` representa la confirmación administrativa original y que `fechaHoraMensaje` corresponde a la generación del mensaje lógico, conservado en sus reintentos.
5. Confirmar el significado de `itemId` y su separación respecto de `codigo`, según 4.3. Enviar un ALTA completa con varias prácticas e `itemId` distintos y una modificación con retiro y agregado, para comprobar estabilidad y no reutilización. Posteriormente probar códigos sensibles a mayúsculas y equivalencias de maestros, fuera del alcance de esta revisión.
6. Enviar ejemplos de reintento idéntico, MODIFICACION y CANCELACION, incluidos motivo, auditoría y conservación de referencias, para verificar las reglas que estas muestras no permiten evaluar.
7. Probar recepción desde dos puestos reales para confirmar que la identificación sede/terminal permite dirigir talón y etiquetas.
8. En una etapa separada, revisar las Órdenes de internación y las condiciones de ubicación/destino operativo. Ambas muestras corresponden a Turnos y no homologan ese circuito.

## 8. Estado de aceptación

El receptor actual continúa en modo RAW: su respuesta HTTP 200 / `RECIBIDO` confirma recepción y guardado del cuerpo. **No representa aceptación funcional de esta estructura, generación de boleta, alta SQL ni emisión de comprobantes.**

Con los ajustes indicados se podrá avanzar a la revisión de códigos, maestros y reglas funcionales. La aceptación de String o Integer para [57] explicita una flexibilidad respecto de la especificación enviada, sujeta a confirmación del tipo elegido por Markey. El resto de las observaciones conserva los requisitos de referencia. No se introducen validaciones nuevas en el servidor instalado.

## Referencias documentales

- Especificación del JSON de turnos requerida por SAGE, revisión documental 1.2 del 12/10/2026; tablas de campos 01-68 y secciones 1 a 10.
- Dos archivos RAW identificados en el apartado 2, recibidos el 05/11/2026.

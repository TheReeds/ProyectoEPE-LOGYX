# 4.2 Proceso Actual — AS-IS (CE0132)

## 4.2.1 Descripción narrativa

El proceso actual inicia cuando el encargado de almacén informa al gerente que hay mercadería lista para despachar. El gerente interrumpe sus actividades y comienza la búsqueda de transporte: llama o escribe por WhatsApp a entre cinco y diez transportistas de su lista de contactos personales, describiendo verbalmente la carga, el destino y la fecha. Algunos no responden; otros no tienen capacidad disponible; los que responden cotizan verbalmente un precio que el gerente no puede contrastar con ninguna referencia de mercado.

Con frecuencia interviene un intermediario (broker informal) que “consigue el camión” a cambio de un margen que la PYME no conoce con precisión. La negociación se resuelve por teléfono, sin registro: el precio final depende de la urgencia de la PYME y de la percepción de escasez del momento. Cerrado el acuerdo verbal, el almacén coordina la hora de recojo por WhatsApp.

Durante el traslado no existe visibilidad: si el cliente pregunta por su pedido, el área de ventas “llama al chofer”. La entrega se realiza sin evidencia formal —sin fotografía, sin firma digital, a lo sumo un mensaje de “ya entregué”. El pago se hace en efectivo o por transferencia, muchas veces adelantado en parte, sin vínculo con la conformidad de la entrega. Finalmente, el gasto se anota (a veces) en un Excel o cuaderno, sin desglose que permita análisis posterior. Si surge una disputa —carga dañada, retraso, cobro distinto al pactado— no hay registro que permita resolverla: es palabra contra palabra.

## 4.2.2 Modelo BPMN AS-IS (especificación textual)

El diagrama BPMN AS-IS se estructura en cuatro carriles (pools/lanes). Especificación para su elaboración en herramienta editable (Anexo B):

<table>
<colgroup>
<col style="width: 24%" />
<col style="width: 75%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Carril</strong></th>
<th><strong>Elementos del flujo</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>PYME — Gerente</td>
<td><p>1. Evento de inicio: mercadería lista para despacho</p>
<p>2. Tarea: contactar transportistas (5–10 llamadas/mensajes) — bucle</p>
<p>3. Compuerta exclusiva: ¿alguna respuesta con capacidad? (No → volver a 2 / recurrir a intermediario)</p>
<p>4. Tarea: negociar precio verbalmente (sin referencia)</p>
<p>5. Compuerta: ¿acuerdo? (No → volver a 2)</p>
<p>6. Tarea: confirmar acuerdo verbal</p></td>
</tr>
<tr class="even">
<td>Intermediario (opcional)</td>
<td><p>7. Tarea: buscar camión disponible en su red</p>
<p>8. Tarea: agregar margen y cotizar a la PYME</p></td>
</tr>
<tr class="odd">
<td>PYME — Almacén</td>
<td><p>9. Tarea: coordinar hora de recojo por WhatsApp</p>
<p>10. Tarea: entregar mercadería al conductor (sin acta formal)</p></td>
</tr>
<tr class="even">
<td>Transportista / Conductor</td>
<td><p>11. Tarea: recoger la carga</p>
<p>12. Tarea: trasladar (sin visibilidad para la PYME) — evento intermedio: consultas del cliente atendidas “llamando al chofer”</p>
<p>13. Tarea: entregar sin evidencia formal</p>
<p>14. Tarea: cobrar (efectivo/transferencia)</p></td>
</tr>
<tr class="odd">
<td>PYME — Administración</td>
<td><p>15. Tarea: registrar gasto en Excel/cuaderno (a veces)</p>
<p>16. Evento de fin: envío cerrado sin evidencia · Camino de excepción: disputa sin registro → fin insatisfactorio</p></td>
</tr>
</tbody>
</table>

<img src="media/image3.png" style="width:6.4625in;height:2.47708in" />

## 4.2.3 Indicadores actuales (línea base)

| **KPI del proceso**                                | **Valor AS-IS (línea base)**                             | **Fuente / naturaleza**                            |
|----------------------------------------------------|----------------------------------------------------------|----------------------------------------------------|
| Recorridos en vacío (lado transportista)           | 40–45% en la región                                      | Farromeque Quiroz (2017) — verificada              |
| Costo logístico sobre ventas (lado PYME)           | 21.1% (microempresa) vs. 15.7% (gran empresa)            | ComexPerú (2022) — verificada                      |
| Tiempo de contratación de un flete                 | Horas a días (llamadas múltiples y espera de respuestas) | Estimación del equipo sobre el proceso narrado     |
| Contactos necesarios por envío                     | 5–10 llamadas/mensajes                                   | Estimación del equipo                              |
| Envíos con precio de referencia previo             | 0%                                                       | Por definición del AS-IS (no existe la referencia) |
| Envíos con evidencia formal de entrega             | 0%                                                       | Por definición del AS-IS                           |
| Envíos con seguimiento en tiempo real              | 0%                                                       | Por definición del AS-IS                           |
| Disputas con posibilidad de resolución documentada | 0%                                                       | Por definición del AS-IS                           |

## 4.2.4 Problemas detectados en el flujo

- La búsqueda secuencial por contactos (tareas 2–3) consume horas del gerente y limita la oferta a su red personal — manifestación directa de P1 y P5.

- La negociación sin referencia (tarea 4) institucionaliza la opacidad de precios — P2.

- La intervención del intermediario (tareas 7–8) añade margen sin añadir información ni garantías — P2/P5.

- El traslado sin visibilidad (tarea 12) y la entrega sin evidencia (tarea 13) generan el déficit de confianza — P4.

- El transportista regresa vacío tras la tarea 13 porque el proceso no contempla carga de retorno — P3.

- El registro opcional (tarea 15) impide la analítica y la mejora continua — P1.


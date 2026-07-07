# 4.3 Proceso Propuesto — TO-BE (CE0133)

## 4.3.1 Descripción narrativa del rediseño

En el proceso rediseñado, la PYME publica la solicitud de carga en la plataforma en un formulario de dos minutos; el sistema calcula automáticamente un precio de referencia basado en la distancia real de la ruta y el histórico del corredor, y abre una subasta con ventana de tiempo definida. Los transportistas verificados cuyo perfil es compatible reciben la notificación y ofertan; la PYME compara ofertas viendo simultáneamente precio y reputación verificada, puede contraofertar por el canal moderado y acepta la mejor combinación precio–confianza, generándose el contrato digital.

Durante la ejecución, el conductor gestiona su ruta desde la aplicación móvil: cada parada registra estado, y la entrega se confirma con fotografía y firma digital del receptor —incluso sin conexión, con sincronización posterior. La PYME y su cliente ven el avance en tiempo real sin llamar a nadie. Al confirmarse la entrega, se habilita la calificación mutua que alimenta la reputación compuesta de ambos actores. Terminada la ruta, el sistema notifica al transportista las cargas de retorno disponibles cerca de su destino, atacando directamente el recorrido en vacío. Todo queda registrado: precios, tiempos, evidencias y calificaciones alimentan la analítica de la PYME y el precio de referencia del corredor.

## 4.3.2 Modelo BPMN TO-BE (especificación textual)

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
<td>PYME</td>
<td><p>1. Inicio: mercadería lista</p>
<p>2. Tarea de usuario: publicar solicitud (formulario guiado)</p>
<p>3. Tarea de servicio (automática): cálculo del precio de referencia</p>
<p>4. Evento intermedio temporizador: ventana de subasta</p>
<p>5. Tarea de usuario: comparar ofertas (precio + reputación) y aceptar/contraofertar</p>
<p>6. Evento: contrato digital generado</p></td>
</tr>
<tr class="even">
<td>Plataforma LOGYX</td>
<td><p>7. Tarea de servicio: notificar a transportistas compatibles (matching)</p>
<p>8. Tarea de servicio: cerrar subasta automáticamente (tiempo o máximo de ofertas)</p>
<p>9. Tarea de servicio: moderar mensajes de negociación</p>
<p>10. Tarea de servicio: registrar estados, evidencias y calificaciones</p>
<p>11. Tarea de servicio: detectar y notificar cargas de retorno al finalizar la ruta</p></td>
</tr>
<tr class="odd">
<td>Transportista</td>
<td><p>12. Tarea de usuario: revisar solicitud rankeada y ofertar</p>
<p>13. Tarea de usuario: asignar vehículo y conductor</p>
<p>14. Tarea de usuario: aceptar carga de retorno sugerida (opcional)</p></td>
</tr>
<tr class="even">
<td>Conductor (app)</td>
<td><p>15. Tarea: iniciar ruta asignada</p>
<p>16. Subproceso por parada: llegar → entregar → foto + firma → estado actualizado</p>
<p>17. Evento de fin: última parada confirmada</p></td>
</tr>
</tbody>
</table>

<img src="media/image4.png" style="width:6.4625in;height:2.38264in" />

## 4.3.3 Nuevos indicadores del proceso

- Tiempo publicación → primera oferta y publicación → aceptación (meta: \< 60 minutos).

- Porcentaje de solicitudes con al menos una oferta en 24 horas (meta SLA: ≥ 60% desde el mes 2).

- Porcentaje de envíos con evidencia completa de entrega (meta: 100% en plataforma).

- Tasa de aceptación de cargas de retorno sugeridas (indicador del ataque a P3).

- Desviación del precio aceptado respecto al precio de referencia (salud del mercado interno).


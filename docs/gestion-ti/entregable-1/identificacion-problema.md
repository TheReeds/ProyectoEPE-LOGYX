# 1.4 Identificación del Problema (CE0111)

## 1.4.1 Definición estructurada del problema

| **Código** | **Problema**                  | **Manifestación**                      | **Evidencia**                           |
|------------|-------------------------------|----------------------------------------|-----------------------------------------|
| P1         | Fragmentación operativa       | Gestión por WhatsApp, Excel y papel    | Inventario AS-IS; madurez 1–2; EFI 1.93 |
| P2         | Opacidad de precios           | Negociación sin referencia de mercado  | Cadena de valor eslabón 3; Porter F5    |
| P3         | Baja utilización logística    | Recorridos en vacío del 40–45%         | Farromeque Quiroz (2017); EFE O4        |
| P4         | Déficit de confianza          | Contratación sin historial verificable | Brecha de confianza; FCE1               |
| P5         | Falta de poder de negociación | Costo logístico 21.1% vs. 15.7%        | ComexPerú (2022); EFI D7; EFE A6        |

## 1.4.2 Análisis de causas raíz

<table>
<colgroup>
<col style="width: 25%" />
<col style="width: 74%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Espina</strong></th>
<th><strong>Causas identificadas</strong></th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>Método (proceso)</td>
<td><p>• No existe proceso logístico definido</p>
<p>• Búsqueda por contactos personales (5–10 llamadas)</p>
<p>• Sin planificación ni consolidación de cargas propias</p></td>
</tr>
<tr class="even">
<td>Información (datos)</td>
<td><p>• Sin referencia de precios por ruta</p>
<p>• Sin historial de desempeño de transportistas</p>
<p>• Registro manual e incompleto del gasto</p></td>
</tr>
<tr class="odd">
<td>Tecnología</td>
<td><p>• Herramientas genéricas en lugar de sistemas del dominio</p>
<p>• Cero trazabilidad: sin GPS ni evidencia digital</p></td>
</tr>
<tr class="even">
<td>Personas (organización)</td>
<td><p>• Función logística dispersa entre roles</p>
<p>• Dependencia de la memoria del gerente</p></td>
</tr>
<tr class="odd">
<td>Mercado (estructura)</td>
<td><p>• Oferta atomizada sin mecanismo de agregación</p>
<p>• Intermediarios sin tecnología</p>
<p>• Demanda fragmentada sin poder de compra</p></td>
</tr>
<tr class="even">
<td>Entorno</td>
<td><p>• Infraestructura vial vulnerable</p>
<p>• Informalidad y débil fiscalización</p></td>
</tr>
</tbody>
</table>

Cuatro de las seis espinas corresponden a causas de coordinación e información, no a limitaciones físicas del transporte. La causa raíz sistémica es la ausencia de una capa de información compartida entre los actores.

*Supuesto declarado del equipo: el diagrama de Ishikawa visual se elaborará en herramienta con archivo fuente editable (draw.io, Bizagi o Enterprise Architect) a partir de esta tabla, para cumplir el requisito de formato de sustentación (Anexo C).*

## 1.4.3 Impacto estratégico

- Sobre OE1: la brecha de ~5 pp erosiona el margen operativo, pudiendo equivaler a la utilidad neta de una PYME.

- Sobre OE2: sin trazabilidad, cada envío es un acto de fe; incidentes sin resolución formal.

- Sobre OE3: sin datos históricos, el gasto logístico es impredecible.

- Sobre OE4: la logística actúa como barrera al crecimiento comercial.

> *Se asume como hipótesis de trabajo, sustentada en la revisión bibliográfica del sector, que la informalidad en la coordinación logística de las PYMEs del corredor Lima–Arequipa–Juliaca genera pérdidas recurrentes de envíos y sobrecostos operativos. Esta hipótesis se apoya en evidencia indirecta: la alta tasa de recorridos en vacío documentada para la región (40–45%, Farromeque Quiroz, 2017), la brecha de costos logísticos que penaliza desproporcionadamente a la micro y pequeña empresa (21.1% vs. 15.7% de la gran empresa, ComexPerú, 2022), y el rezago estructural de Perú en infraestructura y eficiencia logística (puntaje 3.0/5 en el LPI 2023, Arvis et al., 2023). No existe actualmente una medición pública específica de la frecuencia de incidentes de coordinación para el corredor Lima–Sierra Sur, por lo que este dato queda fuera del alcance cuantificado del diagnóstico y se declara como supuesto de diseño del proyecto, no como estadística verificada.*

## 1.4.4 Justificación de la intervención y alineamiento estratégico

| **FCE requerido**                    | **¿Alcanzable con el AS-IS?** | **¿Por qué no?**                                         |
|--------------------------------------|-------------------------------|----------------------------------------------------------|
| FCE1. Confianza verificable          | No                            | WhatsApp no genera historial ni verifica identidad legal |
| FCE2. Precio de referencia           | No                            | No existe fuente de datos de precios                     |
| FCE3. Consolidación de carga         | No                            | Requiere visibilidad simultánea de múltiples cargas      |
| FCE4. Trazabilidad extremo a extremo | No                            | Sin GPS, estados ni evidencia digital                    |
| FCE5. Adopción sin fricción          | —                             | El AS-IS fija el estándar de simplicidad a igualar       |

Ninguno de los cuatro primeros FCE es alcanzable con las herramientas actuales. Se justifica la intervención mediante una solución TIC colaborativa (LOGYX), contra la línea base establecida aquí (comparativo en el Entregable 4).


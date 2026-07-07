# 4.4 Propuesta de Automatización mediante TIC (CE0134)

Las automatizaciones del TO-BE y su mecanismo, referenciando los módulos de la solución (cuyo diseño técnico se desarrolla en la documentación técnica de la solución (fuera del alcance de esta ronda de evaluación)):

| **Automatización**                  | **Qué reemplaza del AS-IS**                          | **Mecanismo (módulo)**                                                                          |
|-------------------------------------|------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| Cálculo del precio de referencia    | Negociación a ciegas (tarea AS-IS 4)                 | Motor de costos: distancia real por carretera + histórico del corredor + variables de la carga  |
| Difusión de la solicitud (matching) | 5–10 llamadas manuales del gerente (tarea 2)         | Notificación automática a transportistas verificados con perfil de ruta y capacidad compatibles |
| Cierre de subasta                   | Presión y arbitrariedad de la negociación telefónica | Cierre automático por tiempo o número máximo de ofertas; reglas iguales para todos              |
| Moderación de la negociación        | Acuerdos verbales sin registro (tareas 4–6)          | Chat con registro íntegro y detección de intentos de contacto fuera de plataforma               |
| Trazabilidad y evidencia            | “Llamar al chofer” y entrega sin acta (tareas 12–13) | Estados por parada + captura de foto y firma en la app del conductor (funciona sin conexión)    |
| Detección de carga de retorno       | Retorno en vacío por defecto (P3)                    | Búsqueda automática de cargas abiertas cercanas al destino al confirmar la última entrega       |
| Registro y analítica                | Excel/cuaderno opcional (tarea 15)                   | Persistencia automática de precios, tiempos, evidencias y calificaciones; tablero para la PYME  |


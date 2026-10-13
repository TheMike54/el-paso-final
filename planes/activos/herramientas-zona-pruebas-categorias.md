ACTIVO

# Herramientas: zona de pruebas por categorías

Sale de la prueba en el Senwa S50 del 12-oct-2026: 31 botones «Sala …» en una lista que se desplaza cuestan de
recorrer en una pantalla chica. Propuesta revisada por la persona en una maqueta el 12-oct-2026; los tamaños y el
margen siguen `planes/activos/nucleo-menu-tactil.md`.

## Decisiones (12-oct-2026)

- Una tabla `const` en `herramientas/salas/zona_pruebas.gd` da el grupo de cada sala; el grupo oculto reemplaza a
  `EXCLUIDAS`. Una sala que no está en la tabla aparece en «Otras»: una sala nueva sigue apareciendo sola.
- Arriba, una fila fija de botones de categoría que cambia la cuadrícula de abajo; no es un nivel más de menú, así
  que «Volver», Atrás y `pausa` salen de la zona (a donde diga `planes/activos/nucleo-menu-tactil.md`: al menú de
  inicio si se hace ese plan, a Configuración si no). Recuerda la última categoría mientras la app
  está abierta (variable estática; nada nuevo en `Ajustes`).
- Botones sin «Sala »: «Doble salto», «Puerta A». Cada grupo en un orden fijo; el foco empieza en la primera sala.
- Descartado: prefijos o subcarpetas por categoría (rompe unas 110 líneas `escena` de guiones, claves de sala y
  destinos de puertas) y un índice `.json` (viaja en el paquete y pide leerlo y manejar errores).

| Categoría | Salas |
|---|---|
| Movimiento | movimiento, caída, salida abajo, doble salto, impulso, pared, carrera |
| Combate | combate, combate chico, golpe, parry, pogo, picada, bola, curar |
| Enemigos y peligros | enemigos, enemigos banco, peligro, peligro móvil |
| Sala y cámara | banco, puerta A, puerta B, cámara, capas, recursos |
| Zonas y mapa | Mapa 1, Mapa 2, Prueba 1 a 4 |
| Otras | vacía hoy |
| Oculta | las 16 de solo guion de hoy |

## Comprobación

- `validar.gd`: un fallo si la tabla nombra una sala que ya no existe (se rompe al renombrar una).
- Ningún `.esperado` cambia (ningún guion entra a la lista); `validar.ps1` y todos los guiones.
- En el S50 (la persona): cada categoría cabe sin desplazar, se cambia de categoría con un toque y al volver de
  una sala está la última categoría. Fila «Menú de desarrollo» de `docs/pruebas.md` actualizada.

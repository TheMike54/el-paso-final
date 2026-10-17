ACTIVO

# L1 / R1 cambian de categoría en la zona de pruebas

Aprobado por la persona el 16-oct-2026.

Decidido por la persona el 15-oct-2026. Entrada `zona-pruebas-l1-r1` de `herramientas/funciones.json`.

## Por qué

Con un control, hoy hay que subir el foco hasta la fila de categorías para cambiar de categoría
(`herramientas/salas/zona_pruebas.gd:40-50` y `:109`). El marco de menús ya cambia de página con L1 / R1
(`pagina_anterior` y `pagina_siguiente`, `nucleo/marco_menus.gd:88-91`). La zona hace lo mismo, como las pestañas
del inventario de Silksong.

## Qué se hace

- En `zona_pruebas.gd`, `pagina_anterior` y `pagina_siguiente` pasan a la categoría anterior o a la siguiente, en el
  orden de la fila. Al llegar al final da la vuelta, igual que el marco.
- Usa `_mostrar(categoria)`, así que el foco queda en la primera sala de la categoría nueva y se recuerda en
  `_ultima`.
- Sin acción nueva: L1 / R1 ya son `pagina_anterior` y `pagina_siguiente`, y en el teclado Z y C. En la zona no hay
  partida, así que `mapa_rapido`, que comparte L1, no responde.
- El ícono de L1 / R1 junto a la fila llega con el plan `nucleo-botones-del-control.md`.

## Hitos

1. H1 · Código.
   - Prueba nueva `herramientas/salas/prueba_zona_pruebas.gd`, con su sala oculta y el guion
     `herramientas/guiones/nucleo/zona_pruebas_categorias`. No hay carpeta de guiones de `herramientas`; va junto a
     `marco`.
   - Casos: R1 pasa a la segunda categoría, L1 vuelve, L1 desde la primera va a la última y el foco queda en la
     primera sala.
   - La sala nueva va en `OCULTAS`.
2. H2 · `validar.ps1` y el guion. Sin revisor: no es punto crítico.
3. H3 · Prueba manual con control: L1 / R1 recorren las categorías.

## Avance (16-oct-2026)

- H1 y H2 hechos: 8 casos en `prueba_zona_pruebas.gd`, que fallan 3 sin la lectura de L1 / R1.
- Los íconos de L1 y R1 quedaron a la derecha de la barra de arriba, con «Categoría», y no junto a la fila: ahí no
  cabían en 1280×720 (plan de los botones del control). Con ellos, la prueba tiene 10 casos.
- Falta H3: la prueba manual con control.

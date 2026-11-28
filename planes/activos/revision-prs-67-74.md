ACTIVO (escrito y aprobado por la persona el 27 y 28-nov-2026)

# Revisión de los PR #67, #68, #69 y #74 antes de fusionarlos

Auditoría de solo lectura de los cuatro PR abiertos el 27-nov-2026 (integración de las cuatro ramas sin commit:
`OK  VALIDACION archivos=456 fallos=0`, `RESUMEN total=241 OK=241 MALOS=0`; revisión del subagente `revisor`). Ningún
PR trae código duplicado, muerto ni archivos de más; los arreglos son documentación, un guion y textos de PR. Se hacen
en la rama de cada PR. Orden de fusión: #67, #68, #69, #74.

## Alcance
1. #68 (`feature/contenido-capas-raices`): solo el texto del PR (salida de `validar.ps1`, campos de la plantilla,
   imagen `montaje_raices_4` repetida, título `feat:` en vez de `design:`).
2. #69 (`feature/contenido-musica-cierre`): el validador revisa que el `TEMA` de la pantalla de cierre se repite
   (`herramientas/validar.gd`, `docs/validador.md`); «pantalla de cierre» en la lista de `FUNDIDO_CORTO`
   (`nucleo/musica.gd`, `docs/audio.md`).
3. #74 (`feat/musica-raices`):
   - guion `contenido/raices_8_puertas`: el tema de Las Raíces suena y no vuelve a empezar al cruzar la puerta;
   - su entrada en `contenido/funciones.json`;
   - `docs/uso-de-ia.md`, fila «Música»: vuelve «con un script escrito con Claude Code» al tema del menú y junta los
     temas de cierre y de Las Raíces;
   - `docs/manual/continuar.md` y `docs/guias/sonido-y-musica.md` (ya hay más temas que el del menú y no se guardan en
     `nucleo/sonidos/`); mención del tema en `docs/sala.md` y `docs/manual/recorrido.md`; prueba manual en
     `docs/pruebas.md`;
   - el texto del PR nombra la herramienta de IA.
4. Conflictos esperados al fusionar #74 después de #69: la fila «Música» de `docs/uso-de-ia.md` (queda la de #74) y
   el final de `contenido/funciones.json` (quedan las dos entradas).

## Pendiente de la persona
- Volumen de Las Raíces (`volumen_musica_db = -10.0`, unos 12 dB por debajo del menú): se decide oyéndolo en el
  teléfono con el APK de desarrollo de la rama de #74.

## Decidido
- 27-nov-2026: auditar los PR antes de fusionarlos, arreglos en la rama de cada PR, el volumen de #74 se decide de
  oído y las imágenes de #68 entran ya como kit. «adelante  y lo de las desisiones tomo lo recomendado»
- 28-nov-2026: hacer todos los arreglos, obligatorios y opcionales. «adelante con obligatorios y opcionales»

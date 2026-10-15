REEMPLAZADO POR nucleo-cierre-antes-de-la-sala.md

# Núcleo: modo desarrollador y herramientas en el paquete de publicación

Decidido por la persona el 07-oct-2026: la zona de pruebas y las herramientas sí viajan en el paquete de
publicación. En el menú, un botón «Modo desarrollador» que, al activarlo, muestra la entrada a la zona de pruebas,
en depuración y en publicación. Cambia una decisión cerrada del `CLAUDE.md` raíz. Plan por aprobar: no se programa
antes.

Precisión de la persona, 11-oct-2026: el juego sale a producción con el modo desarrollador disponible, como lo hizo el
profesor. El interruptor «Activar modo desarrollador» va en la Configuración del menú principal (que ya existe,
`PanelConfiguracion`), no suelto en el menú, y al activarlo aparecen ahí las opciones de desarrollador (por ahora,
la entrada a la zona de pruebas). La sección 2 se ajusta a esto al retomar el plan.

## 1. Lo que hay (leído el 07-oct-2026)

- `nucleo/menu.gd`: el botón `ZonaPruebas` se ve solo si `OS.is_debug_build()` y existe
  `res://herramientas/salas/zona_pruebas.tscn` (`ResourceLoader.exists`).
- `nucleo/arranque.gd`: carga `herramientas/puerto_depuracion.gd` con `load()` solo en depuración y si existe.
- `herramientas/salas/zona_pruebas.gd`: lista la carpeta al entrar y ya acepta los `.tscn.remap` de un paquete
  exportado (probado con el preset «Desarrollo» en el S20).
- Preset «Publicacion» (solo en la rama `chore/android-export`): `exclude_filter="herramientas/*,*funciones.json"`.
  Los `.ps1`, `.guion` y `.esperado` no son recursos: con `all_resources` no se exportan aunque se quite el filtro.
- Ajustes del teléfono (vibración, temblor) en `user://ajustes.json` (`nucleo/ajustes.gd`).
- Textos que dicen lo contrario: `CLAUDE.md` raíz («Decisiones cerradas»), `nucleo/CLAUDE.md` («Qué no toca»),
  `herramientas/CLAUDE.md` (introducción y fila de `puerto_depuracion.gd`), `docs/contrato.md` («Paquete de
  publicación»), cabeceras de `menu.gd`, `arranque.gd` y `zona_pruebas.gd`, y la entrada `menu-desarrollo`.

## 2. Propuesta

| Qué | Cómo | Archivos |
|---|---|---|
| Botón «Modo desarrollador» | Un interruptor en el menú (`CheckButton`), visible en depuración y en publicación, apagado por omisión. Encendido, aparece «Zona de pruebas» si su escena existe | `nucleo/menu.tscn`, `nucleo/menu.gd` |
| Se recuerda | `modo_desarrollador: bool` en `user://ajustes.json`, junto a vibración y temblor (no en la partida: no es del jugador) | `nucleo/ajustes.gd` |
| Puerto de depuración | Sigue solo en depuración: es el lector de guiones de prueba (`--guion=`) y no lo pide la decisión | sin cambio de código; textos |
| Preset «Publicacion» | `exclude_filter="*funciones.json"` (quita `herramientas/*`) | `export_presets.cfg`, bloque aparte en `chore/android-export` |
| Textos | Los siete del punto 1 | ver punto 4 |

Recomendación de Claude en los dos puntos abiertos: recordar el modo en `ajustes.json` (si no, hay que encenderlo
cada vez que se abre la app frente al profesor) y dejar el puerto solo en depuración.

## 3. Cómo se comprueba

- Guion `menu_desarrollo.guion` (lógica que puede romperse: el interruptor y su guardado): con el modo apagado la
  zona no se ve; al encenderlo se ve y `ajustes.json` lo guarda; al volver a abrir el menú sigue encendido. El
  guion corre en depuración, así que prueba la regla, no el paquete.
- Paquete de publicación: exportar con el preset «Publicacion» en modo release. Para Android hace falta el keystore
  de publicación, que Claude no lee ni crea (regla del repo): esa prueba es de la persona. Alternativa sin keystore,
  sin comprobar: exportar en release para Windows en una copia del repo en el scratchpad (las plantillas 4.7.2 ya
  instaladas) y ver que el interruptor muestra la zona con `OS.is_debug_build()` en falso.
- Manual: en ventana y en el paquete de publicación, el interruptor muestra y oculta la zona y se recuerda.

## 4. Cambios de texto (se muestran a la persona antes de editar los `CLAUDE.md`)

`CLAUDE.md` raíz, «Decisiones cerradas», hoy:

> `herramientas/` y la zona de pruebas no viajan en el paquete de publicación: el preset las excluye y el núcleo
> las carga con `load()` solo si existen y el build es de depuración; nunca con `preload` ni como autoload directo.

Propuesta:

> `herramientas/` y la zona de pruebas viajan también en el paquete de publicación (cambiado el 07-oct-2026): la
> zona aparece en el menú solo con «Modo desarrollador» encendido, y el puerto de depuración solo corre en builds
> de depuración. El núcleo las carga con `load()` solo si existen; nunca con `preload` ni como autoload directo.

`nucleo/CLAUDE.md` y `herramientas/CLAUDE.md`: la misma regla en sus palabras (la carpeta viaja, el juego no
depende de ella, el puerto solo en depuración).

Entrada `menu-desarrollo` (redacción que la persona aprobó cambiar):

- `que`: «Un menu sencillo permite empezar, continuar y, con el modo desarrollador encendido, entrar a la zona de
  pruebas, en depuracion y en publicacion».
- `comprobacion`: «manual: en ventana y en el paquete de publicacion, cada opcion del menu lleva a su escena; la
  zona de pruebas aparece solo con el modo desarrollador encendido y el modo se recuerda al reabrir el juego».

## 5. Commits

- En esta rama: menú, ajustes, guion, contrato, `CLAUDE.md` y entrada de `funciones.json`.
- En `chore/android-export`: solo el `exclude_filter` de `export_presets.cfg`, como bloque aparte.

## Avance

- [ ] Plan aprobado por la persona.
- [ ] Textos de los `CLAUDE.md` aprobados.
- [ ] Código y guion.
- [ ] Preset (bloque en `chore/android-export`).
- [ ] Paquete de publicación probado (persona).

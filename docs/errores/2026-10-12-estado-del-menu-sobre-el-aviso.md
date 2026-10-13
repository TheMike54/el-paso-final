# Texto de estado del menú encima del aviso de pocos toques

Fecha: 2026-10-12. Rama `fix/nucleo-menu-aviso-y-autoguardado`.

## Síntoma
En el Senwa S50, con el modo desarrollador encendido, «No hay partida guardada.» se dibujaba encima de la línea
«Tu celular reconoce pocos toques a la vez…» (captura con `adb`, APK de las 23:18).

## Causa
Con «Zona de pruebas» el menú mide unos 667 px de alto. El aviso ocupa los últimos 84 px de la vista de 720 y el
menú se centraba en toda la pantalla, así que su última línea caía en la franja del aviso. Los mensajes de partida
dañada y de otra versión ocupaban hasta 3 líneas y lo empeoraban.

## Arreglo
- Con el aviso, el menú se centra solo arriba de él (`_centro.offset_bottom = aviso.offset_top` en `menu.gd`).
- 12 px entre botones en vez de 20 y el título a 56 en vez de 64; los botones siguen en 108.
- Mensajes de una línea: «La partida está dañada.» y «Partida de otra versión.» (374 px de 480).
- Medido en ventana con `Toques.forzar(true)` y el modo desarrollador: el menú termina en 625 y el texto del
  aviso empieza en 668, en las vistas de 1280 y 1440.

## Qué lo cubre ahora
Ningún guion: la posición depende del dibujo de la letra. Lo cubre la fila «Aviso de pocos toques» de
`docs/pruebas.md` en el S50.

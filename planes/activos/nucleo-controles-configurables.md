ACTIVO

# Núcleo: botones táctiles configurables

Pedido por la persona el 07-oct-2026 como funcionalidad nueva de `nucleo/funciones.json`, al estilo del editor de
controles de Call of Duty: Mobile: mover cada botón a cualquier lugar, cambiar su tamaño (y la opacidad si es
barata), restaurar los valores por omisión y guardarlo en `user://ajustes.json`. Reemplaza a los «botones en tamaño
físico» del plan de pantalla completa, y el área segura pasa a este plan. Plan por aprobar: no se programa antes.

## 1. Lo que hacen otros juegos (investigación del 07-oct-2026, con fuentes al final)

| Juego | Confirmado | Sin confirmar |
|---|---|---|
| Call of Duty: Mobile [1] | Ajustes → Controles → «Custom Layout», sobre un HUD de muestra; se mueve cada elemento; tamaño y opacidad de todo lo que hay en pantalla | Rejilla, deshacer, botón de restaurar, rango de tamaño, varios diseños guardados (solo blogs poco fiables), cómo se guarda |
| Hollow Knight | No se encontró una versión oficial para Android ni iOS (solo páginas de APK poco fiables) | — |
| Dead Cells móvil [2] | Controles a medida: posición y tamaño de los botones; dos esquemas (Original y Auto-Hit) | Opacidad, rejilla, restaurar |
| Alien: Isolation iOS [3] | — | Mover, cambiar tamaño, opacidad por icono (página no abierta; dato de segunda mano) |

Accesibilidad: Android pide objetivos táctiles de 48×48 dp como mínimo, separados 8 dp [4]; las guías de
accesibilidad de juegos piden presets más un modo a medida [5].

## 2. Lo que hay (leído el 07-oct-2026)

`nucleo/controles_tactiles.gd`: siete botones (`saltar`, `atacar`, `curar`, `impulso`, `pausa`, `mapa`, `mochila`)
dibujados con `_draw`; cada uno con una esquina de ancla, un centro en fracción de una pantalla 16:9 y un radio en
fracción del lado corto; el toque cuenta hasta 1,25 veces el radio. Joystick invisible y flotante en la zona de
abajo a la izquierda (45 % × 70 % de la pantalla). Sin área segura. Ajustes en `nucleo/ajustes.gd`: versión 1,
solo valores `bool` (vibración, temblor), con una pantalla en la pausa.

## 3. Propuesta

| Qué | Cómo |
|---|---|
| Entrada al editor | Botón «Controles» en la pausa, junto a vibración y temblor. El juego queda en pausa debajo (vista previa real, como el HUD de muestra de CoD) |
| Elegir y mover | Tocar un botón lo selecciona (se resalta); arrastrarlo lo mueve. Un solo dedo a la vez en el editor |
| Tamaño | Un deslizador del botón seleccionado, de 50 % a 200 % del tamaño por omisión, con un mínimo de radio equivalente a 48 dp |
| Opacidad | Un deslizador para todos los botones a la vez (como CoD), de 20 % a 100 %: un número que multiplica el alfa del dibujo. Por botón costaría una lista más y un deslizador que cambia de dueño; no se propone |
| Restaurar | Un botón que vuelve todo a los valores por omisión, con confirmación |
| Guardar y salir | «Listo» guarda en `user://ajustes.json`; «Cancelar» descarta lo editado |
| Dentro de la pantalla | Al soltar un botón y al cargar, su círculo se ajusta para quedar dentro del área segura (`DisplayServer.get_display_safe_area()`, solo Android/iOS [6]); si se encima con otro, se permite |
| Qué se guarda | Por botón: esquina de ancla (la más cercana al soltarlo), desplazamiento desde ella en fracción del lado corto y escala; más la opacidad global. Es el mismo modelo de hoy, así los valores por omisión no cambian y la distancia al pulgar se conserva entre proporciones (de 4:3 a 22:9) |
| Archivo | Clave nueva `controles` dentro de `ajustes` en `user://ajustes.json`. Sin subir la versión 1: una clave que falta ya se queda en su valor por omisión |
| Joystick | Sin cambios en esta funcionalidad: es flotante (aparece donde cae el dedo) y su zona ya es media pantalla. Moverlo o cambiar su tamaño, si la persona lo pide |

La cuenta (ancla más cercana, ajuste al área segura, de y hacia el diccionario, mínimo de 48 dp) va en un script
sin nodos, como `nucleo/vista.gd`, para probarla sin pantalla.

## 4. Riesgos y lo que no se puede probar aquí

- El área segura llega en píxeles de la ventana; con `canvas_items` + `expand` hay que pasarla a coordenadas de la
  vista. La forma exacta (p. ej. con `get_viewport().get_final_transform()`) está sin comprobar.
- Sin pantalla (`--headless`) el `DisplayServer` da valores ficticios [6]: el área segura y los 48 dp solo se
  comprueban en el S20.
- Los toques del editor no deben llegar al juego en pausa ni accionar los botones mientras se editan.

## 5. Cómo se comprueba

- Guion (lógica que puede romperse): un diseño guardado y vuelto a leer da lo mismo; un botón soltado fuera de la
  pantalla vuelve dentro; restaurar deja los valores por omisión; un toque sobre un botón movido acciona su acción y
  sobre su lugar viejo no; un archivo sin la clave `controles` deja los valores por omisión.
- Manual en el S20: mover y agrandar Saltar, salir, cerrar la app, volver a abrirla y ver que sigue igual; la
  opacidad; restaurar.

Entrada nueva para `nucleo/funciones.json` (la aprueba la persona):

- `id`: `controles-configurables`
- `que`: «Desde la pausa se puede mover cada boton tactil, cambiar su tamano y la opacidad de todos, restaurar los
  valores por omision y guardarlo en user://ajustes.json»
- `comprobacion`: el guion de la sección 5.

## 6. Archivos

`nucleo/controles_tactiles.gd` (lee el diseño), `nucleo/ajustes.gd` (lo guarda), un script nuevo para la cuenta,
la escena del editor en `nucleo/`, `nucleo/pausa.gd` y `.tscn` (botón «Controles»), guion y sala de prueba en
`herramientas/`, `docs/contrato.md`, `docs/pruebas.md`.

## Avance

- [x] Investigación (`investigador`, 07-oct-2026).
- [ ] Plan aprobado por la persona; entrada nueva de `funciones.json` aprobada.
- [ ] Cuenta y guion.
- [ ] Editor.
- [ ] Prueba en el S20 (persona).

## Fuentes (consultadas el 07-oct-2026)

[1] https://blog.activision.com/call-of-duty/2019-10/Getting-a-Grip-on-the-Call-of-Duty-Mobile-Controls (2019) ·
[2] https://www.siliconera.com/dead-cells-heads-to-smartphones-with-a-new-mobile-friendly-interface/ ·
[3] https://support.feralinteractive.com/en/mac-linux-games/alienisolation/faqs/ios_custom_layout/ (no se pudo abrir) ·
[4] https://support.google.com/accessibility/android/answer/7101858 ·
[5] https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/ ·
[6] https://docs.godotengine.org/en/stable/classes/class_displayserver.html (documentación `stable`, no 4.7)

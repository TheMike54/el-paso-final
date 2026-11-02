ACTIVO (escrito y aprobado por la persona el 1-nov-2026, para la tanda autónoma de esa noche)

# Auditoría final antes de la Play Store

El código de `nucleo/` es el ejemplo con el que el equipo construirá las demás salas y zonas. Esta auditoría revisa que
sirva como ejemplo y deja el paquete listo para publicar. No reabre las decisiones de las auditorías anteriores.

## Decisiones de la persona (1-nov-2026)

- Publicar en la Play Store es la prioridad. La cuenta propia vale y el profesor facilita los testers; la fecha del
  9-nov aplica al tablero y a los commits de todo el equipo.
- Las partidas viejas no se conservan entre versiones: sigue la decisión del 29-oct. La conversión queda para el final.
- 5.1 (La Celda silenciosa) y 1.4 (las aspas empujan, no devuelven a un lugar seguro) se quedan como están.
- Patas de Cucaracha: costo 1, `velocidad_factor` 1,25. En el juego se obtiene en Las Raíces.
- Azulito se integra a unos 64 px; el resto del arte no aprobado queda fuera.
- El mapa se queda como está; los mockups cubren Inventario, Amuletos y Útiles, con 3 propuestas por sección.
- Astra no se usa. Codex lleva cerca del 40 % de la carga, sin ser una cifra exacta.

Tras leer el reporte (1-nov-2026):

- Reporte aprobado, con sus recomendaciones: señal nueva en el bus para el guardado fallido y aviso corto en el HUD.
- Todo lo que se vaya a arreglar queda comprobado antes: cada fallo se reproduce con una prueba que falla y pasa con el
  arreglo. Lo que el reporte dejó sin comprobar se comprueba en esta tanda, salvo lo que exige el S21.
- Las Raíces no lleva jefe: solo enemigos. La primera zona enseña a jugar, y así baja la carga de trabajo.
- Cada compañero tendrá al menos 3 días, mejor 4, para sus salas. La metodología de equipo se pule tras resolver los hallazgos.

## Qué se audita

| Dimensión | Pregunta |
|---|---|
| Ejemplo para el equipo | ¿Solo con `docs/guias/` se llega a una sala y un enemigo correctos? |
| Redundancia | Literales repetidos, `Color(` fuera de `Tema`, funciones largas sin motivo, patrones que ya tienen pieza común |
| Comentarios | Regla de abajo |
| Android y robustez | Errores de archivos, lambdas que capturan nodos, señales de nodos que sobreviven, salidas de un `paused` |
| Rendimiento | Trabajo por cuadro en los archivos con `_process` y `_physics_process` |
| Paquete de publicación | AAB, filtros del preset, `Cargar.si_existe` sin `herramientas/pruebas/` |
| Documentación | Largos, caducos, contradicciones y estándar: `docs/`, guías, `CLAUDE.md`, `.claude/` y planes |

Fuera: J2 (sin máquina de estados del jugador ni partir `Partida`), J16, M5, M8, M9, P3, P4, P6, P7 y el código muerto
(barrido del 1-nov: 0 hallazgos).

## Regla de comentarios

Ninguna fuente consultada fija un porcentaje. Google (C++ y Python) y el kernel de Linux piden explicar el porqué o el
qué, no narrar el código. Anthropic y OpenAI solo lo dicen en sus prompts: comentar lo que no sea evidente e igualar la
densidad del código vecino.

1. Se conserva el porqué, la restricción que no se ve en el código y lo que cada parte espera de quien la usa.
2. Se borra lo que narra la línea o repite el nombre o el tipo.
3. Fechas, personas e ids de fallos van a `docs/errores/` o al plan; una cita de la documentación de Godot, sin número de línea.
4. Cada `.gd` conserva su cabecera de 3 o 4 líneas: qué hace y por qué.
5. Formato de Godot: comentario en su línea, `##` solo si el nombre no basta. La densidad sigue a la de los archivos vecinos.

## Límites

- Solo cambios que no alteren el comportamiento; lo dudoso se anota y queda para después de publicar.
- `jugador.gd`, guardado, contrato, autoloads, bus de eventos, `project.godot`, hooks y CI los escribe Claude; el resto
  puede construirlo Codex en worktree. Un archivo tiene un solo escritor a la vez.
- Todo hallazgo se comprueba contra el archivo antes de creerlo.
- Antes de un commit: `validar.ps1` con `fallos=0` y, al cerrar cada grupo, `correr-guiones.ps1` con `MALOS=0`.

## Pasos

| Paso | Qué | Se comprueba con |
|---|---|---|
| 1 | Azulito, ícono y ficha de Patas, Luna en `codex.ps1` | `validar.ps1`, guiones de amuletos y coleccionable |
| 2 | AAB: plantilla Gradle, preset y versión | AAB de depuración exportado, tamaño y alineación medidos |
| 3 | Detectar y verificar, por lotes | Lista de hallazgos confirmados en «Avance» |
| 4 | Ensayo de sala y enemigo con Sol | Lista de tropiezos de las guías |
| 5 | Mockups de menús | Archivos entregados a la persona |
| 6 | Estudio de factibilidad y plan de solución, en un reporte para la persona: qué se propone y por qué, cada decisión con su porqué y qué hace cada modelo de Anthropic y de Codex | Reporte entregado |
| 7 | Arreglar por grupos, solo tras aprobar el reporte | `validar.ps1`, `correr-guiones.ps1`, `revisor` en lo crítico |
| 8 | Cierre | Batería completa, `revisor`, APK en el S50, bloques de commit |
| 9 | Los 51 hallazgos de «tras publicar» y S07 a S10 | `validar.ps1`, `correr-guiones.ps1`, revisión de Sol |

Decidido por la persona el 1-nov-2026: los hallazgos no se arreglan en la tanda de esa noche; primero el reporte. El S21 no está
disponible; descargar herramientas queda autorizado.

## Avance

- Paso 1: hecho. Azulito a 64 px, ícono y ficha de Patas, Luna en `codex.ps1`. Guiones de amuletos, útiles, coleccionable,
  vitrina y sala de equipo: pasan.
- Paso 2: hecho. AAB de depuración de 105 MB; motor de 64 bits alineado a 16 KB. `herramientas/arreglar_uids.*` salió del
  paquete (H194). Falta el AAB firmado, que exporta la persona.
- Paso 3: 205 hallazgos, de los que 200 son reales y distintos: 3 repetidos y 2 falsos. La segunda lectura de Sol sumó 11
  fallos, leídos sin reproducir.
- Paso 4: Sol construyó una sala completa solo con las guías; 5 tropiezos, que entran al grupo «Ejemplo para el equipo».
- Paso 5: mockups entregados fuera del repo.
- Paso 6: reporte entregado. Antes de publicar: 137 hallazgos y 6 fallos de Sol. Tras publicar: 53 y 4. No hacer: 15 y 1.
- Grupos propuestos para el paso 7, en orden: guardado y bus; fallos visibles; paquete; comentarios; ejemplo para el
  equipo; documentos; cierre. Terra no sirve como lectura única: devolvió nada en cuatro lotes, y en dos de ellos Sol
  encontró fallos.
- Paso 7: hecho. Los 137 hallazgos de «antes de publicar» y los 6 fallos de Sol. Antes de arreglar se reprodujeron S01 a S06;
  S04 resultó peor que lo reportado: con el disco lleno, textos de 2000 y 3900 bytes dejaban la partida en 0 bytes y `err=0`
  (`docs/errores/2026-11-01-guardado-en-cero-bytes.md`). Las Raíces pasó a no tener jefes y el mapa sube: `docs/contrato.md`.
  Lo demás sin comprobar del reporte: la cita de Wen (2019) existe, el AAB queda bajo los límites de Play (módulo base 500 MB
  comprimido; 200 MB solo es aviso en datos móviles) y D1 se releyó con 3 hallazgos, corregidos.
- Paso 8: AAB de depuración de 110 MB instalado en el S50 con bundletool: entra en cinco partes (base, assets, ABI, idioma,
  densidad), arranca y llega al menú con video. `arreglar_uids`, `pruebas`, `validar` y `generar_efectos` no están en sus
  assets; `nucleo/` y `herramientas/salas` sí, como control. El APK de desarrollo quedó instalado después.
- Paso 9: hechos los 55 que quedaban (51 de «tras publicar» y S07 a S10). No aplicados: H072, H073 y H024, porque la medida en
  el S50 (`docs/arte-y-rendimiento.md`, «Mediciones») queda muy bajo el umbral; y H120, H069 y H094, excluidos por la persona.
  H049 y H059 quedaron resueltos con las cabeceras. S09 cambió de criterio: `Guardado.respaldar` conserva la copia anterior si
  la nueva falla, y Restaurar confirma «a su última copia». S07 se prueba con `Guardado.fingir_fallo`; la rama real de disco
  no tiene guion. H198: el contrato se partió en `docs/contrato.md`, `docs/sala.md` y `docs/validador.md` (uid y avisos). Las
  citas del contrato en los planes son historia: la regla de subida del mapa está ahora en `docs/sala.md`, `posicion_mapa`.
  Sol revisó antes, después (13 remisiones) y otra vez tras corregir (1 remisión). H197: `CLAUDE.md` dice que pasa de 120 líneas.

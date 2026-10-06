---
name: funcionalidad
description: Flujo para hacer una funcionalidad de El Paso Final de principio a fin, desde tomarla de funciones.json hasta entregar el bloque de commit con su evidencia. Usar cuando se pida la siguiente funcionalidad de un bloque, continuar el núcleo o las herramientas, o implementar una entrada de funciones.json.
---

# Hacer una funcionalidad

Una a la vez. No se empieza la siguiente hasta que esta tiene su evidencia y su bloque de commit.

1. **Elegir.** Leer el `CLAUDE.md` del bloque y su `funciones.json`. Se toma la primera entrada con
   `"pasa": false`, salvo que la persona nombre otra. Decir cuál es y cuál es su `"comprobacion"`.
2. **Contexto.** Si usa o cambia algo que otro bloque ve (autoloads, señales, forma de una sala, guardado),
   leer `docs/contrato.md`.
3. **Plan.** Cambio chico: el plan en pocas líneas en la conversación. Más de un archivo o más de una sesión:
   `planes/activos/<bloque>-<tema>.md` con `ACTIVO` en la primera línea, hitos que se puedan comprobar con un
   comando, y la aprobación de la persona antes de programar.
4. **Rama.** `git branch --show-current`. Si es `main`, dar a la persona el comando para crear la rama
   (`git switch -c feature/<bloque>-<desc>`) y esperar a que la cree.
5. **Programar.** Antes del primer `.gd`, usar la skill `gdscript4`. Cada `.gd` nuevo empieza con 3 o 4 líneas
   de comentario: qué hace y por qué. Las escenas heredan; no se copian archivos con UID.
6. **Comprobar.** Desde la raíz: `.\herramientas\validar.ps1` (también importa y genera los `.gd.uid`). Después,
   la `"comprobacion"` de la entrada: el guion, la prueba o, si es `manual:`, decir a la persona exactamente qué
   hacer y qué observar y esperar su respuesta.
7. **Evidencia.** Pegar la salida real del validador y de la comprobación. Si algo falla, se corrige la causa;
   no se cambia la comprobación para que pase.
8. **Marcar.** Solo con la evidencia a la vista, cambiar `"pasa"` a `true` en esa entrada. Nada más del JSON.
9. **Documentos.** Si cambió lo que el bloque ofrece: `docs/contrato.md` en el mismo cambio. Casos de QA
   ejecutados: `docs/pruebas.md`. Recurso nuevo: su fila en `docs/licencias.md`. `ESTADO.md` solo si cambió la
   rama, el PR, un bloqueo o una decisión abierta. Plan terminado: `CERRADO` y a `planes/cerrados/`.
10. **Releer.** Cada `.md` tocado, completo: sin texto dirigido a una persona ni avisos de trabajo sin terminar
    fuera de `ESTADO.md`, `funciones.json` y los planes.
11. **Entregar.** El bloque exacto para la persona: `git add` de rutas concretas (con los `.gd.uid`) y
    `git commit -m "feat: ..."` en inglés, sin líneas de atribución. Si cierra el PR, también el título y la
    descripción en inglés con What changed? · Why? · QA evidence · Risk / rollback, y dentro de What changed?
    qué herramienta de IA se usó y en qué parte.

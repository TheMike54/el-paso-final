# Cómo se trabaja: de la funcionalidad al PR

**Para qué sirve:** recorrer el ciclo de una funcionalidad, desde la rama hasta el PR, sin saltarse un paso.

**Antes de empezar:** haber hecho `docs/guias/empezar.md` y leer el `CLAUDE.md` de la raíz (secciones «Cómo se
trabaja», «Modelos y revisión» y «Reglas de este proyecto») y `ESTADO.md`. El flujo completo, paso a paso, está en la
skill `funcionalidad` (`.claude/skills/funcionalidad/SKILL.md`); esta receta lo resume.

1. Leer `ESTADO.md` (rama, PR en curso, bloqueos) y el `CLAUDE.md` y el `funciones.json` del bloque donde se trabaja
   (`nucleo/`, `contenido/`, `interfaz/`, `herramientas/`, `mapa/`).
2. Crear la rama desde `main`; nunca se edita en `main`. La rama la crea la persona: el asistente da el comando
   (skill `funcionalidad`, paso 4). Nombres y reglas de ramas, commits y PR: `CLAUDE.md`, «Reglas de este
   proyecto».
3. Elegir una funcionalidad: la primera entrada con `"pasa": false` del `funciones.json` del bloque, o la que la
   persona nombre; si espera hardware o firma, se anota como bloqueo en `ESTADO.md` y se toma la siguiente (skill
   `funcionalidad`, paso 1). Una a la vez.
4. Planear. Cambio chico: el plan en pocas líneas, en la conversación (skill `funcionalidad`, paso 3). Más de un
   archivo o más de una sesión: archivo en `planes/activos/<bloque>-<tema>.md`, con su estado en la primera línea y
   aprobado por la persona antes de programar (`CLAUDE.md`, «Cómo se trabaja»). Al terminar la funcionalidad, en
   el mismo cambio, el plan queda `CERRADO` y pasa a `planes/cerrados/` (skill `funcionalidad`, paso 9).
5. Programar. Antes de un `.gd`, la skill `gdscript4`; antes de interfaz táctil, física o arte, las skills que
   nombra `CLAUDE.md`, «Entorno y trampas». Cada `.gd` nuevo empieza con comentario de qué hace y por qué.
6. Validar con `.\herramientas\validar.ps1` y correr la `"comprobacion"` de la entrada (un guion, una prueba o una
   fila manual de `docs/pruebas.md`). Si algo falla se corrige la causa; no se cambia la comprobación.
7. Pedir el `revisor` solo en los puntos críticos que lista `CLAUDE.md`, «Modelos y revisión». Lo demás lo cubre
   `validar.ps1`.
8. Con la evidencia a la vista, cambiar `"pasa"` a `true` en esa entrada de `funciones.json` y nada más del archivo.
9. Documentar en el mismo cambio: `docs/contrato.md` si cambió lo que un bloque ofrece a otro; `docs/pruebas.md`
   con los casos ejecutados; `ESTADO.md` solo si cambió la rama, el PR, un bloqueo o una decisión abierta (se
   sobrescribe, con el máximo de líneas que fija `CLAUDE.md`). Una herramienta de IA nueva o un recurso de otra
   persona (fuente, sonido, imagen) lleva su línea en `docs/uso-de-ia.md` en este mismo cambio; sin eso no entra.
10. Si se encontró un error del código, escribir `docs/errores/AAAA-MM-DD-tema.md` en el mismo cambio que el
    arreglo (forma: `CLAUDE.md`, «Cómo se trabaja»; ejemplo: cualquier archivo de `docs/errores/`).
11. Los commits los hace la persona que responde por el cambio, con su identidad de git; el asistente solo da el
    bloque de comandos (skill `funcionalidad`, paso 11). El asistente no ejecuta `git commit`, `git push` ni
    `gh pr create`. Sin asistente, los comandos son los mismos, a mano, desde la raíz:

    ```
    git switch -c feature/contenido-celda-sala-6
    git status --short
    git add contenido/salas/celda/celda_6.tscn mapa/indice_salas.tres contenido/funciones.json
    git commit -m "feat: add the sixth cell room with its doors and path script"
    git push -u origin feature/contenido-celda-sala-6
    ```

    `git add` lleva rutas concretas (nunca `git add .`), con los `.gd.uid` y los documentos cambiados. El mensaje va en
    inglés, con prefijo `feat:`, `fix:`, `docs:` o `chore:` y sin líneas de coautoría (el hook `commit-msg` las
    rechaza). El PR se abre en GitHub desde la rama con la plantilla de `.github/pull_request_template.md`.
12. Abrir el PR con las secciones de `.github/pull_request_template.md`: What changed?, Why?, QA evidence y
    Risk / rollback. En What changed? va la herramienta de IA usada y la parte que produjo. El PR lleva la etiqueta
    `qa-pending` hasta que se aprueba (la pone y la quita `.github/workflows/qa-label.yml`); el check que exige el
    ruleset es `validar` (`CLAUDE.md`, «Decisiones cerradas»).

## Qué no se hace

- No se leen ni escriben los archivos de credenciales y claves que lista `CLAUDE.md`, «Reglas de este proyecto».
- No se mueven ni borran escenas, recursos o imágenes fuera del editor (`CLAUDE.md`, «Entorno y trampas»).
- No se sube texto dirigido a una persona ni avisos de trabajo sin terminar, salvo en `ESTADO.md`,
  `funciones.json` y los planes.

## Si algo falla

- Un fallo que se parezca a uno anterior: leer `docs/errores/` antes de arreglarlo.
- Una orden de git rechazada por el hook del repo: `herramientas/CLAUDE.md`, «Reglas» (último punto) explica qué
  frena y `herramientas/probar-sin-commit.ps1` lo prueba.
- Un guion que falla: formato y condiciones de fallo en `docs/guiones.md`.

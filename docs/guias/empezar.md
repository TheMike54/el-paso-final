# Empezar: del clon al juego corriendo

**Para qué sirve:** dejar un equipo nuevo con el proyecto clonado, importado, validado y abierto.

**Antes de empezar:** leer el `README.md` de la raíz del repo (no el índice de `docs/guias/`; secciones «Entorno» y
«Ejecutar desde un clon limpio») y las secciones
«Comandos» y «Entorno y trampas» del `CLAUDE.md` de la raíz. Esta receta solo ordena los pasos; las versiones, las
URL y los comandos exactos viven en esos dos archivos.

Todos los comandos son de PowerShell y se corren desde la raíz del repo.

1. Instalar Godot en la versión exacta que fija `README.md` («Entorno»). Si el editor ofrece convertir el proyecto,
   la respuesta es no (`CLAUDE.md`, «Entorno y trampas»).
2. Guardar la ruta del ejecutable de consola en `GODOT_PATH` con el comando `setx` de `README.md`, paso 2 de
   «Ejecutar desde un clon limpio», y abrir una terminal nueva: la variable solo existe en las terminales abiertas
   después. Ese mismo ejecutable de consola sirve para importar, correr el juego y abrir el editor.
3. Clonar el repositorio e importar el proyecto (`README.md`, paso 3). Repetir la importación al agregar un asset o
   un `class_name` (`CLAUDE.md`, «Comandos»).
4. Revisar el entorno con `.\herramientas\verificar-entorno.ps1`. Debe terminar con `ENTORNO OK`; además activa el
   hook de git del repo, porque `core.hooksPath` no viaja al clonar (`README.md`, paso 4).
5. Validar con `.\herramientas\validar.ps1`. Solo pasa si imprime `OK  VALIDACION archivos=N fallos=0`. El código
   de salida de Godot no sirve para saberlo (`CLAUDE.md`, «Entorno y trampas»).
6. Para programar, bajar la copia local de la documentación de Godot y guardar su ruta en `GODOT_DOCS`
   (`README.md`, paso 6). Es la fuente que se consulta antes de usar una clase o señal de Godot que no esté en la
   skill `gdscript4` (`CLAUDE.md`, «Entorno y trampas»).
7. Correr el juego con el comando de `CLAUDE.md`, «Comandos». Abrir el editor con el comando de `README.md`, paso 7.
8. Probar un guion de ejemplo, para confirmar que el entorno corre las pruebas sin ventana:
   `.\herramientas\correr-guiones.ps1 -Guiones contenido/celda_1_puertas`. Debe terminar con `RESUMEN ... MALOS=0`
   (formato de la línea y opciones: `docs/guiones.md`, inicio).
9. Seguir con `docs/guias/como-trabajamos.md`.

## Qué mirar en el menú del juego

- La zona de pruebas (menú principal, con Configuración, Avanzado, Desarrollador en «Sí») reúne una sala por pieza
  del núcleo; cómo se entra y qué hay en cada una: `docs/salas-de-prueba.md`, «Cómo se entra».
- Lo que no se comprueba sin ventana (táctil, sensación del salto, FPS en el teléfono) se prueba a mano con las
  filas de `docs/pruebas.md`.

## Si algo falla

- `verificar-entorno.ps1` dice qué falta y lo que no es un fallo (`GODOT_DOCS`, `adb`) lo avisa sin fallar
  (`herramientas/CLAUDE.md`, fila `verificar-entorno.ps1`).
- Si PowerShell no deja correr scripts: `README.md`, paso 4, da la orden con `-ExecutionPolicy Bypass`.
- Un script que no compila no se nota en el código de salida: el detalle de `validar.ps1` queda en
  `.godot\validar.log` (`herramientas/CLAUDE.md`, «Reglas»).
- Un fallo que se parezca a uno anterior: `docs/errores/`, antes de arreglarlo.

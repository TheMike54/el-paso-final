# El Paso Final

Metroidvania 2D para Android hecho en Godot 4.7.2. Un alumno de ESCOM se queda dormido ensayando su presentación
de Trabajo Terminal y despierta debajo de la escuela: para titularse tiene que subir, zona por zona, hasta su
salón y vencer a los tres sinodales que le cierran el paso.

Proyecto del equipo para Desarrollo de Aplicaciones Móviles Nativas (ESCOM-IPN).

## Entorno

| Herramienta | Versión con la que se desarrolla |
|---|---|
| Sistema operativo | Windows 11 |
| Godot | 4.7.2 estable, edición estándar (`4.7.2.stable.official.ed1daf0bf`) |
| Git | 2.54 para Windows |
| PowerShell | 5.1 (incluido en Windows) o 7 |

Todo el equipo usa exactamente Godot 4.7.2: un proyecto guardado con una versión más nueva no abre en una
anterior. Si el editor ofrece convertir el proyecto, la respuesta es no.

## Ejecutar desde un clon limpio

Los comandos son de PowerShell.

1. Descargar Godot 4.7.2 (Windows, edición estándar) de <https://godotengine.org/download/archive/4.7.2-stable/>
   y descomprimirlo en una carpeta fija.
2. Guardar en la variable `GODOT_PATH` la ruta del ejecutable de consola y abrir una terminal nueva:

   ```powershell
   setx GODOT_PATH "C:\ruta\a\Godot_v4.7.2-stable_win64_console.exe"
   ```

3. Clonar el repositorio e importar el proyecto:

   ```powershell
   git clone https://github.com/TheMike54/el-paso-final.git
   cd el-paso-final
   & $env:GODOT_PATH --headless --path . --import
   ```

4. Abrir el proyecto en el editor:

   ```powershell
   & $env:GODOT_PATH --path . --editor
   ```

## Licencia

El código se publica bajo la licencia MIT (archivo `LICENSE`). El arte, la música y los textos del juego no
están cubiertos por esa licencia: son del equipo, con todos los derechos reservados.

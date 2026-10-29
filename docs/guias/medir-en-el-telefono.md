# Cómo medir el juego en el teléfono

**Para qué sirve:** instalar el APK de desarrollo en un teléfono por `adb`, ver los FPS y anotar el resultado.
**Antes de empezar:** leer `CLAUDE.md` («Comandos» y «Decisiones cerradas», viñeta Android), `docs/pruebas.md`
(«Medición de rendimiento» y «Casos manuales») y `docs/contrato.md` («Recursos» y «Paquete de publicación»). La skill
`rendimiento-gama-baja` va antes de proponer una optimización.

1. Tener el Android SDK con `platform-tools` y el teléfono conectado por USB. Revisar el entorno con
   `.\herramientas\verificar-entorno.ps1`, que avisa si falta `adb`.
2. Definir `adb` (ruta que busca `herramientas/verificar-entorno.ps1`) y ver el teléfono:
   ```powershell
   $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
   & $adb devices
   ```
   Con más de un teléfono, agregar `-s <serie>` a cada comando de `adb`.
3. Exportar el APK del preset «Desarrollo» (lleva todo lo demás y arranca con `--print-fps`; «Publicacion» no sirve
   para medir: `docs/contrato.md`, «Paquete de publicación»). `build/` está ignorado por git:
   ```powershell
   & $env:GODOT_PATH --headless --path . --export-debug "Desarrollo" build\desarrollo.apk
   ```
4. Instalar: `& $adb install -r build\desarrollo.apk`. Cada máquina firma con su propia clave: un APK exportado en
   otra máquina no se instala encima del que ya está, y desinstalar borra partidas y ajustes (`docs/pruebas.md`,
   «Casos manuales», encabezado).
5. Ver los FPS de dos formas: `& $adb logcat -s godot` (por `--print-fps`) o el contador en pantalla, en
   Configuración > Avanzado > Mostrar FPS (`docs/contrato.md`, «Menú»; ajuste `mostrar_fps` en «Ajustes y
   vibración»). Recursos y FPS en ese mismo panel cambian el modo de la prueba: anotar con cuál se midió.
6. Elegir el caso en `docs/pruebas.md`, «Casos manuales» (filas «Rendimiento en el teléfono», «FPS en el teléfono»,
   «La Celda», «Sala de arte (rendimiento)»), que dice qué sala recorrer y qué observar. Memoria del juego:
   `& $adb shell dumpsys meminfo com.themike54.elpasofinal`.
7. Para comparar una pieza sospechosa, medir A/B con y sin ella en la misma sala y el mismo teléfono; no se supone
   qué limita los FPS (`docs/contrato.md`, «Recursos», «Receta del arte de una sala»). La herramienta de A/B y su
   APK aparte, armado en una copia fuera del repo: `docs/pruebas.md`, «Medición de rendimiento».
8. Observar y anotar: FPS medios y el peor cuadro, memoria (PSS), tirones al cruzar puertas, y el equipo, la versión
   de Android y los ajustes usados. El teléfono frío y la misma duración en cada corrida.
9. Anotar el resultado en la columna «Última ejecución» de la fila de `docs/pruebas.md` (se reemplaza, no se agrega;
   lleva fecha absoluta, equipo y resultado). Lo que no se comprueba sin ventana (táctil, sensación del salto, FPS
   en el teléfono) lo observa la persona (`CLAUDE.md`, «Comandos»).
10. Si se hizo un APK de medición con otro id, desinstalarlo al terminar
    (`& $adb uninstall com.themike54.elpasofinal.medicion`).
11. El commit con la anotación lo hace la persona que responde por el cambio (skill `funcionalidad`, paso
    «Entregar»).

## Si algo falla
- No aparece el teléfono en `adb devices`, o la instalación se rechaza: revisar el cable y la firma (paso 4).
- La exportación falla o el APK no abre: `.\herramientas\verificar-entorno.ps1`, y `CLAUDE.md`, «Entorno y trampas».
- Los FPS se topan en el refresco de la pantalla: es esperado en Android (`docs/pruebas.md`, «Medición de
  rendimiento», paso 3).
- Otros fallos: `docs/guias/cuando-algo-falla.md` y `docs/errores/`.

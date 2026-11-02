# Publicar una versión

**Para qué sirve:** exportar el paquete Android y probarlo en un grupo cerrado.

**Antes de empezar:** leer `docs/contrato.md`, «Paquete de publicación», y `export_presets.cfg`. Tener configuradas las herramientas de exportación Android y la firma fuera del repositorio.

1. Con el editor abierto, revisar Proyecto → Exportar → `Publicacion`: usa Gradle y AAB. Actualizar `version/code` a un entero mayor que el de la versión ya subida y `version/name` a la versión visible; ambos están en `export_presets.cfg`.
2. En consola ejecutar `.\herramientas\validar.ps1` y comprobar `OK  VALIDACION ... fallos=0`. Exportar en modo release con el preset `Publicacion` a un archivo `.aab` fuera del código fuente; también se puede usar el diálogo de exportación del editor.
3. En Play Console crear una versión de prueba cerrada, subir el AAB, completar los requisitos de la consola y habilitar el acceso del grupo de prueba. Instalar desde el enlace de prueba en un teléfono y comprobar arranque, controles, guardado, audio y recorrido principal.
4. Verificar también la zona de pruebas con el modo desarrollador y el filtro del paquete según `docs/contrato.md`, «Paquete de publicación». El AAB y los datos de firma no se guardan en el repositorio.

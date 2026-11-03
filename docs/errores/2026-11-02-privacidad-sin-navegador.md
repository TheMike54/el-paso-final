# El botón de privacidad no hacía nada en un teléfono sin navegador

**Síntoma.** En el S50, tocar «Política de privacidad» en Créditos no abría nada ni avisaba.

**Causa.** Ese teléfono no tiene un navegador instalado: Android no resuelve el enlace (`START_INTENT_NOT_RESOLVED`,
`ActivityNotFoundException` en el registro) y `OS.shell_open` devuelve error. El código solo lo anotaba en el registro.

**Arreglo.** `nucleo/configuracion.gd`, `avisar_sin_navegador()`: si `OS.shell_open` falla, Créditos muestra la
dirección de la política para copiarla.

**Guion.** `nucleo/menu_configuracion`, caso «sin navegador, Creditos muestra la direccion de la politica».

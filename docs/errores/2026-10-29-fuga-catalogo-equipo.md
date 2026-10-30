# El catálogo de amuletos y útiles dejaba recursos sin liberar al salir

## Síntoma

Al agregar `CatalogoEquipo`, `validar.ps1` falló por fugas al cerrar el motor, sin ningún error de compilación:
«2 RID allocations of type 'P12GodotShape2D' leaked», «118 ObjectDB instances leaked» y «102 resources still in use».
Lo retenido eran recursos, no nodos: `sala.gd`, `jugador.tscn`, las páginas del marco, el banco, la mochila y otros.

## Causa

Las funciones estáticas de `nucleo/catalogo_equipo.gd` (`amuleto`, `util` y una auxiliar `_catalogos`) tipaban el
catálogo cargado como `CatalogoEquipo`, es decir, el script se nombraba a sí mismo. Llamadas desde el autoload
`Partida`, eso dejó al salir un ciclo de referencias entre scripts que el motor no libera, y con él todo lo que esos
scripts alcanzan. Se acotó por bisección: sin las llamadas de `partida.gd` al catálogo no había fugas, y con un
catálogo que no se nombra a sí mismo tampoco. La documentación de Godot 4.7 no describe este caso; la causa está
comprobada por esos experimentos, no por el código del motor.

## Arreglo

`amuleto` y `util` leen el catálogo como `Resource` y sus listas con `get()`; las fichas siguen tipadas
(`FichaAmuleto`, `FichaUtil`). Se quitó `_catalogos`. El comentario de `amuleto` dice por qué no se nombra la clase.

## Guion que lo cubre

`validar.ps1`: falla si hay fugas al salir. Lo que el catálogo hace lo cubre `herramientas/guiones/nucleo/amuletos`.

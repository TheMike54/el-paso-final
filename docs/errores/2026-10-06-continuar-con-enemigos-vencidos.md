# Continuar dejaba vencidos a los enemigos fuertes

- **Síntoma**: vencer a un enemigo fuerte, salir al menú y tocar Continuar dejaba a ese enemigo sin aparecer
  hasta descansar, aunque Continuar empieza en un banco. La Inspiración también seguía.
- **Causa**: `Partida.desde_diccionario()` cargaba lo guardado pero no limpiaba lo que no se guarda.
- **Arreglo**: `nucleo/partida.gd` vacía `enemigos_vencidos` y pone la Inspiración en 0 al cargar.
- **Guion que lo cubre**: `herramientas/guiones/nucleo/guardado.guion`, caso «continuar empieza sin Inspiracion y
  sin enemigos vencidos». Sin el arreglo da `fallos obtenido=1.00`. Lo encontró el revisor.

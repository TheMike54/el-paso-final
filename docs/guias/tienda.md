# Tienda

**Para qué sirve:** vender recompensas por PejeCoins.

**Antes de empezar:** leer `docs/componentes.md`, filas `Tienda`, `ArticuloTienda` y `Recompensa`. Modelo: `herramientas/salas/sala_tienda.tscn`.

1. Con el editor abierto, agregar a la raíz de la sala un `Area2D` con `nucleo/tienda.gd`; definir `id` único en la sala y `nombre`.
2. Llenar `articulos` con recursos `ArticuloTienda`: `id` único en la tienda, `nombre`, `descripcion`, `precio` mayor que cero y `recompensa`. `requisito` vacío muestra el artículo siempre; si se usa, debe ser una habilidad existente (`nucleo/articulo_tienda.gd`).
3. En consola ejecutar `.\herramientas\validar.ps1` y un guion basado en `herramientas/guiones/nucleo/tienda.guion`. En el juego comprobar precio, falta de monedas, requisito, confirmación y que la compra no se repita al volver.

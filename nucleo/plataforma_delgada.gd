class_name PlataformaDelgada
extends StaticBody2D
# Plataforma de una via: se atraviesa caminando o saltando desde abajo y se pisa al caer sobre ella. Es la unica
# excepcion a «todo solido» (docs/contrato.md, «Sala»): piezas que cuelgan o se ven delgadas en una ruta escondida,
# donde subirse de un salto es parte de descubrirla. Forma, grosor y margen los fija aqui, asi no varian por sala.

## Grosor de la forma, en px, hacia abajo desde el origen (el origen es la cara de arriba).
const GROSOR: float = 20.0
## Margen de la una via, en px (classes/class_collisionshape2d.rst:153). Medido el 27-oct-2026: con 1 px el jugador no
## la atraviesa ni cayendo a 20 px por tick ni en picada a 30, en 30 fases distintas (el guion
## nucleo/plataformas repite 10 de ellas); con mas margen, caminar sube
## encima de una cara a menos de ese margen sobre el suelo (32 px subia una cara a 30 px). Por eso el minimo.
const MARGEN: float = 1.0

## Ancho de la cara que se pisa, centrada en el origen, en px.
@export var ancho: float = 160.0


func _ready() -> void:
	Capas.poner(self, Capas.ESCENARIO, 0)
	var rectangulo: RectangleShape2D = RectangleShape2D.new()
	rectangulo.size = Vector2(ancho, GROSOR)
	var forma: CollisionShape2D = CollisionShape2D.new()
	forma.name = &"Forma"
	forma.shape = rectangulo
	forma.position = Vector2(0.0, GROSOR / 2.0)
	forma.one_way_collision = true
	forma.one_way_collision_margin = MARGEN
	add_child(forma)

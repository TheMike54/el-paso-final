// Destello en blanco del cuerpo del jugador (congelado, parry): mezcla el color con blanco segun cantidad, sin tocar
// el alfa. Compatibility satura el color en 1, asi que un modulate mayor que 1 no aclara; HK hace lo mismo con
// _FlashAmount. Una sola lectura de textura (la que ya hace el sprite).
shader_type canvas_item;

uniform float cantidad : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), cantidad);
}

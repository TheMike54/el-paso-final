// Franja de niebla sin orillas: el alfa baja a 0 arriba y abajo (seno de la altura). Una sola lectura de textura.
shader_type canvas_item;
render_mode unshaded;

void fragment() {
	COLOR = texture(TEXTURE, UV) * COLOR;
	COLOR.a *= sin(UV.y * PI);
}

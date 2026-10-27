// Desenfoque del video detras de Configuracion (ReproductorVideo.desenfocar): reduce y desenfoca en una pasada. Cada
// px chico promedia 4x4 muestras lineales repartidas en una zona del doble de su tamano (paso = tamano de un px chico
// en UV), con pesos de campana. Una pasada mas costaba ~3 FPS en el S50 (demo de La Celda, 25-oct-2026).
shader_type canvas_item;

uniform vec2 paso = vec2(0.01, 0.01);

void fragment() {
	vec4 suma = vec4(0.0);
	float total = 0.0;
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			vec2 d = vec2(float(i), float(j)) - 1.5;
			float peso = exp(-dot(d, d) * 0.35);
			suma += texture(TEXTURE, UV + d * paso * 0.5) * peso;
			total += peso;
		}
	}
	COLOR = suma / total;
}

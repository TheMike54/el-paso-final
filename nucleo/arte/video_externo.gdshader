// Dibuja la ExternalTexture donde MediaPlayer deja cada cuadro del video (samplerExternalOES, solo Compatibility en
// Android: classes/class_externaltexture.rst). SurfaceTexture trabaja con el origen abajo, y su matriz habitual
// (getTransformMatrix, escala 1 y -1, desplazamiento 0 y 1) lo voltea de vuelta: queda la UV tal cual. Asi se vio
// bien en el S50 y el S21 sin leer la matriz (25-oct-2026).
shader_type canvas_item;

uniform samplerExternalOES externa;

void fragment() {
	COLOR = texture(externa, vec2(UV.x, UV.y));
}

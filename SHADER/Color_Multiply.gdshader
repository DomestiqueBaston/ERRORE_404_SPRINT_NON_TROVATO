shader_type canvas_item;
render_mode blend_premul_alpha, unshaded; 
// unshaded + blend_premul_alpha = comportement identique à ton shader qui marchait

void fragment() {
	// On récupère ce qui est rendu juste en dessous du ColorRect
	vec4 base = texture(TEXTURE, UV);
	
	// ←←←←← METS ICI L’EFFET QUE TU VEUX ←←←←←
	// Exemple tout simple : on décale toute l’image de 100 px vers la droite
	vec2 shifted_uv = UV + vec2(0.05, 0.0); // 0.05 ≈ 100 px sur un écran 1920px
	vec4 color = texture(TEXTURE, shifted_uv);
	
	// Si tu veux garder la transparence là où il n’y a rien
	if (base.a < 0.01) {
		COLOR = vec4(0.0);
	} else {
		COLOR = color;
	}
}
shader_type canvas_item;
render_mode blend_premul_alpha, unshaded; 

void fragment() {
	// On récupère ce qui est rendu juste en dessous du ColorRect
	vec4 base = texture(TEXTURE, UV);
	
	vec2 shifted_uv = UV + vec2(0.0, 0.0); // 0.05 ≈ 100 px sur un écran 1920px
	vec4 color = texture(TEXTURE, shifted_uv);
	
	// Garder la transparence quand y'a rien
	if (base.a < 0.01) {
		COLOR = vec4(0.0);
	} else {
		COLOR = color;
	}
}
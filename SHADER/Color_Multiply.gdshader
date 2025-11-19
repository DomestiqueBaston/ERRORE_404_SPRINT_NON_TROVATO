shader_type canvas_item;
render_mode blend_premul_alpha;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform vec4 tint_color : source_color = vec4(1.0, 0.4, 0.4, 1.0);

void fragment() {
    vec4 base = texture(TEXTURE, UV);
    
    if (base.a < 0.01) {
        COLOR = vec4(0.0);
    } else {
        // Luminosité perçue du pixel (0.0 = noir, 1.0 = blanc)
        float lum = dot(base.rgb, vec3(0.299, 0.587, 0.114));
        
        // Plus c'est lumineux et moins on applique la teinte
        // Donc masque = 1.0 - lum
        float mask = clamp(1.1 - lum, 0.0, 1.0);
        
        // On multiplie par la couleur désirée, mais seulement sur les zones sombres
        vec3 tinted = base.rgb * mix(vec3(1.0), tint_color.rgb * 2.0, mask * intensity);
        
        COLOR = vec4(tinted * base.a, base.a);
    }
}
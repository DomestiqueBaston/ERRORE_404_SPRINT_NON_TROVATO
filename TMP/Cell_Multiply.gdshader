shader_type canvas_item;
render_mode blend_premul_alpha, unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.8;
uniform vec4 tint_color : source_color = vec4(1.0, 0.3, 0.2, 1.0);

void fragment() {
    vec4 base = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    if (base.a < 0.01) {
        COLOR = vec4(0.0);
    } else {
        float lum = dot(base.rgb, vec3(0.299, 0.587, 0.114));
        
        // Plus c'est clair → plus on applique la teinte (inverse de ce qu'on faisait avant)
        float mask = lum;                    // 0.0 sur noir, 1.0 sur blanc
        mask = pow(mask, 0.5);               // rend l'effet plus fort sur les clairs
        
        vec3 tinted = base.rgb * mix(vec3(1.0), tint_color.rgb, mask * intensity);
        
        COLOR = vec4(tinted, base.a);
    }
}
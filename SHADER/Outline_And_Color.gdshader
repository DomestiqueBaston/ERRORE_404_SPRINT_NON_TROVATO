shader_type canvas_item;

// Uniforms de l'outline
uniform float outline_thickness : hint_range(0.0, 3.0, 1.0) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Uniforme pour la couleur du sprite (en maintenant l'alpha)
uniform vec4 sprite_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

bool is_inside_usquare(vec2 x) {
    return x == clamp(x, vec2(0.0), vec2(1.0));
}

vec4 blend(vec4 bottom, vec4 top) {
    float alpha = top.a + bottom.a * (1.0 - top.a);
    if (alpha < 0.0001) return vec4(0.0);
    vec3 color = mix(bottom.rgb * bottom.a, top.rgb, top.a) / alpha;
    return vec4(color, alpha);
}

void fragment() {
    vec2 uv = UV;
    vec4 final_color = texture(TEXTURE, uv);

    // Modifier la couleur du sprite tout en conservant l'alpha
    final_color.rgb *= sprite_color.rgb; // Applique la couleur sur RGB
    final_color.a *= sprite_color.a;     // Applique l'alpha si nécessaire

    // Appliquer l'outline
    if (outline_thickness > 0.0 && outline_color.a > 0.0) {
        float alpha = 0.0;
        vec2 pos = uv;

        // Vérification des pixels voisins pour créer l'outline
        for (float y = 1.0; y <= outline_thickness; y += 1.0) {
            for (float x = 0.0; x <= y; x += 1.0) {
                if (length(vec2(x, y - 0.5)) > outline_thickness) break;
                
                vec2 look_at_uv[8];
                look_at_uv[0] = pos + vec2(x, y) * TEXTURE_PIXEL_SIZE;
                look_at_uv[1] = pos + vec2(-x, y) * TEXTURE_PIXEL_SIZE;
                look_at_uv[2] = pos + vec2(x, -y) * TEXTURE_PIXEL_SIZE;
                look_at_uv[3] = pos + vec2(-x, -y) * TEXTURE_PIXEL_SIZE;
                look_at_uv[4] = pos + vec2(y, x) * TEXTURE_PIXEL_SIZE;
                look_at_uv[5] = pos + vec2(-y, x) * TEXTURE_PIXEL_SIZE;
                look_at_uv[6] = pos + vec2(y, -x) * TEXTURE_PIXEL_SIZE;
                look_at_uv[7] = pos + vec2(-y, -x) * TEXTURE_PIXEL_SIZE;
                
                for (int i = 0; i < 8; i++) {
                    if (is_inside_usquare(look_at_uv[i])) {
                        float look_at_alpha = texture(TEXTURE, look_at_uv[i]).a;
                        alpha = max(alpha, look_at_alpha);
                        if (alpha >= 0.9999) break;
                    }
                }
                if (alpha >= 0.9999) break;
            }
            if (alpha >= 0.9999) break;
        }

        // Appliquer l'outline avec la couleur et l'alpha calculé
        vec4 outline_layer = vec4(outline_color.rgb, alpha * outline_color.a);
        final_color = blend(outline_layer, final_color);
    }

    // Ne pas afficher si la couleur finale a une transparence trop faible
    if (final_color.a < 0.01) discard;

    // Retourner la couleur finale après application de l'outline
    COLOR = final_color;
}

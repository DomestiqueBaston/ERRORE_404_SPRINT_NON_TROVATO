shader_type canvas_item;
uniform vec4 drop_shadow_color : source_color = vec4(0.01, 0.01, 0.5, 0.15);
uniform vec2 shadow_offset = vec2(float(0), float(0.05));
uniform bool shadow_enabled = true;
uniform float shadow_blur : hint_range(0.0, 10.0) = 3.0;

// Fonction pour échantillonner la texture en évitant les artefacts
vec4 sample_texture(sampler2D texture, vec2 uv) {
    if ((uv.x < 0.0 || uv.x > 1.0) || (uv.y < 0.0 || uv.y > 1.0)) {
        return vec4(0.0);
    } else {
        return texture(texture, uv);
    }
}

// Fonction pour mélanger deux couleurs
vec4 mixcolor(vec4 colA, vec4 colB) {
    return vec4((colA.rgb + colB.a * (colB.rgb - colA.rgb)), colA.a + colB.a);
}

// Fonction de blur (box blur) sur l'alpha uniquement
float blur_alpha(sampler2D tex, vec2 uv, float blur_size) {
    float total_alpha = 0.0;
    float total = 0.0;
    float step = 1.0 / blur_size;

    for (float x = -blur_size; x <= blur_size; x += step) {
        for (float y = -blur_size; y <= blur_size; y += step) {
            vec2 offset = vec2(x, y) * 0.005;
            total_alpha += sample_texture(tex, uv + offset).a;
            total += 1.0;
        }
    }

    return total_alpha / total;
}

void fragment() {
    vec2 uv = UV;
    vec4 original_color = sample_texture(TEXTURE, uv);

    if (shadow_enabled) {
        vec2 shadow_uv = uv - shadow_offset;
        // Appliquer le blur uniquement sur l'alpha de l'ombre
        float blurred_alpha = blur_alpha(TEXTURE, shadow_uv, shadow_blur);
        vec4 shadow_color = vec4(drop_shadow_color.rgb, blurred_alpha * drop_shadow_color.a);

        if (shadow_color.a > 0.0) {
            COLOR = mixcolor(shadow_color, original_color);
        } else {
            COLOR = original_color;
        }
    } else {
        COLOR = original_color;
    }
}

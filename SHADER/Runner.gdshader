shader_type canvas_item;

// Uniforms du tremblement
instance uniform bool shake_enabled = false;
instance uniform float shake_power : hint_range(0.0, 0.01, 0.0001) = 0.001;
instance uniform float shake_speed : hint_range(0.0, 100.0, 0.1) = 10.0;
instance uniform float shake_block_size = 150.0;
instance uniform float shake_color_rate : hint_range(0.0, 0.02, 0.0001) = 0.0007;

// Uniforms de l'outline
uniform float outline_thickness : hint_range(0.0, 5.0, 1.0) = 2.0;
instance uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_boost_when_glitch : hint_range(0.0, 100.0, 0.1) = 100.0;


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
    float enable_shift = float(shake_enabled);

    vec2 base_uv = UV;
    base_uv.x += enable_shift * shake_power * sign(sin(trunc(UV.y * shake_block_size) * 5.0 + TIME * shake_speed));
    base_uv.y += enable_shift * shake_power * sign(cos(trunc(UV.x * shake_block_size) * 2.0 + TIME * shake_speed));

    vec4 original_color = texture(TEXTURE, base_uv);

    // ─── Outline sur l’image NON glitchée ───────────────────────────────
    float outline_alpha = 0.0;

    if (outline_thickness > 0.0 && outline_color.a > 0.0) {
        vec2 pos = base_uv;

        for (float y = 1.0; y <= outline_thickness; y += 1.0) {
            for (float x = 0.0; x <= y; x += 1.0) {
                if (length(vec2(x, y - 0.5)) > outline_thickness) continue;

                vec2 dirs[8] = vec2[](
                    vec2( x,  y), vec2(-x,  y),
                    vec2( x, -y), vec2(-x, -y),
                    vec2( y,  x), vec2(-y,  x),
                    vec2( y, -x), vec2(-y, -x)
                );

                for (int i = 0; i < 8; i++) {
                    vec2 sample_uv = pos + dirs[i] * TEXTURE_PIXEL_SIZE;
                    if (is_inside_usquare(sample_uv)) {
                        outline_alpha = max(outline_alpha, texture(TEXTURE, sample_uv).a);
                    }
                }
            }
        }

        // Boost d’intensité quand glitch actif
        float outline_boost = 1.0 + (outline_boost_when_glitch - 1.0) * enable_shift;
        outline_alpha = clamp(outline_alpha * outline_boost, 0.0, 1.0);
    }

    vec4 outline_layer = vec4(outline_color.rgb, outline_alpha * outline_color.a);
    vec4 color_with_outline = blend(outline_layer, original_color);

    // ─── Glitch RGB split ───────────────────────────────────────────────
    vec4 final_color = color_with_outline;

    if (enable_shift > 0.5) {
        vec2 uv_r = base_uv + vec2( shake_color_rate * 1.5,  0.002);
        vec2 uv_g = base_uv + vec2(-shake_color_rate * 0.8, -shake_color_rate * 0.5);
        vec2 uv_b = base_uv + vec2( shake_color_rate * 0.4,  shake_color_rate * 0.8);

        float r = texture(TEXTURE, uv_r).r;
        float g = texture(TEXTURE, uv_g).g;
        float b = texture(TEXTURE, uv_b).b;

        // Alpha plus conservateur pour ne pas trop affaiblir les bords
        float a_sampled  = 0.45 * texture(TEXTURE, uv_r).a
                         + 0.35 * texture(TEXTURE, uv_g).a
                         + 0.20 * texture(TEXTURE, uv_b).a;

        float glitch_a = mix(color_with_outline.a, a_sampled, 0.45);  // ← mix doux

        final_color = vec4(r, g, b, glitch_a);
    }

    if (final_color.a < 0.01) discard;
    COLOR = final_color;
}
shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;


uniform float same_width_lines_count : hint_range(1.0, 50.0) = 1.01;
uniform float glitch_change_per_sec : hint_range(0.01, 60.0) = 5.0;
uniform float threshold : hint_range(0.0, 1.0, 0.01) = 0.34;
uniform float strength : hint_range(0.0, 10.0, 0.001) = 0.041;


float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float trunc2(float v, float num) {
    return floor(v * num) / num;
}

// ──────────────────────────────────────
void fragment() {
    vec2 uv = SCREEN_UV;

    // --- Calcul du décalage horizontal par ligne (identique à l'original) ---
    float step_time = floor(TIME * glitch_change_per_sec);

    float n = 0.0;
    n += 0.25 * hash12(vec2(trunc2(uv.y + step_time, same_width_lines_count * 1.5)));
    n += 0.25 * hash12(vec2(trunc2(uv.y + step_time, 6.0)));
    n += 0.25 * hash12(vec2(trunc2(uv.y + step_time, 11.0)));
    n += 0.25 * hash12(vec2(trunc2(uv.y + step_time, 1.5)));

    n = n * 2.0 - 1.0;                                    // -1 … 1
    n = sign(n) * clamp(abs(n) - threshold, 0.0, 1.0);   // seuillage
    n *= strength;                                        // intensité finale

    // --- Échantillonnage normal + version glitchée (même offset pour tous les canaux) ---
    vec4 original = texture(screen_texture, uv);
    vec4 glitched = texture(screen_texture, uv + vec2(n, 0.0)); // même décalage partout

    // Mix entre image propre et image glitchée
    COLOR = mix(original, glitched, 1.0);
}
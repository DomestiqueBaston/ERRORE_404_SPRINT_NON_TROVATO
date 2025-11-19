shader_type canvas_item;
render_mode blend_mix, unshaded; // Obligatoire pour post-process

// VHS Glitch Horizontal – version post-process Godot 4.5.1
// https://www.shadertoy.com/user/ayy730

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

// ──────────────────────────────────────
// Paramètres du glitch VHS horizontal
// ──────────────────────────────────────
uniform float same_width_lines_count : hint_range(1.0, 50.0) = 17.237;
uniform float same_width_change_per_sec : hint_range(0.1, 20.0) = 7.665;
uniform float glitch_change_per_sec : hint_range(1.0, 60.0) = 2.0;
uniform float threshold : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float strength : hint_range(0.0, 0.3, 0.001) = 0.079;
uniform float glitch_blend : hint_range(0.0, 1.0, 0.01) = 0.85;

// ──────────────────────────────────────
// Bruit
// ──────────────────────────────────────
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    return fract(p * p);
}
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
    vec2 uv = SCREEN_UV; // ← Écran entier

    float line = floor(uv.y * same_width_lines_count);
    float seed = line + hash11(floor(TIME * same_width_change_per_sec));
    float rate = hash11(seed);
    float step_time = floor(TIME * glitch_change_per_sec * rate);

    float n = 0.0;
    n += 0.25 * hash12(vec2(trunc2(uv.y + step_time, same_width_lines_count * 1.5)));
    n += 0.25 * hash12(vec2(trunc2(uv.y + step_time, 6.0)));
    n += 0.25 * hash12(vec2(trunc2(uv.y + step_time, 11.0)));
    n += 0.25 * hash12(vec2(trunc2(uv.y + step_time, 1.5)));

    n = n * 2.0 - 1.0;
    n = sign(n) * clamp(abs(n) - threshold, 0.0, 1.0) * strength;

    vec4 col = texture(screen_texture, uv);
    float r = texture(screen_texture, uv + vec2(n, 0.0)).r;
    float g = texture(screen_texture, uv - vec2(n * 0.8, 0.0)).g;
    float b = texture(screen_texture, uv).b;

    vec4 glitch = vec4(r, g, b, 1.0);
    COLOR = mix(col, glitch, glitch_blend);
}
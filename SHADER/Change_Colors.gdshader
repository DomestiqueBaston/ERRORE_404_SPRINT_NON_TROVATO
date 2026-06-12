// Luan Ha Trong 2025 //

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// 🎛️ Réglages généraux
uniform float saturation : hint_range(0.0, 10.0) = 5.0;
uniform float value : hint_range(0.0, 2.0) = 1.0;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

// ⏱️ Timing
uniform float interval : hint_range(0.1, 30.0) = 0.25;   // X
uniform float duration : hint_range(0.0, 30.0) = 0.75;   // Y

// 🎨 Hue shift aléatoire
uniform float min_hue_shift_deg : hint_range(0.0, 180.0) = 60.0;
uniform float max_hue_shift_deg : hint_range(0.0, 360.0) = 180.0;

// 👁️ Dédoublement horizontal (en pixels écran)
uniform float min_double_offset_px : hint_range(0.0, 20.0) = 1.5;
uniform float max_double_offset_px : hint_range(0.0, 50.0) = 3.5;
uniform float double_strength : hint_range(0.0, 1.0) = 0.4;

// --------------------
// Utils HSV
// --------------------
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(
        abs(q.z + (q.w - q.y) / (6.0 * d + e)),
        d / (q.x + e),
        q.x
    );
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(
        abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0,
        0.0,
        1.0
    );
    return c.z * mix(vec3(1.0), rgb, c.y);
}

// Hash pseudo-aléatoire stable
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// --------------------
// Fragment
// --------------------
void fragment() {
    // ⏲️ Cycle temporel
    float cycle = floor(TIME / interval);
    float t = mod(TIME, interval);
    float active = step(t, duration);

    // 🎲 Random stable par cycle
    float rnd = hash(cycle);
    float sign = step(0.5, hash(cycle + 19.3)) * 2.0 - 1.0;

    // --- DÉDOUBLEMENT HORIZONTAL ---
    float offset_px = mix(min_double_offset_px, max_double_offset_px, rnd) * sign;
    vec2 offset_uv = vec2(offset_px, 0.0) * SCREEN_PIXEL_SIZE * active;

    vec4 base_col = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 double_col = texture(SCREEN_TEXTURE, SCREEN_UV + offset_uv);

    vec4 col = mix(base_col, double_col, double_strength * active);

    // --- HUE SHIFT ---
    vec3 hsv = rgb2hsv(col.rgb);

    float hue_deg = mix(min_hue_shift_deg, max_hue_shift_deg, rnd);
    float hue_shift = (hue_deg * sign / 360.0) * active;

    hsv.x = mod(hsv.x + hue_shift, 1.0);
    hsv.y *= saturation;
    hsv.z *= value;

    col.rgb = hsv2rgb(hsv);
    col.a *= alpha;

    COLOR = col;
}

shader_type canvas_item;
render_mode blend_mix, unshaded;

// RGB Shift Glitch – Eethe (Shadertoy) – VERSION FIDÈLE
// Original: https://www.shadertoy.com/view/4t23Rc
// Bruit procédural ajouté pour matcher iChannel1

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;

uniform float speed : hint_range(0.1, 50.0) = 10.0;

uniform float amplitude : hint_range(0.0, 0.5) = 0.2;

uniform float power : hint_range(1.0, 15.0) = 8.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    float a = hash(i + vec2(0.0, 0.0));
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec4 rgb_shift(vec2 p, vec4 shift) {
    shift *= 2.0 * shift.w - 1.0;
    vec2 rs = vec2(shift.x, -shift.y);
    vec2 gs = vec2(shift.y, -shift.z);
    vec2 bs = vec2(shift.z, -shift.x);

    float r = texture(screen_tex, p + rs).r;
    float g = texture(screen_tex, p + gs).g;
    float b = texture(screen_tex, p + bs).b;

    return vec4(r, g, b, 1.0);
}

vec4 pow4(vec4 v, float p) {
    return vec4(pow(v.x, p), pow(v.y, p), pow(v.z, p), v.w);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    vec2 noise_coords = vec2(speed * TIME, 2.0 * speed * TIME / 25.0);

    vec4 noise_val = vec4(noise(noise_coords * 0.02), noise(noise_coords * 0.023 + 0.5), noise(noise_coords * 0.025 + 1.0), 1.0);

    vec4 shift = pow4(noise_val, power) * vec4(amplitude, amplitude, amplitude, 1.0);

    COLOR = rgb_shift(uv, shift);
}
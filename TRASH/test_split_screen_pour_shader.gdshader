shader_type canvas_item;
render_mode blend_mix, unshaded; // Post-process obligatoire

// RGB Shift Glitch – Eethe (Shadertoy) – VERSION FIDÈLE
// Original: https://www.shadertoy.com/view/4t23Rc
// Bruit procédural ajouté pour matcher iChannel1

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
// Texture de l'écran (remplace iChannel0)

uniform float speed : hint_range(0.1, 30.0) = 10.0;
// Vitesse d'animation du bruit (comme l'original)

uniform float amplitude : hint_range(0.0, 0.5) = 0.2;
// Intensité des shifts RGB (0.2 = original)

uniform float power : hint_range(1.0, 15.0) = 8.0;
// Exposant pour booster les pics du bruit (8.0 = original)

// Fonction de bruit procédural (remplace iChannel1 de l'original)
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f); // smoothstep

    float a = hash(i + vec2(0.0, 0.0));
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fonction RGB shift (copiée-collée de l'original, avec tweaks mineurs)
vec4 rgb_shift(vec2 p, vec4 shift) {
    shift *= 2.0 * shift.w - 1.0; // Remap [0,1] → [-1,1]
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

    // Génération du bruit animé (comme vec2(speed*iTime, 2*speed*iTime/25) dans l'original)
    vec2 noise_coords = vec2(speed * TIME, 2.0 * speed * TIME / 25.0);

    // Échantillonnage du bruit (échelle ajustée pour matcher l'original ~0.01-0.05)
    vec4 noise_val = vec4(noise(noise_coords * 0.02), noise(noise_coords * 0.023 + 0.5), noise(noise_coords * 0.025 + 1.0), 1.0);

    // Boost et amplitude (exactement comme l'original)
    vec4 shift = pow4(noise_val, power) * vec4(amplitude, amplitude, amplitude, 1.0);

    // Application du shift
    COLOR = rgb_shift(uv, shift);
}
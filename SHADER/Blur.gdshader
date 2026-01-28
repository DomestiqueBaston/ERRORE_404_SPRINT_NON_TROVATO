shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Timing
uniform float change_interval : hint_range(0.1, 30.0) = 0.75; // X

// Blur range
uniform int blur_min : hint_range(0, 8) = 2;
uniform int blur_max : hint_range(0, 16) = 10;

// Blur intensity
uniform float blur_strength : hint_range(0.0, 1.0) = 1.0;

// --- Hash utils ---
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Random 0..1
float rand(float seed) {
    return hash(seed);
}

vec4 blur(vec2 uv, int radius) {
    vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 pixel_size = 1.0 / screen_size;

    vec4 sum = vec4(0.0);
    float count = 0.0;

    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            vec2 off = vec2(float(x), float(y)) * pixel_size;
            sum += texture(SCREEN_TEXTURE, uv + off);
            count += 1.0;
        }
    }

    return sum / count;
}

void fragment() {
    // On calcule l'index du cycle actuel
    float cycle_index = floor(TIME / change_interval);

    // Valeur aléatoire du blur pour ce cycle
    int radius = int(floor(mix(float(blur_min), float(blur_max), rand(cycle_index)) + 0.5));

    vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 blur_col = blur(SCREEN_UV, radius);

    COLOR = mix(screen_col, blur_col, blur_strength);
}

shader_type canvas_item;

// --- Paramètres (inchangés) ---
uniform float density : hint_range(0.1, 1.0) = 1.0;
uniform float min_size  : hint_range(0.01, 0.05) = 0.01;
uniform float max_size  : hint_range(0.1, 2.0) = 0.5;
uniform float min_life  : hint_range(0.1, 4.0) = 1.0;
uniform float max_life  : hint_range(0.5, 10.0) = 3.0;
uniform float rectangle_count : hint_range(1.0, 50.0) = 5.0;

// --- Seed par instance via la couleur du ColorRect ---
varying vec4 INSTANCE_SEED;

void vertex() {
    INSTANCE_SEED = COLOR;  // r,g,b,a du ColorRect
}

// --- Hash très sensible au seed ---
uniform float instance_id;
float hash(vec2 p) {
    p = fract(p * vec2(0.3183099, 0.3678794));
    p *= 17.0 + INSTANCE_SEED.xy * 100.0 + INSTANCE_SEED.zw * 50.0 + instance_id;
    return fract(p.x * p.y * (p.x + p.y));
}

float luminance(vec3 c) {
    return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
}

void fragment() {
    vec2 uv = UV;
    float t = TIME + instance_id * 1000.0; // Décale le temps par instance
    vec3 final_col = vec3(0.0);
    float final_a = 0.0;

    for (float i = 0.0; i < rectangle_count; i++) {
        vec2 id = vec2(i * 1.618, i * 3.14159);  // juste pour varier un peu plus l'id

        // Position très sensible au seed
        vec2 pos = vec2(
            hash(id + vec2(17.0,  43.0)),
            hash(id + vec2(29.0, 101.0))
        ) * 0.8 + 0.1;  // pour rester dans l'écran

        float size = mix(min_size, max_size, hash(id + vec2(53.0, 137.0)));

        // Rectangle simple
        float rect = step(pos.x, uv.x) * step(uv.x, pos.x + size)
                   * step(pos.y, uv.y) * step(uv.y, pos.y + size);

        // Timing différent par instance
        float start = hash(id + vec2(71.0, 173.0)) * 80.0;
        float duration = mix(min_life, max_life, hash(id + vec2(89.0, 211.0)));
        float age = t - start;
        float visible = step(0.0, age) * step(age, duration);

        // Overlay (inchangé)
        vec3 bg = texture(TEXTURE, uv).rgb;
        vec3 overlay = vec3(1.0);
        vec3 blend;
        float lum = luminance(bg);
        if (lum < 0.5) {
            blend = 2.0 * overlay * bg;
        } else {
            blend = 1.0 - 2.0 * (1.0 - bg) * (1.0 - overlay);
        }

        float a = rect * visible;
        final_col += blend * a;
        final_a += a;
    }

    final_a = min(final_a, 1.0);
    COLOR.rgb = final_col;
    COLOR.a = final_a * density;
}
shader_type canvas_item;
render_mode blend_mix, unshaded;

// Binary Glitch – post-process version (Godot 4.5.1 compatible)
// Original Shadertoy : https://www.shadertoy.com/view/ls3GDS (by D34N 4L3X)

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform float strength : hint_range(0.0, 2.0, 0.01) = 0.75;


void fragment() {
    vec2 uv = SCREEN_UV;

    float glitch = strength;

    // 1. Grille grossière
    float psize = 0.04 * glitch;
    vec2 p = floor(uv / psize + 0.5) * psize;
    vec4 snap = texture(screen_texture, p);

    // 2. Luminance inversée (zones sombres bougent plus)
    float lum = pow(1.0 - dot(snap.rgb, vec3(0.333333)), glitch);

    // 3. Deuxième grille + déplacement
    float qsize = max(psize * lum, 0.0001);
    vec2 q = floor(uv / qsize + 0.5) * qsize;
    vec2 final_uv = uv + (p - q) * lum;

    // 4. On échantillonne l'écran aux nouvelles coordonnées
    COLOR = texture(screen_texture, final_uv);
}
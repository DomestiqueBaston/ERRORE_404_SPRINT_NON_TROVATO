shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.0; // 0.25 pour une ombre "pleine"

void fragment() {
    vec4 src = texture(TEXTURE, UV) * COLOR;
    vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);
// Luminance du fond
    float lum = dot(bg.rgb, vec3(0.299, 0.587, 0.114));
    float mask = lum * intensity;
    src.a *= mask;
    COLOR = src;
}
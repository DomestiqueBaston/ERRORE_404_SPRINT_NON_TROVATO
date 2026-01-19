shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float scale_y;
uniform float y_zoom;
// Ajoute un paramètre pour contrôler l'opacité (0.0 = transparent, 1.0 = opaque)
uniform float opacity : hint_range(0.0, 1.0) = 0.7;

void fragment() {
    float uv_height = (SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y);
    vec2 reflected_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - (uv_height * UV.y * scale_y * y_zoom));
    vec4 reflection = texture(SCREEN_TEXTURE, reflected_uv);
    // Applique l'opacité
    COLOR = reflection;
    COLOR.a *= opacity;
}
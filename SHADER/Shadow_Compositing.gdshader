shader_type canvas_item;

void fragment() {
    vec4 blend = texture(TEXTURE, UV);
    vec4 base = COLOR;
    COLOR = blend * base;
}
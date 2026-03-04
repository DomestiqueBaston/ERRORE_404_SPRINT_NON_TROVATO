shader_type canvas_item;

uniform int pixel_factor : hint_range(1, 10) = 5;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	
	vec2 block_size = float(pixel_factor) / screen_size;
	
	vec2 uv = SCREEN_UV;
	uv = floor(uv / block_size) * block_size;
	
	vec4 color = textureLod(SCREEN_TEXTURE, uv, 0.0);
	
	COLOR = color;
}
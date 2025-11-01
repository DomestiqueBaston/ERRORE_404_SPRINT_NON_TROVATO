shader_type canvas_item;

uniform float pixelation : hint_range(0.001, 0.1) = 0.01;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Calculate pixel dimensions with screen aspect correction
    vec2 viewport_size = vec2(1.0 / SCREEN_PIXEL_SIZE.x, 1.0 / SCREEN_PIXEL_SIZE.y);
    float aspect = float(viewport_size.x) / float(viewport_size.y);
    vec2 pixel_size = vec2(pixelation / aspect, pixelation);

    // Calculate grid aligned UV coordinates
    vec2 coord = SCREEN_UV;

    // Round to nearest pixel boundary to prevent edge shimmer
    coord = floor(coord / pixel_size) * pixel_size;

    // Explicitly allow the first row and column by ensuring that the coordinates are within bounds
    if (coord.x < 0.0) coord.x = 0.0;
    if (coord.y < 0.0) coord.y = 0.0;

    // Sample with explicit LOD to prevent mipmap shimmer
    vec4 color = textureLod(SCREEN_TEXTURE, coord, 0.0);

    // Output color with opacity set to 1.0 by default
    COLOR = color;
}

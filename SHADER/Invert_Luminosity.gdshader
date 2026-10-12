shader_type canvas_item;

uniform sampler2D existing_screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float speed = 2.0;

float rand(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}

void fragment() {
    vec3 color = texture(existing_screen_texture, SCREEN_UV).rgb;

    float t = floor(TIME * speed);
    float enabled = step(0.5, rand(t));

    if (enabled > 0.5) {
        // luminosity eval
        float luminance = dot(color, vec3(0.5, 0.5, 0.0));

        // Invert luminosity
        float inverted_luminance = 1.0 - luminance;

        // apply correction
        color += vec3(inverted_luminance - luminance);

        // Keep rgb values
        color = clamp(color, 0.0, 1.0);
    }

    COLOR.rgb = color;
}
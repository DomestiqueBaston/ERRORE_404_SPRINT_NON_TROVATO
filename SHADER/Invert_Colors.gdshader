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
        color = vec3(1.0) - color;
    }

    COLOR.rgb = color;
}
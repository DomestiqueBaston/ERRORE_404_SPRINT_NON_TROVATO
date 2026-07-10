shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// 震动参数 (Shake parameters)
uniform float hit_effect : hint_range(0, 1) = 1.0;
uniform float shake_intensity = 4.5;
uniform float time_offset = 0.0;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // 计算屏幕震动偏移 (Calculate the screen shake offset)
    vec2 uv_offset = vec2(0.0);
    if (hit_effect > 0.0) {
        float time = (TIME + time_offset) * 30.0;
        vec2 random_offset = vec2(
            rand(vec2(time, 0.0)) * 2.0 - 1.0,
            rand(vec2(time, 10.0)) * 2.0 - 1.0
        );
        // Convert the pixel offset to UV space
        vec2 tex_size = vec2(textureSize(screen_texture, 0));
        uv_offset = (random_offset * shake_intensity * hit_effect) / tex_size;
    }

    // 应用偏移后的UV采样 (Apply the offset UV sampling)
    vec4 c = textureLod(screen_texture, SCREEN_UV + uv_offset, 0.0);

    // 预乘Alpha处理 (Premultiply alpha)
    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }

    COLOR = c;
}

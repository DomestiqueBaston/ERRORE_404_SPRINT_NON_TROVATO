shader_type canvas_item;
uniform float strength : hint_range(0.0, 0.03) = 0.015;
uniform vec2 direction = vec2(-200.0, -333.0);
uniform int samples : hint_range(1, 8) = 4;
uniform float trail_opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 trails = vec4(0.0);
    vec2 dir = normalize(direction);
    float weight_sum = 0.0;

    for (int i = 1; i <= samples; i++) {
        float t = float(i) / float(samples);
        float weight = 1.0 - t;
        vec4 trail = texture(TEXTURE, UV - dir * strength * t);
        trails.rgb += trail.rgb * weight * trail_opacity;
        trails.a = max(trails.a, trail.a * weight * trail_opacity);
        weight_sum += weight;
    }

    if (weight_sum > 0.0) {
        trails.rgb /= weight_sum;
    }

    vec4 sprite = texture(TEXTURE, UV);

    COLOR = mix(trails, sprite, sprite.a);
}
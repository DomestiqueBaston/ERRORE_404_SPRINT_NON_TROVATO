shader_type canvas_item;
render_mode blend_mul;

// Pour faire juste un Mult, on se fout de la suite !

uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform vec4 tint_color : source_color = vec4(1.0, 0.4, 0.4, 1.0);

void fragment() {
    vec4 effective_color = mix(vec4(1.0), tint_color, intensity);
    COLOR = effective_color;
}
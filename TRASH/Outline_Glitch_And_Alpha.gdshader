shader_type canvas_item;

// Uniforms du tremblement
uniform bool shake_enabled = false;
uniform float shake_power : hint_range(0.0, 0.01, 0.0001) = 0.002;
//uniform float shake_speed = 5.7;
uniform float shake_speed : hint_range(0.0, 100.0, 0.1) = 100.0;
uniform float shake_block_size = 75.0;
uniform float shake_color_rate : hint_range(0.0, 0.01, 0.0001) = 0.002;

// Uniforms de l'outline
uniform float outline_thickness : hint_range(0.0, 3.0, 1.0) = 2.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

bool is_inside_usquare(vec2 x) {
	return x == clamp(x, vec2(0.0), vec2(1.0));
}

vec4 blend(vec4 bottom, vec4 top) {
	float alpha = top.a + bottom.a * (1.0 - top.a);
	if (alpha < 0.0001) return vec4(0.0);
	vec3 color = mix(bottom.rgb * bottom.a, top.rgb, top.a) / alpha;
	return vec4(color, alpha);
}

void fragment() {
	// Activation du tremblement selon une fréquence basée sur le temps
	bool is_shake_active = shake_enabled;

	// Calcul du tremblement
	float enable_shift = float(is_shake_active);

	vec2 fixed_uv = UV;
	fixed_uv.x += enable_shift * shake_power * sign(sin(trunc(UV.y * shake_block_size) * 5.0 + TIME * shake_speed));
	fixed_uv.y += enable_shift * shake_power * sign(cos(trunc(UV.x * shake_block_size) * 2.0 + TIME * shake_speed));


	vec4 texture_color = texture(TEXTURE, fixed_uv);
	vec4 shaken_color = texture_color;

	// Séparation des couleurs (shake sur les canaux)
	if (enable_shift > 0.5) {
		vec4 r_tex = texture(TEXTURE, fixed_uv + vec2(shake_color_rate, 0.0));
		shaken_color.r = mix(shaken_color.r, r_tex.r, enable_shift);
		vec4 g_tex = texture(TEXTURE, fixed_uv + vec2(shake_color_rate, 0.006));
		shaken_color.g = mix(shaken_color.g, g_tex.g, enable_shift);
		vec4 b_tex = texture(TEXTURE, fixed_uv + vec2(-shake_color_rate, 0.0));
		shaken_color.b = mix(shaken_color.b, b_tex.b, enable_shift);
		vec4 a_tex = texture(TEXTURE, fixed_uv + vec2(shake_color_rate * 0.1, 0.001));
		shaken_color.a = mix(shaken_color.a, a_tex.a, enable_shift);
	}

	// Applique l'outline
	vec4 final_color = shaken_color;
	if (outline_thickness > 0.0 && outline_color.a > 0.0) {
		float alpha = 0.0;
		vec2 pos = fixed_uv;
		for (float y = 1.0; y <= outline_thickness; y += 1.0) {
			for (float x = 0.0; x <= y; x += 1.0) {
				if (length(vec2(x, y - 0.5)) > outline_thickness) break;
				vec2 look_at_uv[8];
				look_at_uv[0] = pos + vec2(x, y) * TEXTURE_PIXEL_SIZE;
				look_at_uv[1] = pos + vec2(-x, y) * TEXTURE_PIXEL_SIZE;
				look_at_uv[2] = pos + vec2(x, -y) * TEXTURE_PIXEL_SIZE;
				look_at_uv[3] = pos + vec2(-x, -y) * TEXTURE_PIXEL_SIZE;
				look_at_uv[4] = pos + vec2(y, x) * TEXTURE_PIXEL_SIZE;
				look_at_uv[5] = pos + vec2(-y, x) * TEXTURE_PIXEL_SIZE;
				look_at_uv[6] = pos + vec2(y, -x) * TEXTURE_PIXEL_SIZE;
				look_at_uv[7] = pos + vec2(-y, -x) * TEXTURE_PIXEL_SIZE;
				for (int i = 0; i < 8; i++) {
					if (is_inside_usquare(look_at_uv[i])) {
						float look_at_alpha = texture(TEXTURE, look_at_uv[i]).a;
						alpha = max(alpha, look_at_alpha);
						if (alpha >= 0.9999) break;
					}
				}
				if (alpha >= 0.9999) break;
			}
			if (alpha >= 0.9999) break;
		}
		vec4 outline_layer = vec4(outline_color.rgb, alpha * outline_color.a);
		final_color = blend(outline_layer, shaken_color);
	}

	if (final_color.a < 0.01) discard;
	COLOR = final_color;
}

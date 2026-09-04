shader_type canvas_item;

/* ================= SETTINGS ================= */

uniform float glitch_speed = 7.0;

uniform float slice_density = 50.0;
uniform float slice_strength = 0.38;

uniform float shake_strength = 0.00;

uniform float scanline_strength : hint_range(0.0, 1.0) = 1.0;

uniform float local_warp_strength = 0.666;


/* ================= BLOCK GLITCH ================= */

// Intensité du déplacement en blocs
uniform float block_glitch_power : hint_range(0.0, 0.01, 0.0001) = 0.001;

// Vitesse du déplacement des blocs
uniform float block_glitch_speed : hint_range(0.0, 100.0, 0.1) = 10.0;

// Taille des blocs
uniform float block_size = 150.0;

// Intensité du RGB split
uniform float block_chroma : hint_range(0.0, 0.02, 0.0001) = 0.0007;


/* ================= RANDOM ================= */

float rand(float x)
{
	return fract(sin(x * 143758.5453) * 43758.5453);
}

float rand2(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


/* ================= FRAGMENT ================= */

void fragment()
{
	vec2 uv = UV;

	float frame = floor(TIME * glitch_speed);


	/* ================= SLICES ================= */

	float slice_id = floor(
		uv.y * slice_density
	);

	float slice_random = rand(
		slice_id + frame * 13.37
	);

	float slice_active = step(
		0.5,
		slice_random
	);

	float displacement =
		(slice_random - 0.5)
		* slice_strength;

	uv.x += displacement * slice_active;


	/* ================= MICRO JITTER ================= */

	float jitter = step(
		0.8,
		rand(frame * 3.17)
	);

	uv.x += (
		rand(frame * 5.73) - 0.5
	) * 0.04
	* jitter;


	/* ================= LOCAL WARP ================= */

	float warp_random = rand2(
		vec2(slice_id, frame)
	);

	float warp_active = step(
		0.7,
		warp_random
	);

	vec2 warp = vec2(
		rand2(vec2(slice_id, frame + 1.0)),
		rand2(vec2(slice_id, frame + 2.0))
	) - 0.5;

	uv += warp
		* local_warp_strength
		* warp_active;


	/* ================= GLOBAL SHAKE ================= */

	uv += vec2(
		rand(frame * 1.37) - 0.5,
		rand(frame * 1.91) - 0.5
	) * shake_strength;


	/* ================= BLOCK GLITCH ================= */

	// Même principe que ton deuxième shader :
	// les coordonnées sont décalées suivant des blocs.

	float block_x = trunc(
		UV.y * block_size
	);

	float block_y = trunc(
		UV.x * block_size
	);

	uv.x += block_glitch_power
		* sign(
			sin(
				block_x * 5.0
				+ TIME * block_glitch_speed
			)
		);

	uv.y += block_glitch_power
		* sign(
			cos(
				block_y * 2.0
				+ TIME * block_glitch_speed
			)
		);


	/* ================= TEXTURE ================= */

	vec4 base = texture(
		TEXTURE,
		uv
	);


	/* ================= RGB GLITCH ================= */

	vec2 uv_r = uv + vec2(
		block_chroma * 1.5,
		0.002
	);

	vec2 uv_g = uv + vec2(
		-block_chroma * 0.8,
		-block_chroma * 0.5
	);

	vec2 uv_b = uv + vec2(
		block_chroma * 0.4,
		block_chroma * 0.8
	);

	float r = texture(
		TEXTURE,
		uv_r
	).r;

	float g = texture(
		TEXTURE,
		uv_g
	).g;

	float b = texture(
		TEXTURE,
		uv_b
	).b;

	vec3 color = vec3(
		r,
		g,
		b
	);


	/* ================= ALPHA ================= */

	float alpha = base.a;


	/* ================= SCANLINES ================= */

	float scan = sin(
		uv.y * 800.0
	) * 0.5 + 0.5;

	float scan_mask = smoothstep(
		0.92,
		1.0,
		scan
	);

	color *= 1.0
		- scan_mask
		* scanline_strength;


	/* ================= OUTPUT ================= */

	COLOR = vec4(
		color,
		alpha
	);
}

shader_type canvas_item;

/* ================= SETTINGS ================= */
uniform float glitch_speed = 10.0;
uniform float slice_density = 50.0;
uniform float local_warp_strength = 0.666;

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
	float slice_id = floor(uv.y * slice_density);

	/* ================= MICRO JITTER ================= */
	float jitter = step(0.8, rand(frame * 3.17));
	uv.x += (rand(frame * 5.73) - 0.5) * 0.04 * jitter;

	/* ================= LOCAL WARP ================= */
	float warp_random = rand2(vec2(slice_id, frame));
	float warp_active = step(0.7, warp_random);
	vec2 warp = vec2(
		rand2(vec2(slice_id, frame + 1.0)),
		rand2(vec2(slice_id, frame + 2.0))
	) - 0.5;
	uv += warp * local_warp_strength * warp_active;

	/* ================= TEXTURE ================= */
	COLOR = texture(TEXTURE, uv);
}
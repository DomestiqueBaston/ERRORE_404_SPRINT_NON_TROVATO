shader_type canvas_item;

/* ================= SETTINGS ================= */
uniform float glitch_speed = 7.0;
uniform float slice_density = 50.0;
uniform float slice_strength = 0.38;
uniform float shake_strength = 0.00;
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
	float slice_random = rand(slice_id + frame * 13.37);
	float slice_active = step(0.5, slice_random);
	float displacement = (slice_random - 0.5) * slice_strength;
	uv.x += displacement * slice_active;

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

	/* ================= SHAKE ================= */
	uv += vec2(
		rand(frame * 1.37) - 0.5,
		rand(frame * 1.91) - 0.5
	) * shake_strength;

	/* ================= TEXTURE ================= */
	COLOR = texture(TEXTURE, uv);
}
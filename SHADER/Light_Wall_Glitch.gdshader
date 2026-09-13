shader_type canvas_item;

uniform float glitch_speed = 10.0;
uniform float slice_density = 50.0;
uniform float local_warp_strength = 0.75;
uniform float noise_intensity = 0.3;
uniform float random_frame_period = 100.0;

float rand(float x)
{
	return fract(sin(x * 143758.5453) * 43758.5453);
}

float rand2(vec2 p)
{
	return fract(sin(dot(p, vec2(127.1, 311.7)))* 43758.5453);
}

void fragment()
{
	vec2 uv = UV;
	float frame = mod(floor(TIME * glitch_speed), random_frame_period);
	/* ================= SLICES ================= */
	float slice_id = floor(uv.y * slice_density);

	/* ================= MICRO JITTER ================= */
	float jitter = step(0.8, rand(frame * 3.17));
	uv.x += (rand(frame * 5.73) - 0.5) * 0.04 * jitter;

	/* ================= LOCAL WARP ================= */
	float warp_random = rand2(vec2(slice_id, frame));
	float warp_active = step(0.7, warp_random);
	vec2 warp = vec2(rand2(vec2(slice_id, frame + 1.0)), rand2(vec2(slice_id, frame + 2.0))) - 0.5;
	uv += warp * local_warp_strength * warp_active;

	/* ================= TEXTURE ================= */
	COLOR = texture(TEXTURE, uv);

	/* ================= COLOR NOISE ================= */
	vec3 noise = vec3(rand2(uv + vec2(frame, 0.0)), rand2(uv + vec2(frame, 17.0)), rand2(uv + vec2(frame, 31.0)));
	noise = noise * 2.0 - 1.0;
	COLOR.rgb += noise * noise_intensity;
}
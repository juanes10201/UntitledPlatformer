shader_type canvas_item;

uniform float blur_size : hint_range(0.0, 8.0) = 4.0;
uniform float max_alpha : hint_range(0.0, 1.0) = 0.6;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1);

uniform float extend_px = 0.0;

void vertex() {
	vec2 dir = sign(UV - 0.5);
	VERTEX += dir * extend_px;
	UV += dir * extend_px * TEXTURE_PIXEL_SIZE;
}

void fragment() {
	vec2 pixel = TEXTURE_PIXEL_SIZE * blur_size;
	float alpha = 0.0;

	const int SAMPLES = 8;
	for (int i = 0; i < SAMPLES; i++) {
		float angle = float(i) * (6.2831853 / float(SAMPLES));
		vec2 offset = vec2(cos(angle), sin(angle)) * pixel;
		alpha += texture(TEXTURE, UV + offset).a;
	}

	alpha += texture(TEXTURE, UV).a * 2.0;
	alpha /= float(SAMPLES) + 2.0;

	alpha = clamp(alpha, 0.0, max_alpha);
	COLOR = vec4(shadow_color.rgb, alpha);
}
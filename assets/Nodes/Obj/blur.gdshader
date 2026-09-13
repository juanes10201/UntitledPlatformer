shader_type canvas_item;

uniform float blur_size : hint_range(0.0, 8.0) = 4.0;
uniform float max_alpha : hint_range(0.0, 1.0) = 0.6;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 1);

void fragment() {
	vec2 t = TEXTURE_PIXEL_SIZE * blur_size;
	float alpha = 0.0;

	alpha += texture(TEXTURE, UV + vec2( t.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(-t.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0,  t.y)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, -t.y)).a;

	alpha += texture(TEXTURE, UV + t).a;
	alpha += texture(TEXTURE, UV - t).a;
	alpha += texture(TEXTURE, UV + vec2( t.x, -t.y)).a;
	alpha += texture(TEXTURE, UV + vec2(-t.x,  t.y)).a;

	alpha /= 8.0;
	alpha = clamp(alpha, 0.0, max_alpha);

	COLOR = vec4(shadow_color.x, shadow_color.y, shadow_color.z, alpha);
}
shader_type canvas_item;

uniform int blend_mode : hint_enum("Normal", "Darken", "Multiply", "Color Burn", "Linear Burn", "Darker Color", "Lighten", "Screen", "Color Dodge", "Linear Dodge (Add)", "Lighter Color", "Overlay", "Soft Light", "Hard Light", "Vivid Light", "Linear Light", "Pin Light", "Hard Mix", "Difference", "Exclusion", "Subtract", "Divide", "Hue", "Saturation", "Color", "Luminosity") = 0;
uniform int base_source : hint_enum("Node Texture", "Screen", "Blend Texture", "Blend Color") = 1;
uniform int layer_source : hint_enum("Node Texture", "Screen", "Blend Texture", "Blend Color") = 0;
uniform sampler2D blend_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 blend_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 blend_uv_scale = vec2(1.0, 1.0);
uniform vec2 blend_uv_offset = vec2(0.0, 0.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

const float EPS = 0.00001;

float lum(vec3 c) {
	return dot(c, vec3(0.3, 0.59, 0.11));
}

vec3 clip_color(vec3 c) {
	float l = lum(c);
	float n = min(min(c.r, c.g), c.b);
	float x = max(max(c.r, c.g), c.b);
	if (n < 0.0) {
		c = l + (c - l) * l / max(l - n, EPS);
	}
	if (x > 1.0) {
		c = l + (c - l) * (1.0 - l) / max(x - l, EPS);
	}
	return c;
}

vec3 set_lum(vec3 c, float l) {
	return clip_color(c + (l - lum(c)));
}

float sat(vec3 c) {
	return max(max(c.r, c.g), c.b) - min(min(c.r, c.g), c.b);
}

vec3 set_sat(vec3 c, float s) {
	float mn = min(min(c.r, c.g), c.b);
	float mx = max(max(c.r, c.g), c.b);
	if (mx > mn) {
		return (c - mn) * s / (mx - mn);
	}
	return vec3(0.0);
}

vec3 color_burn(vec3 a, vec3 b) {
	return 1.0 - min((1.0 - a) / max(b, vec3(EPS)), vec3(1.0));
}

vec3 color_dodge(vec3 a, vec3 b) {
	return min(a / max(1.0 - b, vec3(EPS)), vec3(1.0));
}

vec3 overlay(vec3 a, vec3 b) {
	return mix(2.0 * a * b, 1.0 - 2.0 * (1.0 - a) * (1.0 - b), step(0.5, a));
}

vec3 hard_light(vec3 a, vec3 b) {
	return mix(2.0 * a * b, 1.0 - 2.0 * (1.0 - a) * (1.0 - b), step(0.5, b));
}

vec3 soft_light(vec3 a, vec3 b) {
	vec3 d = mix(((16.0 * a - 12.0) * a + 4.0) * a, sqrt(a), step(0.25, a));
	vec3 lo = a - (1.0 - 2.0 * b) * a * (1.0 - a);
	vec3 hi = a + (2.0 * b - 1.0) * (d - a);
	return mix(lo, hi, step(0.5, b));
}

vec3 vivid_light(vec3 a, vec3 b) {
	vec3 lo = color_burn(a, 2.0 * b);
	vec3 hi = color_dodge(a, 2.0 * (b - 0.5));
	return mix(lo, hi, step(0.5, b));
}

vec3 pin_light(vec3 a, vec3 b) {
	vec3 lo = min(a, 2.0 * b);
	vec3 hi = max(a, 2.0 * (b - 0.5));
	return mix(lo, hi, step(0.5, b));
}

vec3 apply_blend(vec3 a, vec3 b, int mode) {
	switch (mode) {
		case 0:
			return b;
		case 1:
			return min(a, b);
		case 2:
			return a * b;
		case 3:
			return color_burn(a, b);
		case 4:
			return max(a + b - 1.0, vec3(0.0));
		case 5:
			return lum(a) < lum(b) ? a : b;
		case 6:
			return max(a, b);
		case 7:
			return 1.0 - (1.0 - a) * (1.0 - b);
		case 8:
			return color_dodge(a, b);
		case 9:
			return min(a + b, vec3(1.0));
		case 10:
			return lum(a) > lum(b) ? a : b;
		case 11:
			return overlay(a, b);
		case 12:
			return soft_light(a, b);
		case 13:
			return hard_light(a, b);
		case 14:
			return vivid_light(a, b);
		case 15:
			return clamp(a + 2.0 * b - 1.0, vec3(0.0), vec3(1.0));
		case 16:
			return pin_light(a, b);
		case 17:
			return step(vec3(1.0), a + b);
		case 18:
			return abs(a - b);
		case 19:
			return a + b - 2.0 * a * b;
		case 20:
			return max(a - b, vec3(0.0));
		case 21:
			return min(a / max(b, vec3(EPS)), vec3(1.0));
		case 22:
			return set_lum(set_sat(b, sat(a)), lum(a));
		case 23:
			return set_lum(set_sat(a, sat(b)), lum(a));
		case 24:
			return set_lum(b, lum(a));
		case 25:
			return set_lum(a, lum(b));
	}
	return b;
}

vec4 get_source(int source, vec4 node_tex, vec2 uv, vec2 screen_uv) {
	if (source == 0) {
		return node_tex;
	}
	if (source == 1) {
		return textureLod(screen_tex, screen_uv, 0.0);
	}
	if (source == 2) {
		return texture(blend_texture, uv * blend_uv_scale + blend_uv_offset) * blend_color;
	}
	return blend_color;
}

void fragment() {
	vec4 node_tex = texture(TEXTURE, UV) * COLOR;
	vec4 base = get_source(base_source, node_tex, UV, SCREEN_UV);
	vec4 layer = get_source(layer_source, node_tex, UV, SCREEN_UV);

	vec3 blended = apply_blend(base.rgb, layer.rgb, blend_mode);

	if (base_source == 1) {
		float mask = layer_source == 0 ? 1.0 : node_tex.a;
		COLOR = vec4(blended, layer.a * opacity * mask);
	} else {
		float mask = base_source == 0 ? 1.0 : node_tex.a;
		COLOR = vec4(mix(base.rgb, blended, layer.a * opacity), base.a * mask);
	}
}
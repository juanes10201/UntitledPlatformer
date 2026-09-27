shader_type canvas_item;

uniform sampler2D border_map;
uniform vec2 map_size;

uniform sampler2D light_color;
uniform sampler2D shadow_color;
uniform sampler2D v_light_color;
uniform sampler2D v_shadow_color;

uniform sampler2D diagonal_upper_right_color;
uniform sampler2D diagonal_upper_left_color;
uniform sampler2D diagonal_down_right_color;
uniform sampler2D diagonal_down_left_color;

uniform vec2 cell_size = vec2(16.0, 16.0);
uniform vec2 map_origin;

varying vec2 vert;
varying vec2 tile_uv;

void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	tile_uv = world_pos / cell_size;
}

void fragment() {
	vec2 in_tile_uv = fract(tile_uv);
	ivec2 tile_coord = ivec2(floor(tile_uv)) - ivec2(map_origin);
	vec4 pixel_color = texelFetch(border_map, tile_coord, 0);
	if(pixel_color.a > 0.0){
		//Horizontal lights
		if((pixel_color.x > 0.1 && pixel_color.x < 0.3) || pixel_color.x > .8) {
			vec4 shadow_color_sample = texture(light_color, in_tile_uv);
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		}
		if(pixel_color.x > 0.3 || pixel_color.x > .8) {
			vec4 shadow_color_sample = texture(shadow_color, in_tile_uv);
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		}
		//vertical lights
		if((pixel_color.y > 0.1 && pixel_color.y < 0.3) || pixel_color.y > .8) {
			vec4 shadow_color_sample = texture(v_light_color, in_tile_uv);
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		}
		if(pixel_color.y > 0.3 || pixel_color.y > .8) {
			vec4 shadow_color_sample = texture(v_shadow_color, in_tile_uv);
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		}
		if(pixel_color.z == 0.2) {
			vec4 shadow_color_sample = texture(diagonal_upper_right_color, in_tile_uv);
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		}
		else if(pixel_color.z == 0.4) {
			vec4 shadow_color_sample = texture(diagonal_upper_left_color, in_tile_uv);
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		}
		else if(pixel_color.z == 0.6) {
			vec4 shadow_color_sample = texture(diagonal_down_right_color, in_tile_uv);
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		}
		else if(pixel_color.z == 0.8) {
			vec4 shadow_color_sample = texture(diagonal_down_left_color, in_tile_uv);
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		}
	}
	//COLOR = vec4(tile_uv.x/10.0, tile_uv.y/10.0, 1.0, 1.0);
}

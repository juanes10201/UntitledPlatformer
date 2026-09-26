shader_type canvas_item;

uniform sampler2D border_map;
uniform vec2 map_size;

uniform sampler2D shadow_color;
uniform vec2 cell_size = vec2(16.0, 16.0);
uniform vec2 map_origin;

varying vec2 vert;
varying flat vec2 tile_uv;
varying vec2 in_tile_uv;

void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	tile_uv = world_pos / cell_size;
	in_tile_uv = vec2( mod(world_pos.x, cell_size.x), mod(world_pos.y, cell_size.y) ) / cell_size;;
}

void fragment() {
	ivec2 tile_coord = ivec2(floor(tile_uv)) - ivec2(map_origin);
	vec4 pixel_color = texelFetch(border_map, tile_coord, 0);
	vec4 shadow_color_sample = texture(shadow_color, in_tile_uv);
	if(pixel_color.a > 0.0){
		//if(pixel_color.x > 0.1 && pixel_color.x < 0.3){
			COLOR = mix(COLOR, vec4(shadow_color_sample.x, shadow_color_sample.y, shadow_color_sample.z, 1.0), shadow_color_sample.a);
		//}
	}
	//COLOR = vec4(tile_uv.x/10.0, tile_uv.y/10.0, 1.0, 1.0);
}
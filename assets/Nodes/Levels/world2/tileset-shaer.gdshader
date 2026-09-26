shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.45);
uniform vec2 cell_size = vec2(16.0, 16.0);
uniform vec2 map_origin;

varying vec2 vert;
varying flat vec2 tile_uv;

void vertex() {
	vert = VERTEX;
	tile_uv = vert/cell_size;
}

void fragment() {
	COLOR = mix(COLOR, vec4(shadow_color.x, shadow_color.y, shadow_color.z, 1.0), shadow_color.a);
	COLOR = vec4(tile_uv.x/10.0, tile_uv.y/10.0, 1.0, 1.0);
}
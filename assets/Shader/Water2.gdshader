//https://godotshaders.com/shader/2d-water-distortion-effect-godot-4/
shader_type canvas_item;

uniform float opacity_post_border : hint_range(0.0, 1.0) = 0.0;

uniform sampler2D refraction_map;
uniform vec2 refraction_stretch = vec2(1.0, 1.0);
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.02;
uniform sampler2D water_tint;// : source_color = vec4(0.2, 0.6, 1.0, 0.1);
uniform float water_depth_range : hint_range(1.0, 500.0) = 100.0;
uniform float speed : hint_range(0.0, 1.0) = 0.1;

// Border wave controls
uniform float border_wave_height : hint_range(0.0, 20.0) = 6.0;
uniform float border_wave_x_strength : hint_range(0.0, 20.0) = 4.0;
uniform float border_wave_frequency : hint_range(0.0, 1.0) = 0.05;
uniform float border_wave_speed : hint_range(0.0, 5.0) = 1.5;
uniform float border_thickness : hint_range(0.0, 50.0) = 10.0;
uniform sampler2D border_color;

// Set this to the world Y position of the water surface (top of the uppermost water tiles)
uniform float water_surface_y : hint_range(-2000.0, 2000.0) = 0.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
varying vec2 globalposition;

void vertex(){
	globalposition = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment()
{
	vec2 uv = globalposition / 512.0;

	// --- Refraction (existing) ---
	vec2 refraction_offset = texture(
		refraction_map,
		vec2(
			mod(uv.x * refraction_stretch.x + TIME * speed, 1.0),
			mod(uv.y * refraction_stretch.y + TIME * speed, 1.0))).xy;
	refraction_offset -= 0.5;

	vec4 refraction = texture(SCREEN_TEXTURE, SCREEN_UV - refraction_offset * refraction_strength);

	// --- Border wave using global position ---
	// Wave line is defined in world space along the water surface Y
	float wave_y = water_surface_y
				 + sin(globalposition.x * border_wave_frequency + TIME * border_wave_speed) * border_wave_height;
	float wave_x = sin(globalposition.x * border_wave_frequency * 0.7 + TIME * border_wave_speed * 1.3 + 1.5) * border_wave_x_strength;

	// How far this pixel is below the animated wave line (world space pixels)
	float dist_to_border = globalposition.y - wave_y;

	// Band just below the crest — smoothstep in world-space pixel units
	float border_mask = smoothstep(border_thickness, 0.0, dist_to_border)
					  * smoothstep(-2.0, 2.0, dist_to_border);

	// X wobble on the border band
	vec2 border_uv = SCREEN_UV + vec2(wave_x / vec2(textureSize(SCREEN_TEXTURE, 0)).x, 0.0) * border_mask;
	vec4 border_sample = texture(SCREEN_TEXTURE, border_uv - refraction_offset * refraction_strength);
	
	//if (dist_to_border < -1.0) {
    //	discard;
	//}
	
	//Ponerle una textura al water tint
	float depth_t = clamp(dist_to_border / water_depth_range, 0.0, 1.0);
	vec4 water_tint_sample = texture(water_tint, vec2(depth_t, 0.5));
	
	
	// --- Composite ---
	vec4 color = vec4(1.0);
	color.rgb = mix(refraction.rgb, water_tint_sample.rgb, water_tint_sample.a);
	//color.rgb = mix(color.rgb, border_color.rgb, border_mask * border_color.a);
	
	float border_gradient_t = clamp(dist_to_border / border_thickness, 0.0, 1.0);
	vec4 border_color_sample = texture(border_color, vec2(border_gradient_t, 0.5));
	color.rgb = mix(color.rgb, border_color_sample.rgb, border_mask*border_color_sample.a);
	
	color.a = dist_to_border < -1.0 ? opacity_post_border : 1.0;
	
	COLOR = color;
}
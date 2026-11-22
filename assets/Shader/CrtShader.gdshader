shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec2 resolution = vec2(320.0, 180.0);

uniform float scan_line_amount : hint_range(0.0, 1.0) = 0.5;
uniform float warp_amount : hint_range(0.0, 1.0) = 0.05;
uniform float vignette_amount : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float grille_amount : hint_range(0.0, 1.0) = 0.05;
uniform float brightness_boost : hint_range(1.0, 2.0) = 1.2;

uniform sampler2D original_palette : filter_nearest, repeat_disable;
uniform sampler2D target_palette : filter_nearest, repeat_disable;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;

vec3 apply_pallete(vec3 current_color){
    vec3 result_color_pallete = current_color;
	ivec2 pal_size = textureSize(original_palette, 0);
	if(pal_size.x <= 0 || pal_size.y <= 0){
		return current_color;
	}
	// Validamos que la paleta esté cargada
	if (pal_size.x > 0 && pal_size.y > 0) {
		bool match_found = false;
		for (int y = 0; y < pal_size.y; y++) {
			for (int x = 0; x < pal_size.x; x++) {
				ivec2 texel_coord = ivec2(x, y);
				vec4 ref_color = texelFetch(original_palette, texel_coord, 0);
				    
				if (ref_color.a < 0.1) {
					continue;
				}
				// Margen de tolerancia mínimo para float
				if (distance(current_color.rgb, ref_color.rgb) < 0.008) {
					vec4 new_color = texelFetch(target_palette, texel_coord, 0);
					result_color_pallete = new_color.rgb;
					match_found = true;
					break;
				}
			}
			if (match_found) {
				break;
			}
		}
	}
	return result_color_pallete;
}

void fragment() {
    vec2 uv = SCREEN_UV;

    vec2 delta = uv - 0.5;
    float warp_factor = dot(delta, delta) * warp_amount;
    uv += delta * warp_factor;

    float scanline = sin(uv.y * resolution.y * PI) * 0.5 + 0.5;
    scanline = mix(1.0, scanline, scan_line_amount * 0.5); // Réduit l'impact

    float grille = mod(uv.x * resolution.x, 3.0) < 1.5 ? 0.95 : 1.05;
    grille = mix(1.0, grille, grille_amount * 0.5);
	
	vec3 color = texture(SCREEN_TEXTURE, uv).rgb;
	color = apply_pallete(color);
    
	color *= scanline * grille;

    vec2 v_uv = uv * (1.0 - uv.xy);
    float vignette = v_uv.x * v_uv.y * 15.0;
    vignette = mix(1.0, vignette, vignette_amount * 0.7);

    color *= vignette * brightness_boost;

    COLOR.rgb = color;
    COLOR.a = 1.0;
}
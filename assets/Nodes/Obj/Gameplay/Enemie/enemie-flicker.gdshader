//https://godotshaders.com/shader/blinking-bomb-countdown/
shader_type canvas_item;

uniform float end_time = 5.0; //length of animation in seconds
uniform float start_freq : hint_range(0.0, 1.0, 0.05) = 1; //how fast the flashing will be at start of animation
uniform float end_freq : hint_range(1.0, 20.0, 0.5) = 10; //how fast it will be in the end
uniform float time; //time variable to set in code
uniform vec4 flash_color : source_color = vec4(1.0);
uniform vec4 flash_color2 : source_color = vec4(1.0);
uniform float blink_length : hint_range(0.0, 1.0) = 0.5;
uniform float posterize = .25;
uniform float div_second_color = .50;

void fragment() {
	float phase = 2.0 * PI * (start_freq * time + (end_freq - start_freq) / (2.0 * end_time) * time*time);
	float wave = sin(phase);
	float blink_wave = floor((time/end_time)/posterize)*posterize;//*2.0;//wave * (1.0/blink_length) - (1.0/blink_length) + 1.0;
	
	vec4 t = texture(TEXTURE, UV);
	if (blink_wave > 0.0) {
		vec3 colorMix;
		if( mod(blink_wave, div_second_color) == 0.0 ){
	    	colorMix = mix(t.rgb, flash_color.rgb, blink_wave*flash_color.a);
		}
		else{
			colorMix = mix(t.rgb, flash_color2.rgb, blink_wave*flash_color.a);
		}
		COLOR = vec4(colorMix, t.a); // Preserve the alpha value from the texture
	}
}

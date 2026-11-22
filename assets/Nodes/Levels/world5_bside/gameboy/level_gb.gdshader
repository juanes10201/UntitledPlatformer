shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec3 pallette_white : source_color = vec3(0.988235294, 0.980392157, 0.988235294);
uniform vec3 pallette_light_grey : source_color = vec3(0.674509804, 0.149019608, 0.141176471);
uniform vec3 pallette_dark_grey : source_color = vec3(0.925490196, 0.541176471, 0.549019608);
uniform vec3 pallette_black : source_color = vec3(0.015686275, 0.094117647, 0.015686275);

vec3 tex2D(sampler2D _tex,vec2 _p)
{
	vec3 col=texture(_tex,_p).xyz;
	if(.5<abs(_p.x-.5)){
		col=vec3(.1);
	}
	return col;
}

void fragment() {

	vec2 percent = (SCREEN_UV.xy);

	vec3 pixelColor = tex2D(SCREEN_TEXTURE, percent).xyz;
	float a = texture(SCREEN_TEXTURE, percent).a;

	float pixelGrey = dot(pixelColor, vec3(1.0/3.0));
	if(pixelGrey > 0.75){
		pixelColor = pallette_white;
	}else if(pixelGrey > 0.5){
		pixelColor = pallette_light_grey;
	}else  if(pixelGrey > 0.25){
		pixelColor = pallette_dark_grey;
	}else if(pixelGrey > 0.0){
		pixelColor = pallette_black;
	}
	COLOR = vec4(pixelColor, a);
}
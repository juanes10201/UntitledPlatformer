//https://godotshaders.com/shader/earthbound-background-shader/
//Shader created by roteroam

shader_type canvas_item;

uniform float horizontal_oscillation : hint_range(0.0, 1, 0.001) = 0.01;
uniform float vertical_oscillation : hint_range(0.0, 1, 0.001) = 0.01;
uniform float scanline_wave_frequency : hint_range(1.0, 100.0, 0.1) = 40.0;
uniform float scanline_wave_speed : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform bool alternate_direction = true;

uniform vec2 viewport_size;

uniform float hue_shift_speed : hint_range(0.0, 5.0, 0.01) = 0.5;
uniform float hue_strength : hint_range(0.0, 1.0, 0.01) = 1.0;

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0., -1./3., 2./3., -1.);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1e-10;
    return vec3(abs((q.w - q.y) / (6. * d + e)),
                d / (q.x + e),
                q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6. + vec3(0., 4., 2.), 6.) - 3.) - 1., 0., 1.);
    return c.z * mix(vec3(1.), rgb, c.y);
}

void fragment() {
    vec2 uv = UV;
    float pixel_y = SCREEN_UV.y * viewport_size.y;
    int scanline = int(floor(pixel_y));
    float wave = sin(pixel_y / scanline_wave_frequency + TIME * scanline_wave_speed);
    float x_offset = wave * horizontal_oscillation;
    if (alternate_direction && (scanline % 2 == 1)) {
        x_offset = -x_offset;
    }
    float y_offset = wave * vertical_oscillation;

    uv.x += x_offset;
    uv.y += y_offset;

    vec4 tex_color = texture(TEXTURE, uv);
    if (tex_color.a == 0.0) {
        COLOR = tex_color;
    }
    vec3 hsv = rgb2hsv(tex_color.rgb);
    hsv.x = mod(hsv.x + TIME * hue_shift_speed * hue_strength, 1.0);
    vec3 scrolled_color = hsv2rgb(hsv);

    COLOR = vec4(scrolled_color, tex_color.a);
}

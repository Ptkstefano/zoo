shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float saturation_r: hint_range(-1.0, 1.0) = 1.0;
uniform float saturation_g: hint_range(-1.0, 1.0) = 1.0;
uniform float saturation_b: hint_range(-1.0, 1.0) = 1.0;
uniform float color_quantization: hint_range(1.0, 32.0) = 32.0;
uniform float brightness: hint_range(-1.0, 1.0) = 0.0;
uniform float contrast: hint_range(-1.0, 1.0) = 0.0;

uniform bool use_palette = false;
uniform sampler2D palette;
uniform uint palette_colors;

void fragment() {
    if (use_palette) {
    vec3 transform = vec3(0.2989, 0.5870, 0.1140);
    float luma = dot(texture(screen_texture, SCREEN_UV).rgb, transform);

    float sample_x = floor(luma*float(palette_colors))/float(palette_colors);
    COLOR = texture(palette, vec2(sample_x, 0.5));
}
    else {
        COLOR = texture(screen_texture, SCREEN_UV);
}

// selective desaturation
vec3 transform = vec3(0.2989, 0.5870, 0.1140);
float luma = dot(COLOR.rgb, transform);
COLOR.r = mix(luma, COLOR.r, saturation_r);
COLOR.g = mix(luma, COLOR.g, saturation_g);
COLOR.b = mix(luma, COLOR.b, saturation_b);

// contrast
float c = sign(contrast)*contrast*contrast + 1.0;
COLOR.rgb = (COLOR.rgb - vec3(0.5))*c + 0.5;

// brightness
float b = sign(brightness)*brightness*brightness;
COLOR.rgb += vec3(b);

// color quantization
COLOR.rgb = round(COLOR.rgb*color_quantization)/color_quantization;
}
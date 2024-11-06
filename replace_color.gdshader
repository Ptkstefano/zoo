shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float r;
uniform float g;
uniform float b;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);

	COLOR = color;

	if (color.rgb == vec3(0.0, 0.0, 0.0)) {
	    COLOR.rgb = vec3(r, g, b);
	}

}


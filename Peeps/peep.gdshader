shader_type canvas_item;

uniform vec4 target_body_color : source_color = vec4(0.675, 0.196, 0.196, 1.0); // #ac3232
uniform vec4 target_skin_color : source_color = vec4(0.929, 0.651, 0.541, 1.0); // #ac3232
uniform vec4 target_hair_color : source_color = vec4(0.388, 0.251, 0.165, 1.0); // #ac3232

uniform vec4 body_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // default replacement color
uniform vec4 skin_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // default replacement color
uniform vec4 hair_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // default replacement color

void fragment() {
	if (distance(COLOR.rgba, target_body_color.rgba) < 0.01){
		COLOR = body_color;
	}
		if (distance(COLOR.rgba, target_skin_color.rgba) < 0.01){
		COLOR = skin_color;
	}
		if (distance(COLOR.rgba, target_hair_color.rgba) < 0.01){
		COLOR = hair_color;
	}
}
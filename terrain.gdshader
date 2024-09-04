shader_type canvas_item;

void fragment() {
	vec4 right_neighbor_color = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0));
	vec4 down_neighbor_color = texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y));
	vec4 left_neighbor_color = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0));
	vec4 up_neighbor_color = texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y));
	
	vec4 average_color = COLOR;
	
	for (float x = -3.; x < 4.; x += 1.)
	{
		vec4 neighbor = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x * x, 0));
		if (neighbor.a > 0.1){
			if (neighbor != COLOR){
				average_color = (average_color + neighbor) / 2.;
			}
		}
	}
	
	for (float x = -3.; x < 4.; x += 1.)
	{
		vec4 neighbor = texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y * x));
		if (neighbor.a > 0.1){
			if (neighbor != COLOR){
				average_color = (average_color + neighbor) / 2.;
			}
		}
	}
	
	COLOR = average_color;
	
}
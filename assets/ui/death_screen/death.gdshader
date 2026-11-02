shader_type canvas_item;
// guided by Gemini
uniform vec2 scale = vec2(4, 4);
uniform vec2 scroll = vec2(0.3, 0.3);
uniform float alpha = 0.99;


void fragment() {
	vec2 new_uv = UV * scale + vec2(TIME, TIME) * scroll;
	COLOR = texture(TEXTURE, new_uv) * vec4(1, 1, 1, alpha) * COLOR;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

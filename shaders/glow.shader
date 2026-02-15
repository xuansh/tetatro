shader_type canvas_item;

uniform float glow_strength = 2.0;
uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	// 计算发光效果
	vec4 glow = glow_color * glow_strength * original_color.a;
	
	// 混合原始颜色和发光效果
	COLOR = original_color + glow;
}
shader_type canvas_item;

uniform float blur_amount;

void fragment() {
	vec3 blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount).rgb;
	COLOR.rgb = vec3(COLOR.a) * COLOR.rgb + vec3(1.0 - COLOR.a) * blurred;
	COLOR.a = 1.0;
}
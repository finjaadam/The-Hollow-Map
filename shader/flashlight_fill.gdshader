shader_type canvas_item;

uniform float fill_progress : hint_range(0.0, 1.0) = 1.0;
uniform float dim_alpha : hint_range(0.0, 1.0) = 0.08;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float threshold = 1.0 - UV.y;
	float t = (fill_progress - threshold) / 0.08;
	float fill = clamp(t, 0.0, 1.0);
	if (fill_progress >= 1.0) {
		COLOR.a = tex.a;
	} else {
		float alpha = mix(dim_alpha, 1.0, fill);
		COLOR.a = tex.a * alpha;
	}
}

shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_back, fog_disabled;

uniform vec4 silhouette_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	ALBEDO = silhouette_color.rgb;
	ALPHA = silhouette_color.a;
}

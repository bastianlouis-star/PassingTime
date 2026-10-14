shader_type canvas_item;
// "HD-2D" finish: tilt-shift depth of field (sharp band across the middle, soft top and
// bottom), strong bloom on bright areas, a saturated split-tone grade and a vignette.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform float bloom : hint_range(0.0, 2.0) = 0.5;
uniform float vignette : hint_range(0.0, 1.0) = 0.34;
uniform float focus_y : hint_range(0.0, 1.0) = 0.56;
uniform float blur_max : hint_range(0.0, 12.0) = 5.5;
uniform float saturation : hint_range(0.5, 1.8) = 1.04;
uniform float fade : hint_range(0.0, 1.0) = 0.0;

const vec2 TAPS[12] = vec2[](
	vec2(0.0, 1.0), vec2(0.87, 0.5), vec2(0.87, -0.5), vec2(0.0, -1.0), vec2(-0.87, -0.5), vec2(-0.87, 0.5),
	vec2(0.0, 0.5), vec2(0.43, 0.25), vec2(0.43, -0.25), vec2(0.0, -0.5), vec2(-0.43, -0.25), vec2(-0.43, 0.25));

void fragment() {
	vec2 uv = SCREEN_UV;
	float d = abs(uv.y - focus_y);
	float amt = smoothstep(0.17, 0.52, d);
	vec3 c = textureLod(screen_tex, uv, 0.0).rgb;
	if (amt > 0.01) {
		// radius in uv units, independent of the window resolution (tuned at 1280 wide)
		float r = amt * blur_max / 1280.0;
		float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
		vec3 acc = c;
		float wsum = 1.0;
		for (int i = 0; i < 12; i++) {
			vec2 o = TAPS[i] * r * vec2(1.0, aspect);
			acc += textureLod(screen_tex, uv + o, 0.0).rgb;
			wsum += 1.0;
		}
		c = acc / wsum;
	}
	vec3 b = textureLod(screen_tex, uv, 2.5).rgb * 0.34
		+ textureLod(screen_tex, uv, 3.5).rgb * 0.33
		+ textureLod(screen_tex, uv, 4.5).rgb * 0.33;
	vec3 hi = max(b - vec3(0.45), vec3(0.0));
	c += hi * bloom;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(l), c, saturation);
	c = mix(c, c * vec3(1.07, 1.0, 0.9), smoothstep(0.45, 1.0, l));
	c = mix(c, c * vec3(0.9, 0.98, 1.1), 1.0 - smoothstep(0.0, 0.5, l));
	c = (c - 0.5) * 1.08 + 0.5;
	vec2 v = uv - vec2(0.5);
	c *= 1.0 - dot(v, v) * vignette * 1.7;
	c = mix(c, vec3(0.0), fade);
	COLOR = vec4(clamp(c, 0.0, 1.0), 1.0);
}

shader_type canvas_item;

uniform vec2 output_size = vec2(100.0, 100.0);

uniform sampler2D noise1;
uniform sampler2D noise2;

uniform vec2 scroll_speed1 = vec2(0.01, 0.0);
uniform vec2 scroll_speed2 = vec2(0.0, 0.01);

uniform vec4 base_color : source_color = vec4(0.1, 0.4, 0.7, 1.0);
uniform vec4 foam_color : source_color = vec4(0.9, 0.95, 1.0, 1.0);

uniform float foam_threshold : hint_range(0.0, 1.0) = 0.72;
uniform float foam_softness : hint_range(0.001, 0.2) = 0.05;
uniform float water_darkness : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec2 uv = floor(UV * output_size) / output_size;

    vec4 n1 = texture(noise1, mod(uv + TIME * scroll_speed1, vec2(1.0)));
    vec4 n2 = texture(noise2, mod(uv + TIME * scroll_speed2, vec2(1.0)));

    // Combined noise value (grayscale)
    float noise_val = sqrt(n1.r * n2.r);

    // Water: blend base_color darkened in troughs, lighter on crests
    vec3 water = mix(base_color.rgb * water_darkness, base_color.rgb, noise_val);

    // Foam: soft threshold near the bright peaks of the noise
    float foam_amount = smoothstep(foam_threshold - foam_softness, foam_threshold + foam_softness, noise_val);

    // Composite foam over water
    vec3 final_color = mix(water, foam_color.rgb, foam_amount * foam_color.a);

    COLOR = vec4(final_color, base_color.a);
}

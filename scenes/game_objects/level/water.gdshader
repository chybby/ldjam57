shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_back;

uniform sampler2D wave_texture;

uniform bool enable_surface = false;

uniform vec4 water_color : source_color = vec4(0.041, 0.147, 0.161, 0.95);
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_thickness : hint_range(0.01, 0.5) = 0.1;
uniform float line_threshold : hint_range(0.0, 1.0) = 0.7;

uniform float line_speed;

uniform float wave_frequency = 50.0;
uniform vec2 wave_direction = vec2(1.0, 0.5);
uniform float wave_speed = 1;
uniform float wave_height = 0.03;
uniform float steps = 5.0;

float wave_function(vec2 position, float time){
    float wave = sin(position.x * wave_frequency + time * wave_speed) * 0.5;
    wave += sin(position.y * wave_frequency * 0.8 + time * wave_speed * 1.2) * 0.5;
    
    wave = floor(wave * steps) / steps;
    
    return wave * wave_height;    
}

void vertex() {
	// Called for every vertex the material is visible on.
    VERTEX.y += wave_function(VERTEX.xz, TIME);
}

void fragment() {
    if(enable_surface) 
    {
        vec2 scroll_amount = sin(wave_direction * TIME * line_speed);
    
        vec2 noise_uv = fract(UV + scroll_amount);
        float noise_value = texture(wave_texture, noise_uv).r;
        
        float line_mask = smoothstep(line_threshold - line_thickness, line_threshold, noise_value);
    
        float line_mask2 = smoothstep(line_threshold - 0.3 - line_thickness, line_thickness - 0.3, noise_value);
    
        line_mask = max(line_mask, line_mask2 * 0.7);
    
        vec3 final_color = mix(water_color.rgb, line_color.rgb, line_mask);
    
	   // Called for every pixel the material is visible on.
        ALBEDO = final_color;
        ALPHA = water_color.a;
    }
    else 
    {
        ALBEDO = water_color.rgb;
        ALPHA = water_color.a;
    }
    
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

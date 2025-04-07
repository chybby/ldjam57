shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float wobble_speed : hint_range(0.1, 5.0) = 1.0;
uniform float wobble_strength : hint_range(0.0, 0.1, 0.001) = 0.005;
uniform vec4 tint_color : source_color = vec4(0.2, 0.5, 0.8, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.25;

uniform float distortion_scale : hint_range(1.0, 20.0) = 10.0;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;

void fragment() { 
    // First distortion: diagonal wave pattern
    float wobble1 = sin(TIME * wobble_speed + (UV.x + UV.y) * distortion_scale) * wobble_strength;
    
    // Second distortion: perpendicular diagonal wave pattern
    float wobble2 = cos(TIME * wobble_speed * 0.8 + (UV.x - UV.y) * distortion_scale * 1.3) * wobble_strength;
    
    // Third distortion: higher frequency wave for smaller ripples
    float wobble3 = sin(TIME * wobble_speed * 1.5 + UV.x * distortion_scale * 2.0) * wobble_strength * 0.5;
    
    // Fourth distortion: variation in Y direction
    float wobble4 = cos(TIME * wobble_speed * 1.2 + UV.y * distortion_scale * 2.5) * wobble_strength * 0.5;
    
    // Create circular waves from the center
    vec2 center_uv = UV - vec2(0.5, 0.5); // UV coordinates relative to center
    float dist_from_center = length(center_uv);
    float circular_wave = sin(dist_from_center * distortion_scale - TIME * wobble_speed) * wobble_strength;
    
    vec2 screen_uv_distorted = SCREEN_UV;
    screen_uv_distorted.x += wobble1 + wobble3 + circular_wave * 0.5;
    screen_uv_distorted.y += wobble2 + wobble4 + circular_wave * 0.5;
    
    vec4 screen_color = texture(SCREEN_TEXTURE, screen_uv_distorted);
    
    // Apply tint
    COLOR.rgb = mix(screen_color.rgb, tint_color.rgb, tint_strength);
    COLOR.a = screen_color.a;
    
    float total_distortion = abs(wobble1) + abs(wobble2) + abs(wobble3) + abs(wobble4) + abs(circular_wave);
    COLOR.rgb *= (1.0 - total_distortion * 5.0); 
}

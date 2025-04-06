shader_type canvas_item;
#define MAXCOLORS 64

//Chromatic aberration
uniform bool enable_aberration = true;
uniform int levels = 3;
uniform float spread = 0.01;

//Dithering
uniform bool enable_dithering = true;
uniform int colors : hint_range(1, MAXCOLORS) = 12;
uniform int dither_size : hint_range(1, 8) = 1;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Bayer dithering matrix
float dithering_pattern(ivec2 fragcoord) {
    const float pattern[] = {
        0.00, 0.50, 0.10, 0.65, 
        0.75, 0.25, 0.90, 0.35, 
        0.20, 0.70, 0.05, 0.50, 
        0.95, 0.40, 0.80, 0.30
    };
    
    int x = fragcoord.x % 4;
    int y = fragcoord.y % 4;
    
    return pattern[y * 4 + x];
}

// Color reduction function
float reduce_color(float raw, float dither, int depth) {
    float div = 1.0 / float(depth);
    float val = 0.0;
    int i = 0;

    while (i <= MAXCOLORS) {
        if (raw > div * (float(i + 1))) {
            i = i + 1;
            continue;
        }

        if (raw * float(depth) - float(i) <= dither * 0.999) {
            val = div * float(i);
        } else {
            val = div * float(i + 1);
        }
        return val;

        i = i + 1;
    }

    return val;
}

vec3 chromatic_slice(float t){
	vec3 res = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
	return max(res, 0.0);
}

void fragment(){
    vec3 final_color;
    if(enable_aberration) {   
	   vec3 sum = vec3(0.0);
	   final_color = vec3(0.0);
	   vec2 offset = (UV - vec2(0.5))*vec2(1,-1);
	   for(int i = 0; i < levels; i++){
		  float t = 2.0*float(i)/float(levels-1); // range 0.0->2.0
		  vec3 slice = vec3(1.0-t, 1.0 - abs(t - 1.0), t - 1.0);
		  slice = max(slice, 0.0);
		  sum += slice;
		  vec2 slice_offset = (t-1.0)*spread*offset;
		  final_color += slice * texture(SCREEN_TEXTURE, SCREEN_UV + slice_offset).rgb;
	   }
	   final_color /= sum;
    } else {
        final_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    }
    
    if(enable_dithering) {
        ivec2 uv = ivec2(FRAGCOORD.xy / float(dither_size));
        float dithering_value = dithering_pattern(uv);
        
        final_color.r = reduce_color(final_color.r, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);
        final_color.g = reduce_color(final_color.g, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);
        final_color.b = reduce_color(final_color.b, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);
    }
    
    COLOR.rgb = final_color;
}
shader_type canvas_item;

// Color shift parameters
uniform float color_shift_speed : hint_range(0.0, 20.0) = 8.0;
uniform float color_shift_intensity : hint_range(0.0, 2.0) = 0.15;

// Glitch parameters
uniform float glitch_frequency : hint_range(0.0, 50.0) = 30.0;
uniform float glitch_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float slice_size : hint_range(0.0, 1.0) = 0.05;
uniform float slice_shift_intensity : hint_range(0.0, 2.0) = 0.4;

// Additional effects
uniform float pulse_speed : hint_range(0.0, 10.0) = 5.0;
uniform float distortion_strength : hint_range(0.0, 2.0) = 0.3;
uniform float scanline_speed : hint_range(0.0, 50.0) = 20.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;
    
    // Aggressive wave distortion
    float wave = sin(uv.y * 10.0 + TIME * pulse_speed) * distortion_strength;
    uv.x += wave * sin(TIME * 2.0);
    uv.y += wave * cos(TIME * 1.5);
    
    // Multi-channel color shifting
    float time_offset = TIME * color_shift_speed;
    float r = texture(TEXTURE, uv + vec2(sin(time_offset) * color_shift_intensity, cos(time_offset * 0.5) * color_shift_intensity)).r;
    float g = texture(TEXTURE, uv + vec2(cos(time_offset * 1.2) * color_shift_intensity * 0.8, sin(time_offset * 0.8) * color_shift_intensity)).g;
    float b = texture(TEXTURE, uv + vec2(sin(time_offset * 0.9) * color_shift_intensity * 1.2, cos(time_offset * 1.1) * color_shift_intensity)).b;
    vec4 color_shifted = vec4(r, g, b, texture(TEXTURE, uv).a);
    
    // Enhanced glitch effect
    float time_based_random = random(vec2(floor(TIME * glitch_frequency)));
    float slice = floor(uv.y / slice_size);
    float slice_random = random(vec2(slice, time_based_random));
    
    if (slice_random < glitch_intensity) {
        // Horizontal shift
        uv.x += (slice_random * 2.0 - 1.0) * slice_shift_intensity;
        
        // Vertical shift
        if (random(vec2(slice_random, TIME)) > 0.5) {
            uv.y += (random(vec2(slice, TIME)) * 2.0 - 1.0) * 0.2;
        }
        
        // Color inversion on some slices
        if (random(vec2(slice, TIME * 0.1)) > 0.9) {
            color_shifted.rgb = 1.0 - color_shifted.rgb;
        }
    }
    
    // Dynamic scanlines
    float scanline = sin(uv.y * 100.0 + TIME * scanline_speed) * 0.1;
    color_shifted.rgb += vec3(scanline);
    
    // Pulsing brightness
    float pulse = sin(TIME * pulse_speed) * 0.2 + 0.8;
    color_shifted.rgb *= pulse;
    
    // Random color tinting
    vec3 tint = vec3(
        sin(TIME * 2.0) * 0.5 + 0.5,
        cos(TIME * 1.7) * 0.5 + 0.5,
        sin(TIME * 1.4) * 0.5 + 0.5
    );
    
    COLOR = color_shifted;
    COLOR.rgb *= tint;
    
    // Add digital noise
    COLOR.rgb += (random(uv + vec2(TIME * 0.1)) - 0.5) * 0.1;
}
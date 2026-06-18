#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform sampler2D uDepthMap;
uniform float uFocusDepth;     // 0.0 to 1.0 (near to far)
uniform float uMaxBlurRadius; // 0.0 to 1.0 (normalized)

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    float pixelDepth = texture(uDepthMap, uv).r;
    
    // Calculate blur radius based on focus distance
    float blurIntensity = abs(pixelDepth - uFocusDepth);
    float radius = blurIntensity * uMaxBlurRadius;
    
    // Multi-sample Lens Blur (Bokeh) Simulation
    vec3 acc = vec3(0.0);
    float totalWeight = 0.0;
    const int SAMPLES = 8;
    
    for (int i = -SAMPLES; i <= SAMPLES; i++) {
        for (int j = -SAMPLES; j <= SAMPLES; j++) {
            vec2 offset = vec2(float(i), float(j)) * radius * 0.01;
            float weight = 1.0 / (1.0 + length(offset) * 100.0);
            
            acc += texture(uTexture, uv + offset).rgb * weight;
            totalWeight += weight;
        }
    }
    
    vec3 result = acc / totalWeight;
    fragColor = vec4(result, 1.0);
}

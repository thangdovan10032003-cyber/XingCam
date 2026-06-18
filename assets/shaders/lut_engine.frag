#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform sampler2D uLutA;
uniform sampler2D uLutB;
uniform float uInterpolation; // 0.0 (LutA) to 1.0 (LutB)

out vec4 fragColor;

// Professional 3D LUT Lookup for LutA
vec3 sampleLutA(vec3 inColor) {
    float size = 64.0;
    float sliceSize = 1.0 / size;
    float sliceInnerSize = sliceSize * (size - 1.0) / size;
    float zSlice = inColor.b * (size - 1.0);
    
    float zSliceLow = floor(zSlice);
    float zSliceHigh = ceil(zSlice);
    
    vec2 uvLow = vec2(inColor.r * sliceInnerSize + (zSliceLow / size), inColor.g);
    vec2 uvHigh = vec2(inColor.r * sliceInnerSize + (zSliceHigh / size), inColor.g);
    
    vec3 colorLow = texture(uLutA, uvLow).rgb;
    vec3 colorHigh = texture(uLutA, uvHigh).rgb;
    
    return mix(colorLow, colorHigh, fract(zSlice));
}

// Professional 3D LUT Lookup for LutB
vec3 sampleLutB(vec3 inColor) {
    float size = 64.0;
    float sliceSize = 1.0 / size;
    float sliceInnerSize = sliceSize * (size - 1.0) / size;
    float zSlice = inColor.b * (size - 1.0);
    
    float zSliceLow = floor(zSlice);
    float zSliceHigh = ceil(zSlice);
    
    vec2 uvLow = vec2(inColor.r * sliceInnerSize + (zSliceLow / size), inColor.g);
    vec2 uvHigh = vec2(inColor.r * sliceInnerSize + (zSliceHigh / size), inColor.g);
    
    vec3 colorLow = texture(uLutB, uvLow).rgb;
    vec3 colorHigh = texture(uLutB, uvHigh).rgb;
    
    return mix(colorLow, colorHigh, fract(zSlice));
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    vec4 source = texture(uTexture, uv);
    
    // Sample from both LUTs natively
    vec3 gradedA = sampleLutA(source.rgb);
    vec3 gradedB = sampleLutB(source.rgb);
    
    // Interpolate according to keyframe weight
    vec3 finalColor = mix(gradedA, gradedB, uInterpolation);
    
    fragColor = vec4(finalColor, source.a);
}

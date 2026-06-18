#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 u_Size;
uniform sampler2D u_SdrTexture;
uniform sampler2D u_GainMapTexture;
uniform float u_MaxHdrLuminance; // Max display boost (e.g. 8.0 for 1000 nits)
uniform float u_HdrMix;          // 0.0 (SDR) to 1.0 (True HDR)

out vec4 fragColor;

/**
 * Reconstruction of Ultra HDR (Gain Map) radiance.
 * Based on the Adobe/Google ISO 21496-1 Gain Map specification.
 */
void main() {
    vec2 uv = FlutterFragCoord().xy / u_Size;
    
    // 1. Sample SDR base image
    vec4 sdrColor = texture(u_SdrTexture, uv);
    
    // 2. Sample Gain Map (usually a single channel grayscale)
    vec4 gainColor = texture(u_GainMapTexture, uv);
    float gainValue = gainColor.r; // Normalized 0.0 -> 1.0

    // 3. HDR Reconstruction Formula
    // hdrValue = sdrValue * pow(2, gainValue * log2(maxLuminance))
    // We use exponential interpolation to restore highlights.
    float boost = exp2(gainValue * log2(u_MaxHdrLuminance));
    
    // Mix based on u_HdrMix to allow smooth "SDR to HDR" transition if needed
    vec3 finalRgb = sdrColor.rgb * mix(1.0, boost, u_HdrMix);
    
    // Output directly to Impeller's high-bit-depth buffer
    fragColor = vec4(finalRgb, sdrColor.a);
}

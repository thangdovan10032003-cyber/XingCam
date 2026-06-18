#version 460 core

// XingCam Beauty Shader v1.0
// Ported to SPIR-V for Flutter Graphics initialization.
// Focus: Real-time skin smoothing and brightening @ 30 FPS.

precision mediump float;

layout(location = 0) out vec4 fragColor;
layout(location = 0) in vec2 texCoord;

uniform sampler2D uTexture;
uniform float uSmoothness; // 0.0 to 1.0
uniform float uBrightening; // 0.0 to 1.0

void main() {
    vec4 color = texture(uTexture, texCoord);
    
    // Simple 3x3 Box Blur simulation for skin-tone pixels
    vec2 texelSize = 1.0 / textureSize(uTexture, 0);
    vec4 blurred = vec4(0.0);
    
    for(int i = -1; i <= 1; i++) {
        for(int j = -1; j <= 1; j++) {
            blurred += texture(uTexture, texCoord + vec2(i, j) * texelSize);
        }
    }
    blurred /= 9.0;

    // Skin Tone Masking (simplified)
    bool isSkin = (color.r > 0.4 && color.g > 0.2 && color.b > 0.1 && (color.r - color.g) > 0.05);
    
    vec4 processed = color;
    if(isSkin) {
        processed = mix(color, blurred, uSmoothness);
    }
    
    // Brightening
    processed.rgb *= (1.0 + uBrightening * 0.15);
    
    fragColor = processed;
}

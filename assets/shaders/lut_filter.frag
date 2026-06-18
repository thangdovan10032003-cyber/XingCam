#include <flutter/runtime_effect.glsl>

uniform sampler2D tInput;
uniform sampler2D tLut;
uniform float lutSize;
uniform vec2 resolution;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / resolution;
    vec4 inColor = texture(tInput, uv);
    
    float blueColor = inColor.b * (lutSize - 1.0);
    
    vec2 quad1;
    quad1.y = floor(floor(blueColor) / lutSize);
    quad1.x = floor(blueColor) - (quad1.y * lutSize);
    
    vec2 quad2;
    quad2.y = floor(ceil(blueColor) / lutSize);
    quad2.x = ceil(blueColor) - (quad2.y * lutSize);
    
    vec2 texPos1;
    texPos1.x = (quad1.x * 1.0/lutSize) + 0.5/1024.0 + ((1.0/lutSize - 1.0/1024.0) * inColor.r);
    texPos1.y = (quad1.y * 1.0/lutSize) + 0.5/1024.0 + ((1.0/lutSize - 1.0/1024.0) * inColor.g);
    
    vec2 texPos2;
    texPos2.x = (quad2.x * 1.0/lutSize) + 0.5/1024.0 + ((1.0/lutSize - 1.0/1024.0) * inColor.r);
    texPos2.y = (quad2.y * 1.0/lutSize) + 0.5/1024.0 + ((1.0/lutSize - 1.0/1024.0) * inColor.g);
    
    vec4 newColor1 = texture(tLut, texPos1);
    vec4 newColor2 = texture(tLut, texPos2);
    
    vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
    fragColor = vec4(newColor.rgb, inColor.a);
}

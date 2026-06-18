#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform sampler2D uNormalMap;
uniform vec3 uLightPos; // Normalized coordinates [0, 1] for x, y, and z for depth
uniform vec3 uLightColor;
uniform float uLightIntensity;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    vec4 albedo = texture(uTexture, uv);
    vec3 normal = texture(uNormalMap, uv).rgb * 2.0 - 1.0;
    
    // Pixel 3D position (approximate z as base)
    vec3 pixelPos = vec3(uv, 0.0);
    
    // Light calculation
    vec3 lightDir = normalize(uLightPos - pixelPos);
    
    // 1. Ambient
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * uLightColor;
    
    // 2. Diffuse (Lambertian)
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * uLightColor * uLightIntensity;
    
    // 3. Specular (Phong)
    float specularStrength = 0.5;
    vec3 viewDir = vec3(0.0, 0.0, 1.0); // Viewer is looking straight
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    vec3 specular = specularStrength * spec * uLightColor;
    
    // Final Compositing
    vec3 result = (ambient + diffuse + specular) * albedo.rgb;
    
    fragColor = vec4(result, albedo.a);
}

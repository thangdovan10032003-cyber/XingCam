#version 460 core

#include <flutter/runtime_effect.glsl>

precision mediump float;

layout(location = 0) out vec4 fragColor;

// Định nghĩa các tham số đầu vào từ Dart (Cubit/Widget)
// Thứ tự truyền biến trong Dart: width, height, smoothness, brightening
uniform vec2 uSize;         // Kích thước của Viewfinder/Canvas
uniform float uSmoothness;  // Cường độ làm mịn: 0.0 đến 1.0
uniform float uBrightening; // Cường độ làm sáng: 0.0 đến 1.0
uniform sampler2D uTexture;

/// Thuật toán nhận diện da mặt trong hệ màu YCbCr (Cực kỳ chính xác)
bool isSkinYCbCr(vec3 rgb) {
    float y  =  0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b;
    float cb = -0.169 * rgb.r - 0.331 * rgb.g + 0.500 * rgb.b + 0.5;
    float cr =  0.500 * rgb.r - 0.419 * rgb.g - 0.081 * rgb.b + 0.5;
    return (cb >= 0.32 && cb <= 0.48 && cr >= 0.54 && cr <= 0.67);
}

void main() {
    // Tính toán tọa độ UV chuẩn hóa từ tọa độ mảnh của Flutter
    vec2 fragCoord = FlutterFragCoord();
    vec2 uv = fragCoord / uSize;
    vec4 color = texture(uTexture, uv);
    
    // ── BỘ LỌC SONG PHƯƠNG (BILATERAL FILTER) BẢO TOÀN CHI TIẾT SẮC NÉT ──
    vec2 texelSize = 1.0 / uSize;
    vec3 sum = vec3(0.0);
    float factorSum = 0.0;
    
    // Bán kính lọc không gian và ngưỡng sai lệch màu sắc
    float sigmaS = 4.0; 
    float sigmaR = 0.08 + (1.0 - uSmoothness) * 0.12; // Điều chỉnh động theo thanh trượt của người dùng
    
    for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
            vec2 offset = vec2(float(i), float(j)) * texelSize;
            vec4 neighborSample = texture(uTexture, uv + offset);
            vec3 neighborColor = neighborSample.rgb;
            
            // 1. Trọng số khoảng cách không gian (Spatial Weight)
            float distS = dot(offset, offset);
            float weightS = exp(-distS / (2.0 * sigmaS * sigmaS));
            
            // 2. Trọng số khoảng cách màu sắc (Color Distance Weight - Bảo toàn cạnh)
            vec3 diffColor = neighborColor - color.rgb;
            float distR = dot(diffColor, diffColor);
            float weightR = exp(-distR / (2.0 * sigmaR * sigmaR));
            
            float weight = weightS * weightR;
            sum += neighborColor * weight;
            factorSum += weight;
        }
    }
    
    // Tránh lỗi chia cho 0 trong đồ họa
    vec3 blurred = sum / max(factorSum, 0.0001);
    
    // ── ÁP DỤNG LÀM MỊN DA & LÀM SÁNG ──
    vec4 processed = color;
    if (isSkinYCbCr(color.rgb)) {
        processed.rgb = mix(color.rgb, blurred, uSmoothness);
    }
    
    // Làm sáng nhẹ nhàng dải mid-tone của gương mặt
    processed.rgb *= (1.0 + uBrightening * 0.15);
    
    fragColor = processed;
}

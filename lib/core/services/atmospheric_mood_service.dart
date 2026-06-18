import 'package:flutter/material.dart';

/// AtmosphericMoodService — v1.5 "Fenweigan" Engine.
/// Blends environment textures over depth-aware images to create immersive atmospheres.
class AtmosphericMoodService {
  
  /// Applies a spatial mood effect based on a depth map.
  /// Places elements (Mist, Light Beams) either in front of or behind the subject.
  static Widget buildMoodOverlay({
    required Widget child,
    required String moodType, // 'mist', 'beams', 'rain'
    required double intensity,
    bool bgOnly = false,
  }) {
    return Stack(
      children: [
        child,
        // Behind subject (using depth mask logic - placeholder for shader)
        if (bgOnly || moodType == 'mist')
          _buildMoodLayer(moodType, intensity, isBackground: true),
        
        // Foreground layer
        if (!bgOnly)
          _buildMoodLayer(moodType, intensity, isBackground: false),
      ],
    );
  }

  static Widget _buildMoodLayer(String type, double intensity, {bool isBackground = false}) {
    switch (type) {
      case 'mist':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white.withOpacity(isBackground ? 0.3 * intensity : 0.1 * intensity),
                Colors.transparent,
              ],
            ),
          ),
        );
      case 'beams':
        return _LightBeamsOverlay(intensity: intensity);
      case 'rain':
        return _RainOverlay(intensity: intensity);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _LightBeamsOverlay extends StatelessWidget {
  final double intensity;
  const _LightBeamsOverlay({required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.5, -0.8),
          radius: 1.5,
          colors: [
            Colors.white.withOpacity(0.2 * intensity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6],
        ),
      ),
    );
  }
}

class _RainOverlay extends StatelessWidget {
  final double intensity;
  const _RainOverlay({required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.withOpacity(0.05 * intensity), // Subtle tint
      // In a real impl, this would use a noise shader for rain streaks
    );
  }
}

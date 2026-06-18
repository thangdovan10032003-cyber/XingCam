import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:xingcam/features/retro_camera/domain/entities/light_leak_settings.dart';

/// Renders a semi-transparent PNG light-leak texture over the camera preview.
/// Uses [BlendMode.screen] for a natural light bleed effect.
class LightLeakOverlay extends StatelessWidget {
  final LightLeakSettings settings;

  const LightLeakOverlay({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: settings.opacity.clamp(0.0, 1.0),
        child: Image.asset(
          settings.assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          color: AppColors.textPrimary,
          colorBlendMode: BlendMode.screen,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// CinematicStoryOverlay — v1.7 Documentary Assistant.
/// Provides visual guides and "Shot List" suggestions to help users create cinematic vlogs.
class CinematicStoryOverlay extends StatelessWidget {
  final String currentShotType;

  const CinematicStoryOverlay({
    super.key,
    this.currentShotType = 'EXTREME WIDE',
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Letterbox (Anamorphic 2.35:1)
          Column(
            children: [
              Container(height: 60, color: Colors.black),
              const Spacer(),
              Container(height: 60, color: Colors.black),
            ],
          ),

          // Cinematic Guides
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: 1,
              color: AppColors.gold.withOpacity(0.3),
            ),
          ),

          // Shot Suggestion Label
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.movie_creation_outlined, color: AppColors.gold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'NEXT SHOT: $currentShotType',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.gold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

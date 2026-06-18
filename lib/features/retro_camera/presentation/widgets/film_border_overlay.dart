import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:flutter/material.dart';

enum FilmBorderType { none, kodakPortra, polaroid, fujiPro }

class FilmBorderOverlay extends StatelessWidget {
  final FilmBorderType type;
  final Widget child;

  const FilmBorderOverlay({
    super.key,
    required this.type,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (type == FilmBorderType.none) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: _buildBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildBorder() {
    switch (type) {
      case FilmBorderType.kodakPortra:
        return _KodakBorder();
      case FilmBorderType.polaroid:
        return _PolaroidBorder();
      case FilmBorderType.fujiPro:
        return _FujiBorder();
      default:
        return Container();
    }
  }
}

class _KodakBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.background, width: 20),
      ),
      child: Stack(
        children: [
          // Kodak branding text on top
          Positioned(
            top: 4,
            left: 30,
            child: Text(
              'KODAK PORTRA 400',
              style: TextStyle(fontFamily: 'Outfit', 
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
          // Frame counters on side
          Positioned(
            bottom: 30,
            left: 4,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                '13',
                style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolaroidBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 30, color: AppColors.paper),
        Expanded(
          child: Row(
            children: [
              Container(width: 30, color: AppColors.paper),
              const Spacer(),
              Container(width: 30, color: AppColors.paper),
            ],
          ),
        ),
        Container(
          height: 100,
          color: AppColors.paper,
          alignment: Alignment.center,
          child: Text(
            'XINGCAM',
            style: TextStyle(fontFamily: 'PlayfairDisplay', 
              color: AppColors.background.withOpacity(0.45),
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }
}

class _FujiBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceLow, width: 16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _perfHole(),
                const SizedBox(width: 40),
                _perfHole(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _perfHole(),
                const SizedBox(width: 40),
                _perfHole(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _perfHole() {
    return Container(
      width: 12,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}


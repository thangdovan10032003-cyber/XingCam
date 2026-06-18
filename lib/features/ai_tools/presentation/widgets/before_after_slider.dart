import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

class BeforeAfterSlider extends StatefulWidget {
  final Widget before;
  final Widget after;

  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPos = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _sliderPos = (details.localPosition.dx / width).clamp(0.0, 1.0);
            });
          },
          child: Stack(
            children: [
              // After image (background)
              SizedBox(
                width: width,
                height: height,
                child: widget.after,
              ),

              // Before image (clipped)
              ClipRect(
                clipper: _SliderClipper(_sliderPos),
                child: SizedBox(
                  width: width,
                  height: height,
                  child: widget.before,
                ),
              ),

              // Slider handle
              Positioned(
                left: _sliderPos * width - 20,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.background.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Circle handle icon
              Positioned(
                left: _sliderPos * width - 18,
                top: height / 2 - 18,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.background.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(AppIcons.adjust,
                      color: AppColors.primary, size: 24),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double progress;
  _SliderClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) =>
      oldClipper.progress != progress;
}

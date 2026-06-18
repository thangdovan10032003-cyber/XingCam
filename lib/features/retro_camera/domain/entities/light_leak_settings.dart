import 'package:equatable/equatable.dart';

class LightLeakSettings extends Equatable {
  /// Asset path to a PNG light-leak overlay image.
  final String assetPath;
  /// Overlay opacity from 0.0 (invisible) to 1.0 (full).
  final double opacity;

  const LightLeakSettings({
    required this.assetPath,
    this.opacity = 0.3,
  });

  LightLeakSettings copyWith({String? assetPath, double? opacity}) {
    return LightLeakSettings(
      assetPath: assetPath ?? this.assetPath,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => [assetPath, opacity];
}

import 'package:equatable/equatable.dart';

class GrainSettings extends Equatable {
  /// Grain intensity from 0.0 (none) to 1.0 (heavy).
  final double intensity;
  /// Whether the grain texture refreshes on each frame for a film-like animation.
  final bool animated;

  const GrainSettings({
    this.intensity = 0.15,
    this.animated = true,
  });

  GrainSettings copyWith({double? intensity, bool? animated}) {
    return GrainSettings(
      intensity: intensity ?? this.intensity,
      animated: animated ?? this.animated,
    );
  }

  @override
  List<Object?> get props => [intensity, animated];
}

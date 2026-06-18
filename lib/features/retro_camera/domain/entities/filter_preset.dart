import 'package:equatable/equatable.dart';

class FilterPreset extends Equatable {
  final String id;
  final String name;
  final String lutAssetPath;
  final double intensity;
  /// A 4x5 color matrix approximating the LUT for real-time ColorFiltered preview.
  final List<double>? previewMatrix;

  const FilterPreset({
    required this.id,
    required this.name,
    required this.lutAssetPath,
    this.intensity = 1.0,
    this.previewMatrix,
  });

  FilterPreset copyWith({double? intensity}) {
    return FilterPreset(
      id: id,
      name: name,
      lutAssetPath: lutAssetPath,
      intensity: intensity ?? this.intensity,
      previewMatrix: previewMatrix,
    );
  }

  @override
  List<Object?> get props => [id, name, lutAssetPath, intensity];
}

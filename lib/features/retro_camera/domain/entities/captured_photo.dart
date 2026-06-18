import 'package:equatable/equatable.dart';
import 'filter_preset.dart';

class CapturedPhoto extends Equatable {
  final String path;
  final DateTime timestamp;
  final FilterPreset? appliedPreset;

  const CapturedPhoto({
    required this.path,
    required this.timestamp,
    this.appliedPreset,
  });

  @override
  List<Object?> get props => [path, timestamp, appliedPreset];
}

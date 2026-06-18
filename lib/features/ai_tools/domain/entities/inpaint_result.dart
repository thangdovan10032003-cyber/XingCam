import 'package:equatable/equatable.dart';

class InpaintResult extends Equatable {
  final String resultImagePath;
  final DateTime processedAt;

  const InpaintResult({
    required this.resultImagePath,
    required this.processedAt,
  });

  @override
  List<Object?> get props => [resultImagePath, processedAt];
}

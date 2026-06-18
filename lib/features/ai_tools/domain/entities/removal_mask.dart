import 'package:equatable/equatable.dart';

/// Represents the brush-painted mask that marks regions to inpaint.
/// [maskPath] points to a black-and-white PNG file where white = remove area.
class RemovalMask extends Equatable {
  final String maskPath;
  final double brushSize;

  const RemovalMask({
    required this.maskPath,
    required this.brushSize,
  });

  @override
  List<Object?> get props => [maskPath, brushSize];
}

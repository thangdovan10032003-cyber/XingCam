import 'package:equatable/equatable.dart';

class EditablePhoto extends Equatable {
  final String originalPath;
  final int width;
  final int height;

  const EditablePhoto({
    required this.originalPath,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [originalPath, width, height];
}

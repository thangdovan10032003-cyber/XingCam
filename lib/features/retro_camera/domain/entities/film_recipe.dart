import 'package:equatable/equatable.dart';
import 'package:xingcam/features/retro_camera/domain/entities/filter_preset.dart';
import 'package:xingcam/features/retro_camera/presentation/widgets/film_border_overlay.dart';

class FilmRecipe extends Equatable {
  final String id;
  final String name;
  final String author;
  final FilterPreset filter;
  final double grainIntensity;
  final FilmBorderType borderType;
  final bool showDateStamp;

  const FilmRecipe({
    required this.id,
    required this.name,
    this.author = 'Anonymous',
    required this.filter,
    required this.grainIntensity,
    this.borderType = FilmBorderType.none,
    this.showDateStamp = true,
  });

  @override
  List<Object?> get props => [id, name, author, filter, grainIntensity, borderType, showDateStamp];

  FilmRecipe copyWith({
    String? id,
    String? name,
    String? author,
    FilterPreset? filter,
    double? grainIntensity,
    FilmBorderType? borderType,
    bool? showDateStamp,
  }) {
    return FilmRecipe(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      filter: filter ?? this.filter,
      grainIntensity: grainIntensity ?? this.grainIntensity,
      borderType: borderType ?? this.borderType,
      showDateStamp: showDateStamp ?? this.showDateStamp,
    );
  }
}

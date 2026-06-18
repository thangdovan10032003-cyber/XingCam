import 'package:isar/isar.dart';
import 'package:xingcam/features/retro_camera/presentation/widgets/film_border_overlay.dart';

part 'recipe_isar_model.g.dart';

@collection
class RecipeIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late String author;
  
  late String filterId;
  
  late double grainIntensity;
  
  @enumerated
  late FilmBorderType borderType;
  
  late bool showDateStamp;

  late DateTime createdAt;
}

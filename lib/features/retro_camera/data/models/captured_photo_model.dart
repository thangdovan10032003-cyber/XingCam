import 'package:isar/isar.dart';

part 'captured_photo_model.g.dart';

@collection
class CapturedPhotoModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String path;

  @Index()
  late DateTime timestamp;

  // We only store the ID of the filter preset since the filters are static lists
  String? appliedPresetId;
}

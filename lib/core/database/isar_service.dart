import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:xingcam/features/retro_camera/data/models/captured_photo_model.dart';
import 'package:xingcam/core/models/local_analytics_model.dart';
import 'package:xingcam/features/retro_camera/data/models/recipe_isar_model.dart'; // FIX: Imported missing Recipe schema

@singleton
class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = _openDB();
  }

  Future<Isar> _openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          CapturedPhotoModelSchema,
          LocalAnalyticsModelSchema,
          RecipeIsarModelSchema, // FIX: Registered the recipe schema to prevent collection crash
        ],
        directory: dir.path,
        inspector: kDebugMode,
      );
    }
    return Future.value(Isar.getInstance()!);
  }
}

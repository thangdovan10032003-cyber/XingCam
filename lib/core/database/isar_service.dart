import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:xingcam/features/retro_camera/data/models/captured_photo_model.dart';

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
        ],
        directory: dir.path,
        inspector: kDebugMode,
      );
    }
    return Future.value(Isar.getInstance()!);
  }
}

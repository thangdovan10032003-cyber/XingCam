import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// CacheCleaningService: Automated storage hygiene and self-healing GC.
/// Proactively removes orphaned temporary files left behind by crashes
/// or force-closes, ensuring XingCam never bloats user storage.
class CacheCleaningService {
  
  /// Performs a deep scan of the app's cache and temporary directories.
  /// Removes files with prefix 'XingCam_temp_' older than [staleThreshold].
  static Future<void> performStartupGC({
    Duration staleThreshold = const Duration(hours: 24),
  }) async {
    try {
      final List<Directory> scanDirs = [
        await getTemporaryDirectory(),
        await getApplicationDocumentsDirectory(),
      ];

      int deletedCount = 0;
      final now = DateTime.now();

      for (final dir in scanDirs) {
        if (!dir.existsSync()) continue;

        await for (final file in dir.list(recursive: false, followLinks: false)) {
          if (file is File) {
            final fileName = file.path.split(Platform.pathSeparator).last;
            
            // Only target our specific temp files
            if (fileName.startsWith('XingCam_temp_')) {
              final stat = await file.stat();
              final age = now.difference(stat.modified);

              if (age > staleThreshold) {
                await file.delete();
                deletedCount++;
              }
            }
          }
        }
      }

      if (deletedCount > 0) {
        // debugPrint('XingCam GC: Cleaned $deletedCount orphaned temp files.');
      }
    } catch (e) {
      // debugPrint('XingCam GC Error: $e');
    }
  }
}

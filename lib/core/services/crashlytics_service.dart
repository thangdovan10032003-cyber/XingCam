import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// CrashlyticsService: Centralized anomaly monitoring and local diagnostic logging.
/// 
/// Transitioned to 100% Sovereign (Local-only) for production release.
/// Diagnostic logs are stored locally for user-initiated export.
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  static File? _logFile;

  /// Initializes the monitoring system with a local diagnostic file.
  static Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/xingcam_diagnostic.log');
      
      // Cleanup old logs if they exceed 5MB
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > 5 * 1024 * 1024) {
          await _logFile!.delete();
        }
      }
      
      await _logFile!.writeAsString(
        '--- SESSION START: ${DateTime.now().toIso8601String()} ---\n',
        mode: FileMode.append,
      );
      // Sovereign Logging initialized internally.
    } catch (e) {
      // Sovereign Logging failed internally.
    }
  }

  /// Logs a non-fatal exception to the local diagnostic file.
  static Future<void> logException(dynamic exception, {StackTrace? stackTrace, String? reason}) async {
    final logEntry = '[EXCEPTION] ${DateTime.now().toIso8601String()} | $exception\nREASON: $reason\nSTACK: $stackTrace\n\n';
    // No-op for console in production.
    await _logFile?.writeAsString(logEntry, mode: FileMode.append);
  }

  /// Sets user context (Local only - for diagnostic header).
  static void setUserContext({required String id, String? email}) {
    _logFile?.writeAsStringSync('USER_ID: $id | EMAIL: $email\n', mode: FileMode.append);
  }

  /// Records a custom breadcrumb for session tracking.
  static void addBreadcrumb({required String message, String category = 'ui'}) {
    final entry = '[BREADCRUMB] ${DateTime.now().toIso8601String()} | ($category) $message\n';
    // No-op for console in production.
    _logFile?.writeAsString(entry, mode: FileMode.append);
  }
}

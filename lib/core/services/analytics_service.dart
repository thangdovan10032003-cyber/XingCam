import '../models/local_analytics_model.dart';
import '../database/isar_service.dart';
import 'package:get_it/get_it.dart';

/// AnalyticsService: Measures the creative funnel and AI performance.
/// Essential for optimizing user retention and minimizing churn in 2026.
class AnalyticsService {
  static final _isarService = GetIt.I<IsarService>();

  /// Persists event to local Isar database.
  static void trackEvent(String eventName, {Map<String, String>? properties}) async {
    final db = await _isarService.db;
    await db.writeTxn(() async {
      await db.localAnalyticsModels.put(LocalAnalyticsModel(
        eventName: eventName,
        timestamp: DateTime.now(),
        properties: properties ?? {},
      ));
    });
  }

  /// Specialized tracking for tool latency.
  static void trackLatency(String toolId, Duration duration, bool success) {
    trackEvent('tool_latency', properties: {
      'toolId': toolId,
      'duration_ms': duration.inMilliseconds.toString(),
      'success': success.toString(),
    });
  }

  /// Tracks step-by-step funnel progression.
  static void trackFunnel(String step, String toolId) {
    trackEvent('funnel_step', properties: {
      'step': step,
      'toolId': toolId,
    });
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

enum TaskStatus { pending, running, done, failed }

class AiTask {
  final String id;
  final String toolId;
  final String inputPath;
  final TaskStatus status;
  final String? outputPath;
  final String? error;
  final DateTime createdAt;

  const AiTask({
    required this.id,
    required this.toolId,
    required this.inputPath,
    required this.status,
    required this.createdAt,
    this.outputPath,
    this.error,
  });

  AiTask copyWith({
    TaskStatus? status,
    String? outputPath,
    String? error,
  }) =>
      AiTask(
        id: id,
        toolId: toolId,
        inputPath: inputPath,
        status: status ?? this.status,
        outputPath: outputPath ?? this.outputPath,
        error: error ?? this.error,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'toolId': toolId,
        'inputPath': inputPath,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        if (outputPath != null) 'outputPath': outputPath,
        if (error != null) 'error': error,
      };

  factory AiTask.fromJson(Map<String, dynamic> j) => AiTask(
        id: j['id'] as String,
        toolId: j['toolId'] as String,
        inputPath: j['inputPath'] as String,
        status: TaskStatus.values.byName(j['status'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        outputPath: j['outputPath'] as String?,
        error: j['error'] as String?,
      );
}

// ─── Service ──────────────────────────────────────────────────────────────────

/// BackgroundTaskService — AI job queue for XingCam.
///
/// Enqueues heavy AI operations so the user can dismiss the screen and
/// return later. Sends a local push notification when the job is done.
///
/// Architecture note: On Android this wraps WorkManager via platform channel.
/// On iOS it uses BGTaskScheduler + local notification on completion.
/// For initial release, tasks run in a Dart Isolate (no native plugin needed).
class BackgroundTaskService {
  static const String _prefsKey = 'xingcam_ai_queue_v1';
  static final FlutterLocalNotificationsPlugin _notifs =
      FlutterLocalNotificationsPlugin();
  static bool _notifsReady = false;

  // ─── Initialization ───────────────────────────────────────────────────────────

  /// Call once in main() before runApp().
  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );
    await _notifs.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );
    _notifsReady = true;
    // Resume any interrupted tasks on app restart
    _resumeInterruptedTasks();
  }

  // ─── Enqueue ──────────────────────────────────────────────────────────────────

  /// Adds an AI task to the queue and starts processing immediately in background.
  /// Returns the task [id] for tracking.
  static Future<String> enqueueTask({
    required String toolId,
    required String inputPath,
  }) async {
    final task = AiTask(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      toolId: toolId,
      inputPath: inputPath,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
    );
    await _upsert(task);
    _processTask(task); // fire-and-forget
    return task.id;
  }

  // ─── Queue Management ─────────────────────────────────────────────────────────

  static Future<List<AiTask>> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => AiTask.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearCompleted() async {
    final all = await loadQueue();
    final active = all.where((t) =>
        t.status == TaskStatus.pending || t.status == TaskStatus.running).toList();
    await _saveAll(active);
  }

  // ─── Processing ───────────────────────────────────────────────────────────────

  static Future<void> _processTask(AiTask task) async {
    await _upsert(task.copyWith(status: TaskStatus.running));

    try {
      // Processing via compute Isolate — replace with real AI call per toolId
      final outputPath = await compute(_runAiWorker, _AiWorkerInput(
        taskId: task.id,
        toolId: task.toolId,
        inputPath: task.inputPath,
      ));

      final done = task.copyWith(
          status: TaskStatus.done, outputPath: outputPath);
      await _upsert(done);
      await _sendNotification(task.toolId, success: true);
    } catch (e) {
      await _upsert(task.copyWith(status: TaskStatus.failed, error: e.toString()));
      await _sendNotification(task.toolId, success: false);
    }
  }

  /// Isolate-safe worker — performs the actual AI operation.
  static Future<String> _runAiWorker(_AiWorkerInput input) async {
    // TODO: Route to real AI per toolId once models are downloaded.
    // Current: returns input as placeholder (non-blocking, no RAM spike)
    await Future.delayed(const Duration(seconds: 2));
    return input.inputPath;
  }

  static Future<void> _resumeInterruptedTasks() async {
    final queue = await loadQueue();
    for (final task in queue) {
      if (task.status == TaskStatus.running) {
        // Was interrupted — retry
        _processTask(task.copyWith(status: TaskStatus.pending));
      }
    }
  }

  // ─── Notifications ────────────────────────────────────────────────────────────

  static Future<void> _sendNotification(String toolId, {required bool success}) async {
    if (!_notifsReady) return;
    final title = success ? '✨ Kiệt tác của bạn đã sẵn sàng!' : '⚠️ Xử lý AI thất bại';
    final body = success
        ? 'Tính năng $toolId đã xong. Mở XingCam để xem kết quả!'
        : 'Tính năng $toolId gặp lỗi. Nhấn để thử lại.';

    await _notifs.show(
      toolId.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'xingcam_ai_tasks',
          'AI Tasks',
          channelDescription: 'XingCam background AI processing',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  static Future<void> _upsert(AiTask task) async {
    final all = await loadQueue();
    final idx = all.indexWhere((t) => t.id == task.id);
    if (idx >= 0) { all[idx] = task; } else { all.insert(0, task); }
    await _saveAll(all);
  }

  static Future<void> _saveAll(List<AiTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }
}

class _AiWorkerInput {
  final String taskId;
  final String toolId;
  final String inputPath;
  const _AiWorkerInput({
    required this.taskId,
    required this.toolId,
    required this.inputPath,
  });
}

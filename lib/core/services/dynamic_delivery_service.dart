import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'model_registry.dart';

/// Represents the real-time state of a model download.
enum DownloadStatus { idle, queued, downloading, verifying, ready, error }

class DownloadState {
  final AiModel model;
  final DownloadStatus status;
  final double progress;   // 0.0 → 1.0
  final String? error;

  const DownloadState({
    required this.model,
    required this.status,
    this.progress = 0.0,
    this.error,
  });

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
  }) => DownloadState(
    model: model,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    error: error ?? this.error,
  );
}

/// DynamicDeliveryService — Production on-demand AI model downloader.
///
/// Uses real HTTP chunked streaming with:
///   • Progress tracking via Content-Length
///   • Automatic retry (up to 3 times)
///   • Persistent cache in Application Documents Directory
///   • File integrity check (size validation)
class DynamicDeliveryService {
  DynamicDeliveryService._();

  static final Map<AiModel, StreamController<DownloadState>> _controllers = {};
  static const int _maxRetries = 3;

  /// Returns the current download [Stream] for a model.
  /// If already downloaded, emits [DownloadStatus.ready] immediately.
  static Stream<DownloadState> downloadModel(AiModel model) {
    // If there's already an active download for this model, return it
    if (_controllers.containsKey(model)) {
      return _controllers[model]!.stream;
    }

    final ctrl = StreamController<DownloadState>.broadcast();
    _controllers[model] = ctrl;
    _runDownload(model, ctrl);
    return ctrl.stream;
  }

  static Future<void> _runDownload(
    AiModel model,
    StreamController<DownloadState> ctrl,
  ) async {
    final meta = ModelRegistry.catalog[model]!;

    // Check if already cached
    if (await ModelRegistry.isDownloaded(model)) {
      ctrl.add(DownloadState(model: model, status: DownloadStatus.ready, progress: 1.0));
      await ctrl.close();
      _controllers.remove(model);
      return;
    }

    ctrl.add(DownloadState(model: model, status: DownloadStatus.queued));

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        await _attemptDownload(model, meta, ctrl);
        return; // Success — exit retry loop
      } catch (e) {
        if (attempt == _maxRetries) {
          ctrl.add(DownloadState(
            model: model,
            status: DownloadStatus.error,
            error: 'Download failed after $_maxRetries attempts: $e',
          ));
          await ctrl.close();
          _controllers.remove(model);
        } else {
          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
  }

  static Future<void> _attemptDownload(
    AiModel model,
    AiModelMeta meta,
    StreamController<DownloadState> ctrl,
  ) async {
    final destFile = await ModelRegistry.localFile(model);
    final tempFile = File('${destFile.path}.tmp');

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(meta.url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(meta.url));
      }

      final totalBytes = response.contentLength ?? meta.expectedBytes;
      int receivedBytes = 0;

      final sink = tempFile.openWrite();
      ctrl.add(DownloadState(model: model, status: DownloadStatus.downloading, progress: 0.0));

      await response.stream.listen((chunk) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        final progress = (receivedBytes / totalBytes).clamp(0.0, 1.0);
        ctrl.add(DownloadState(model: model, status: DownloadStatus.downloading, progress: progress));
      }).asFuture<void>();

      await sink.flush();
      await sink.close();

      // Integrity check: verify file size is within 5% of expected
      ctrl.add(DownloadState(model: model, status: DownloadStatus.verifying, progress: 0.99));
      final actualSize = await tempFile.length();
      final expectedSize = meta.expectedBytes;
      final deviation = (actualSize - expectedSize).abs() / expectedSize;
      if (deviation > 0.05) {
        await tempFile.delete();
        throw Exception('File size mismatch: expected ~${meta.sizeMb}MB, got ${(actualSize/1e6).toStringAsFixed(1)}MB');
      }

      // Promote temp file to final destination
      await tempFile.rename(destFile.path);

      ctrl.add(DownloadState(model: model, status: DownloadStatus.ready, progress: 1.0));
      await ctrl.close();
      _controllers.remove(model);
    } finally {
      client.close();
      // Clean up temp file if something went wrong
      if (await tempFile.exists()) await tempFile.delete();
    }
  }

  /// Checks if a model is already available locally without downloading.
  static Future<bool> isReady(AiModel model) => ModelRegistry.isDownloaded(model);

  /// Returns the local file path for a model (call after [isReady] returns true).
  static Future<String> getModelPath(AiModel model) async {
    final f = await ModelRegistry.localFile(model);
    return f.path;
  }

  /// Deletes a locally cached model to force re-download.
  static Future<void> evictCache(AiModel model) => ModelRegistry.evict(model);
}

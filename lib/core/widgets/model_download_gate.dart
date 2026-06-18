import 'package:flutter/material.dart';
import '../services/dynamic_delivery_service.dart';
import '../services/model_registry.dart';
import '../theme/design_tokens.dart';

/// A widget that gates any AI-powered screen behind a model download check.
///
/// Usage:
/// ```dart
/// ModelDownloadGate(
///   model: AiModel.segmentation,
///   child: SegmentationScreen(),
/// )
/// ```
///
/// Shows a download prompt if the model is not yet available locally.
/// Once downloaded (or already available), renders [child] directly.
class ModelDownloadGate extends StatefulWidget {
  final AiModel model;
  final Widget child;
  final String? featureName;

  const ModelDownloadGate({
    super.key,
    required this.model,
    required this.child,
    this.featureName,
  });

  @override
  State<ModelDownloadGate> createState() => _ModelDownloadGateState();
}

class _ModelDownloadGateState extends State<ModelDownloadGate> {
  late Future<bool> _alreadyReady;

  @override
  void initState() {
    super.initState();
    _alreadyReady = DynamicDeliveryService.isReady(widget.model);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _alreadyReady,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _LoadingScaffold();
        }
        if (snapshot.data == true) {
          return widget.child;
        }
        return _DownloadPrompt(
          model: widget.model,
          featureName: widget.featureName,
          onReady: () => setState(() {
            _alreadyReady = Future.value(true);
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal: Download prompt + progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadPrompt extends StatefulWidget {
  final AiModel model;
  final String? featureName;
  final VoidCallback onReady;

  const _DownloadPrompt({
    required this.model,
    required this.featureName,
    required this.onReady,
  });

  @override
  State<_DownloadPrompt> createState() => _DownloadPromptState();
}

class _DownloadPromptState extends State<_DownloadPrompt> {
  Stream<DownloadState>? _stream;
  DownloadState? _latest;
  bool _started = false;

  void _startDownload() {
    setState(() {
      _started = true;
      _stream = DynamicDeliveryService.downloadModel(widget.model);
    });
    _stream!.listen((state) {
      if (!mounted) return;
      setState(() => _latest = state);
      if (state.status == DownloadStatus.ready) {
        widget.onReady();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = ModelRegistry.catalog[widget.model]!;
    final name = widget.featureName ?? 'Tính năng AI';
    final state = _latest;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download_rounded, size: 40, color: AppColors.accent),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                '$name cần tải AI Model',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Model AI (~${meta.sizeMb.toStringAsFixed(0)} MB) sẽ được tải '
                'một lần và lưu trên máy của bạn. Ảnh của bạn không bao giờ '
                'rời khỏi thiết bị.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Progress area
              if (_started && state != null) ...[
                _buildProgressBar(state),
                const SizedBox(height: 16),
                Text(
                  _statusLabel(state),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _startDownload,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(
                      'Tải xuống (${meta.sizeMb.toStringAsFixed(0)} MB)',
                      style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],

              if (state?.status == DownloadStatus.error) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _started = false;
                    _latest = null;
                  }),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
                  label: const Text('Thử lại', style: TextStyle(color: AppColors.accent, fontFamily: 'Outfit')),
                ),
                const SizedBox(height: 8),
                Text(
                  state?.error ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontFamily: 'Outfit'),
                ),
              ],

              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Quay lại', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Outfit')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(DownloadState state) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: state.status == DownloadStatus.queued ? null : state.progress,
            minHeight: 8,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(state.progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  String _statusLabel(DownloadState state) {
    switch (state.status) {
      case DownloadStatus.queued:       return 'Đang chuẩn bị tải…';
      case DownloadStatus.downloading:  return 'Đang tải model AI…';
      case DownloadStatus.verifying:    return 'Đang xác minh tính toàn vẹn…';
      case DownloadStatus.ready:        return '✓ Sẵn sàng!';
      case DownloadStatus.error:        return 'Đã xảy ra lỗi.';
      case DownloadStatus.idle:         return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal: Minimal loading scaffold while checking local cache
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }
}

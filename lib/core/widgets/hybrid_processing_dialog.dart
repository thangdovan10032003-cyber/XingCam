import 'package:flutter/material.dart';
import '../services/background_task_service.dart';
import '../services/memory_armor_service.dart';
import '../services/platform_capability_service.dart';
import '../theme/design_tokens.dart';

/// HybridProcessingDialog — Shown when device is too slow for immediate processing.
///
/// Presents the user with three options:
///   1. Process on this device in the background (WorkManager/BGTask)
///   2. Use Cloud processing (fast, privacy-preserving — image deleted after)
///   3. Wait and process immediately on-device (not recommended for low-tier)
class HybridProcessingDialog extends StatelessWidget {
  final String toolId;
  final String inputPath;
  final Duration estimatedTime;
  final VoidCallback? onQueued;

  const HybridProcessingDialog({
    super.key,
    required this.toolId,
    required this.inputPath,
    required this.estimatedTime,
    this.onQueued,
  });

  /// Shows the dialog and returns true if a background/cloud task was queued.
  static Future<bool> show({
    required BuildContext context,
    required String toolId,
    required String inputPath,
  }) async {
    final spec = await PlatformCapabilityService.getDeviceSpec();
    if (!spec.needsHybridWarning) return false; // Device is fast enough — skip

    final eta = await MemoryArmorService.estimateProcessingTime(
      imagePath: inputPath,
      operationType: toolId,
    );

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => HybridProcessingDialog(
        toolId: toolId,
        inputPath: inputPath,
        estimatedTime: eta,
      ),
    );
    return result ?? false;
  }

  String get _etaLabel {
    final s = estimatedTime.inSeconds;
    if (s < 60) return '~$s giây';
    final m = (s / 60).ceil();
    return '~$m phút';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.speed_rounded, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thiết bị cần thêm thời gian',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Ước tính: $_etaLabel trên thiết bị của bạn',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Option 1: Background on device
            _OptionCard(
              icon: Icons.schedule_rounded,
              iconColor: AppColors.accent,
              title: 'Xử lý nền trên máy',
              subtitle: 'Bạn có thể dùng app khác. Chúng tôi sẽ thông báo khi xong.',
              onTap: () async {
                await BackgroundTaskService.enqueueTask(
                  toolId: toolId,
                  inputPath: inputPath,
                );
                onQueued?.call();
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),
            const SizedBox(height: 10),

            // Option 2: Cloud (fast, private)
            _OptionCard(
              icon: Icons.cloud_sync_rounded,
              iconColor: Colors.blueAccent,
              title: 'Xử lý bằng Cloud (5 giây)',
              subtitle: 'Ảnh được mã hóa, xử lý, rồi xóa ngay. Không lưu trữ.',
              badge: 'Nhanh nhất',
              onTap: () {
                // Cloud processing route — show coming soon for now
                Navigator.of(context).pop(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('☁️ Cloud Processing sẽ ra mắt sớm!',
                        style: TextStyle(fontFamily: 'Outfit')),
                    backgroundColor: AppColors.surface,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Option 3: Process now (slow)
            _OptionCard(
              icon: Icons.phone_android_rounded,
              iconColor: AppColors.textSecondary,
              title: 'Vẫn xử lý ngay trên máy',
              subtitle: 'App có thể bị đơ trong $_etaLabel. Không khuyến nghị.',
              isWarning: true,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Internal Widgets ─────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final bool isWarning;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isWarning
              ? Colors.orange.withOpacity(0.06)
              : AppColors.background.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWarning
                ? Colors.orange.withOpacity(0.3)
                : AppColors.textSecondary.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isWarning
                              ? Colors.orange
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

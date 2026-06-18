import 'dart:io';
import 'package:flutter/material.dart';
import '../services/background_task_service.dart';
import '../theme/design_tokens.dart';

/// A sleek mini-widget for the Home Screen that displays ongoing AI task progress.
class ActiveTaskMiniWidget extends StatelessWidget {
  final AiTask task;
  final VoidCallback onTap;

  const ActiveTaskMiniWidget({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Preview or Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: task.inputPath.isNotEmpty && File(task.inputPath).existsSync()
                    ? DecorationImage(
                        image: FileImage(File(task.inputPath)),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.background,
              ),
              child: task.inputPath.isEmpty || !File(task.inputPath).existsSync()
                  ? const Icon(Icons.auto_awesome, color: AppColors.accent)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đang xử lý ${task.toolId}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: AppColors.background,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

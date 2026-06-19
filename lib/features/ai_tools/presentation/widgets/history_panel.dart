import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:flutter/material.dart';
import 'package:xingcam/core/models/edit_command.dart';
import 'package:xingcam/core/services/pipeline_context.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:easy_localization/easy_localization.dart';

/// HistoryPanel: A visual "Layer" management system for NDE commands.
/// Replaces the simple 'Undo' with a granular, interactive history stack.
class HistoryPanel extends StatelessWidget {
  final PipelineContext context;

  const HistoryPanel({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: this.context,
      builder: (context, _) {
        final commands = this.context.editCommands.reversed.toList();

        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  context.tr('tools.history.title'),
                  style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              Expanded(
                child: commands.isEmpty
                    ? Center(child: Text(context.tr('tools.history.empty'), style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.3))))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: commands.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final cmd = commands[index];
                          return GestureDetector(
                            onLongPressStart: (_) => this.context.peekState(cmd.id),
                            onLongPressEnd: (_) => this.context.resetPeek(),
                            child: _HistoryTile(
                              command: cmd,
                              onDelete: () => this.context.removeCommand(cmd.id),
                              onRestoreTo: () {
                                // Time-Machine Restore (Phase 200)
                                // Remove all commands after this index
                                final allIds = this.context.editCommands.map((c) => c.id).toList();
                                final thisIdx = allIds.indexOf(cmd.id);
                                final toRemove = allIds.sublist(thisIdx + 1);
                                for (final id in toRemove) {
                                  this.context.removeCommand(id);
                                }
                                HapticsUtility.heavyImpact();
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final EditCommand command;
  final VoidCallback onDelete;
  final VoidCallback onRestoreTo;

  const _HistoryTile({required this.command, required this.onDelete, required this.onRestoreTo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(_getIcon(command.type), color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getNaturalName(command.type, context),
                  style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getNaturalParams(command.type, command.params, context),
                  style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(AppIcons.delete, color: AppColors.error, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          // Time-Machine Restore (Phase 200)
          GestureDetector(
            onTap: onRestoreTo,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('â†©', style: TextStyle(color: AppColors.accent, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(EditType type) {
    switch (type) {
      case EditType.lut: return AppIcons.paletteOutlined;
      case EditType.grain: return AppIcons.texture;
      case EditType.beauty: return AppIcons.faceRetouch;
      case EditType.blur: return AppIcons.blur;
      case EditType.border: return AppIcons.borderAll;
      case EditType.crop: return AppIcons.crop;
      case EditType.transform: return AppIcons.transform;
      case EditType.lightLeak: return AppIcons.light;
    }
  }

  String _getNaturalName(EditType type, BuildContext context) {
    switch (type) {
      case EditType.lut: return 'Color Mood';
      case EditType.grain: return 'Texture';
      case EditType.beauty: return 'Luminous Skin';
      case EditType.blur: return 'Lens Depth';
      case EditType.border: return 'Artistic Frame';
      case EditType.crop: return 'Composition';
      case EditType.transform: return 'Geometry';
      case EditType.lightLeak: return 'Vintage Glow';
    }
  }

  String _getNaturalParams(EditType type, Map<String, dynamic> params, BuildContext context) {
    final amount = params['amount'] ?? 0.5;
    if (amount < 0.3) return 'Subtle refinement';
    if (amount > 0.7) return 'Pronounced character';
    return 'Balanced harmony';
  }
}


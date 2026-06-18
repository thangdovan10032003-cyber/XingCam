import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:go_router/go_router.dart';

/// AppHeader: A standardized, professional app bar for AI tools.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Outfit',
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: AppColors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: onBack ?? () => context.pop(),
        icon: const Icon(AppIcons.back, size: 20),
        color: AppColors.textPrimary,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

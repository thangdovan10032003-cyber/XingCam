import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:xingcam/core/services/memory_armor_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(AppIcons.back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            context.tr('settings.title'),
            style: const TextStyle(fontFamily: 'Outfit', 
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionHeader(context.tr('settings.sections.general')),
            _SettingsTile(
              icon: AppIcons.quality,
              title: context.tr('settings.export_quality.title'),
              subtitle: context.tr('settings.export_quality.high'),
              onTap: () => _showQualityDialog(context),
            ),
            const SizedBox(height: 24),
            _SectionHeader(context.tr('settings.sections.legal')),
            _SettingsTile(
              icon: AppIcons.privacy,
              title: context.tr('settings.privacy'),
              subtitle: context.tr('settings.privacy_desc'),
              onTap: () => context.push('/privacy-policy'),
            ),
            _SettingsTile(
              icon: AppIcons.terms,
              title: context.tr('settings.terms'),
              subtitle: context.tr('settings.terms_desc'),
              onTap: () => context.push('/privacy-policy'),
            ),
            const SizedBox(height: 24),
            _SectionHeader(context.tr('settings.sections.data')),
            _SettingsTile(
              icon: AppIcons.sweep,
              title: context.tr('settings.clear.title'),
              subtitle: context.tr('settings.clear.subtitle'),
              iconColor: AppColors.primary,
              onTap: () => _showClearDialog(context),
            ),
            const SizedBox(height: 16),
            _buildStorageShield(context),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Text(
                    'XINGCAM',
                    style: TextStyle(fontFamily: 'Outfit', 
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr('settings.version')} 1.0.0',
                    style: const TextStyle(fontFamily: 'Outfit', 
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageShield(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.quality, color: AppColors.primary, size: 18),
              const SizedBox(width: 12),
              Text(context.tr('settings.storage_shield.title').toUpperCase(), 
                style: const TextStyle(fontFamily: 'Outfit', color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.75, // Simulated 75% protected
              backgroundColor: AppColors.background,
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(context.tr('settings.storage_shield.desc'), 
            style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  void _showQualityDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('settings.export_quality.title'),
                style: const TextStyle(fontFamily: 'Outfit', 
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...[
              context.tr('settings.export_quality.high'),
              context.tr('settings.export_quality.medium'),
              context.tr('settings.export_quality.standard')
            ].map(
              (label) => ListTile(
                title: Text(label,
                    style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.tr('settings.clear.title'),
            style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary)),
        content: Text(
          context.tr('settings.clear.confirm'),
          style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel'),
                style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await MemoryArmorService.clearTemporaryFiles();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('settings.clear.done'))),
                );
              }
            },
            child: Text(context.tr('settings.clear.action'),
                style: const TextStyle(fontFamily: 'Outfit', color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontFamily: 'Outfit', 
          color: AppColors.textSecondary.withValues(alpha: 0.4),
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.textPrimary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontFamily: 'Outfit', 
                color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
        trailing:
            const Icon(AppIcons.chevron, color: AppColors.surfaceLight),
        onTap: onTap,
      ),
    );
  }
}

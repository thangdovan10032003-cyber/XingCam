import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surfaceDeep,
        appBar: AppBar(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(AppIcons.back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            context.tr('settings.privacy'),
            style: TextStyle(fontFamily: 'Outfit', 
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '${context.tr('privacy.last_updated')}: June 2026',
              style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            _PolicySection(
              title: context.tr('privacy.sections.design.title'),
              body: context.tr('privacy.sections.design.body'),
            ),
            _PolicySection(
              title: context.tr('privacy.sections.storage.title'),
              body: context.tr('privacy.sections.storage.body'),
            ),
            _PolicySection(
              title: context.tr('privacy.sections.ai.title'),
              body: context.tr('privacy.sections.ai.body'),
            ),
            _PolicySection(
              title: context.tr('privacy.sections.permissions.title'),
              body: context.tr('privacy.sections.permissions.body'),
            ),
            _PolicySection(
              title: context.tr('privacy.sections.analytics.title'),
              body: context.tr('privacy.sections.analytics.body'),
            ),
            _PolicySection(
              title: context.tr('privacy.sections.contact.title'),
              body: context.tr('privacy.sections.contact.body'),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'Outfit', 
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(fontFamily: 'Outfit', 
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

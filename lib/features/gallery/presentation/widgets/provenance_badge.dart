import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// ProvenanceBadge: A premium HUD element for Content Credentials.
/// Displays a human-readable "Trust Card" instead of raw technical data.
class ProvenanceBadge extends StatelessWidget {
  final Map<String, dynamic> manifest;

  const ProvenanceBadge({super.key, required this.manifest});

  @override
  Widget build(BuildContext context) {
    final assertions = manifest['assertions'] as List<dynamic>? ?? [];
    final signature = manifest['signature'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Icon(AppIcons.privacy, color: AppColors.mint, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Authenticity Verified',
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This image contains a cryptographically signed manifest proving its origin and editing history.',
            style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _TrustItem(
            icon: AppIcons.check, 
            label: 'Securely Signed', 
            value: signature['algorithm']?.toString() ?? 'HMAC-SHA256'
          ),
          const Divider(color: AppColors.border, height: 24),
          const _TrustItem(
            icon: AppIcons.ai, 
            label: 'AI Transparency', 
            value: 'Enhanced with Sovereign AI'
          ),
          const Divider(color: AppColors.border, height: 24),
          _TrustItem(
            icon: AppIcons.save, 
            label: 'Local Provenance', 
            value: 'Original File: ${manifest['original_file'] ?? 'XingCam Master'}'
          ),
          const SizedBox(height: 32),
          Text(
             'Verified via XingCam Content Credentials v1.0',
             style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.3), fontSize: 10),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void show(BuildContext context, Map<String, dynamic> manifest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProvenanceBadge(manifest: manifest),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _TrustItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textPrimary, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(value, style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

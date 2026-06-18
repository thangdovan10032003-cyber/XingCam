import 'package:xingcam/core/utils/haptics_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xingcam/core/services/ai_credit_service.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// AiCreditStore: A premium monetization interface for purchasing AI credits.
/// Designed to feel like a high-end digital agency store.
class AiCreditStore extends StatelessWidget {
  const AiCreditStore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text('THE SOVEREIGN VAULT', style: TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
          const SizedBox(height: 32),
          _buildPack(context, 'Starter Pack', '50 Credits', '\$4.99', AppColors.primary),
          const SizedBox(height: 16),
          _buildPack(context, 'Pro Vault', '250 Credits', '\$19.99', AppColors.accent, isBestValue: true),
          const SizedBox(height: 16),
          _buildPack(context, 'Sovereign Infinity', 'âˆž Credits (1yr)', '\$99.99', AppColors.gold),
          const SizedBox(height: 32),
          Text('All transactions secured by device sovereignty.', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPack(BuildContext context, String name, String amount, String price, Color color, {bool isBestValue = false}) {
    return GestureDetector(
      onTap: () {
        HapticsUtility.dialClick();
        Future.delayed(const Duration(milliseconds: 300), () => HapticsUtility.leverWind());
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isBestValue ? AppColors.gold : AppColors.border, width: isBestValue ? 2 : 1),
          boxShadow: isBestValue ? [BoxShadow(color: AppColors.gold.withOpacity(0.1), blurRadius: 20)] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(AppIcons.ai, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(amount, style: TextStyle(fontFamily: 'Outfit', color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(price, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}




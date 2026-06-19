import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:provider/provider.dart';
import 'package:xingcam/core/services/ai_credit_service.dart';

/// AiCreditBadge: A premium glowing HUD element showing the current credit balance.
/// Serves as a constant reminder of the app's generative power.
class AiCreditBadge extends StatelessWidget {
  const AiCreditBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AiCreditService>(
      builder: (context, creditService, _) {
        return GestureDetector(
          onTap: () {}, // AiCreditStore.show(context) not implemented yet
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.ai, color: AppColors.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                  context.tr('monetization.remaining_credits', args: [getRemainingCredits(creditService)]),
                  style: const TextStyle(fontFamily: 'Outfit', 
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(AppIcons.add, color: AppColors.textSecondary, size: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  String getRemainingCredits(AiCreditService service) {
    return service.currentCredits.toString();
  }
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_credit_service.dart';
import '../theme/design_tokens.dart';

class SubscriptionPaywallWidget extends StatelessWidget {
  final VoidCallback onPremiumStarted;

  const SubscriptionPaywallWidget({
    super.key,
    required this.onPremiumStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gold.withOpacity(0.1),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium Crown / Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.15),
              boxShadow: [
                BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 64),
          ),
          const SizedBox(height: 32),

          // Content
          const Text(
            'XINGCAM PRO',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
              fontSize: 28,
              letterSpacing: 4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mở khóa toàn bộ mô hình AI Sovereign\nvà xử lý 4K không giới hạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          // Features
          _buildFeature('Xử lý ảnh 4K High-Res Isolates'),
          _buildFeature('500 Credits hàng tháng'),
          _buildFeature('Không quảng cáo, 100% Offline-Mode'),
          _buildFeature('Ưu tiên tính năng AI mới nhất'),

          const SizedBox(height: 48),

          // Price Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: const Column(
              children: [
                Text('3 NGÀY DÙNG THỬ MIỄN PHÍ', 
                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.gold, fontSize: 12)),
                SizedBox(height: 4),
                Text('Sau đó 199.000đ / năm', 
                  style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 40),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }
}

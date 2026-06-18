import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// SubscriptionPaywallWidget — v1.5 Premium Monetization Interface.
/// Features Glassmorphism design and App Store compliance.
class SubscriptionPaywallWidget extends StatelessWidget {
  const SubscriptionPaywallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient/Image
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Colors.black],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildFeatureComparison(),
                        const SizedBox(height: 40),
                        _buildPricingOptions(),
                        const SizedBox(height: 32),
                        _buildComplianceLinks(),
                      ],
                    ),
                  ),
                ),
                _buildFooterButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white60),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () { /* Restore logic */ },
            child: Text(
              'KHÔI PHỤC GÓI MUA',
              style: TextStyle(fontFamily: 'Outfit', color: AppColors.gold.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Text('XINGCAM PRO', style: TextStyle(fontFamily: 'Outfit', color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 24),
              _FeatureRow(label: 'Tất cả 120+ Công thức màu', isPro: true),
              _FeatureRow(label: 'Xử lý Video 4K & Cinematic', isPro: true),
              _FeatureRow(label: 'Hút công thức từ ảnh (Stealth)', isPro: true),
              _FeatureRow(label: 'Sovereign Audit (100% Offline)', isPro: true),
              _FeatureRow(label: 'Không giới hạn AI Credits', isPro: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingOptions() {
    return Column(
      children: [
        _buildPlanCard(
          title: 'HÀNG NĂM (TIẾT KIỆM 50%)',
          price: '899.000đ / năm',
          subtitle: 'Dùng thử miễn phí 3 ngày',
          isPopular: true,
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          title: 'HÀNG TUẦN',
          price: '49.000đ / tuần',
          subtitle: 'Gia hạn mỗi tuần',
        ),
        const SizedBox(height: 12),
        _buildPlanCard(
          title: 'VĨNH VIỄN (LIFETIME)',
          price: '1.999.000đ',
          subtitle: 'Mua một lần, dùng mãi mãi',
        ),
      ],
    );
  }

  Widget _buildPlanCard({required String title, required String price, String? subtitle, bool isPopular = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular ? AppColors.gold.withOpacity(0.1) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPopular ? AppColors.gold : Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isPopular ? AppColors.gold : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          if (isPopular) const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
        ],
      ),
    );
  }

  Widget _buildComplianceLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LinkText('Điều khoản sử dụng (EULA)'),
            const Text(' • ', style: TextStyle(color: Colors.white24)),
            _LinkText('Quyền riêng tư'),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Hủy bất cứ lúc nào trong cài đặt App Store. Đăng ký tự động gia hạn.',
          style: TextStyle(color: Colors.white24, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: const Center(
          child: Text('BẮT ĐẦU DÙNG THỬ MIỄN PHÍ', style: TextStyle(fontFamily: 'Outfit', color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final bool isPro;
  const _FeatureRow({required this.label, required this.isPro});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(isPro ? Icons.check_circle : Icons.remove_circle, color: isPro ? AppColors.gold : Colors.white24, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  final String text;
  const _LinkText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white38, fontSize: 11, decoration: TextDecoration.underline));
  }
}

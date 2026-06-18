import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

class CreativeWrappedScreen extends StatelessWidget {
  const CreativeWrappedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('BÁO CÁO SÁNG TẠO', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Icon(Icons.auto_awesome_mosaic_rounded, color: AppColors.gold, size: 80),
            ),
            const SizedBox(height: 32),
            const Text(
              'SOVEREIGN INSIGHTS',
              style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tuần vừa qua bạn đã hoàn thành 42 tác vụ AI\nvới tổng thời gian sáng tạo 4.5 giờ.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 48),
            _buildStatCard('Tool được yêu thích nhất', 'Retro Camera (32 lần)'),
            const SizedBox(height: 16),
            _buildStatCard('Recipe bạn tin dùng nhất', 'VINTAGE_WARM_01'),
            const Spacer(),
            const Text(
              'Dữ liệu này hoàn toàn nằm trên máy bạn.\nKhông ai khác có thể truy cập.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textPrimary.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.gold)),
        ],
      ),
    );
  }
}

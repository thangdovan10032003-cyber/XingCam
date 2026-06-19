import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

class SovereignAuditScreen extends StatelessWidget {
  const SovereignAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SOVEREIGN AUDIT', 
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shield Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.1),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.gold, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text('THIẾT BỊ LÀ PHÒNG LAB CỦA BẠN', 
                    style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildAuditSection('TIẾN TRÌNH AI', [
              _AuditItem('Denoising Engine', 'LOCAL ISOLATE #1', true),
              _AuditItem('Aesthetic Scorer', 'LOCAL TFLITE', true),
              _AuditItem('Memory Armor (4K)', 'LOCAL ENCRYPTED', true),
            ]),

            const SizedBox(height: 32),

            _buildAuditSection('DỮ LIỆU ĐANG LƯU TRỮ', [
              _AuditItem('Film Recipes', 'ISAR DATABASE (OFFLINE)', true),
              _AuditItem('Usage Analytics', 'ISAR DATABASE (OFFLINE)', true),
              _AuditItem('Captured Photos', 'INTERNAL APP STORAGE', true),
            ]),

            const SizedBox(height: 48),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                   Icon(Icons.verified_user_outlined, color: AppColors.gold),
                   SizedBox(width: 16),
                   Expanded(
                     child: Text(
                       'XingCam không bao giờ gửi ảnh lên server. 100% mã nguồn AI chạy cục bộ.',
                       style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditSection(String title, List<_AuditItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.gold),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(item.location, style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),
            ],
          ),
        )),
      ],
    );
  }
}

class _AuditItem {
  final String name;
  final String location;
  final bool isLocal;
  _AuditItem(this.name, this.location, this.isLocal);
}

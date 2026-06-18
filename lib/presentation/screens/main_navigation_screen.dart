import 'package:flutter/material.dart';
import 'package:xingcam/core/theme/design_tokens.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:xingcam/presentation/screens/home_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/ai_home_screen.dart';
import 'package:xingcam/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:xingcam/presentation/screens/settings_screen.dart';
import 'package:xingcam/features/retro_camera/presentation/screens/camera_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const AiHomeScreen(),
    const CameraScreen(), // Direct camera access
    const GalleryScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border.withOpacity(0.5), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary.withOpacity(0.5),
          selectedLabelStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 10),
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppIcons.home),
              activeIcon: Icon(AppIcons.home),
              label: 'home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.ai),
              activeIcon: const Icon(AppIcons.ai),
              label: 'ai_tools'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const _CenterAddIcon(),
              label: 'camera'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.gallery),
              activeIcon: const Icon(AppIcons.gallery),
              label: 'gallery'.tr(),
            ),
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.settings),
              activeIcon: const Icon(AppIcons.settings),
              label: 'settings'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAddIcon extends StatelessWidget {
  const _CenterAddIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(AppIcons.camera, color: AppColors.textPrimary, size: 24),
    );
  }
}

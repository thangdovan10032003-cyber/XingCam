import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:xingcam/presentation/screens/onboarding_screen.dart';
import 'package:xingcam/presentation/screens/settings_screen.dart';
import 'package:xingcam/presentation/screens/privacy_policy_screen.dart';
import 'package:xingcam/presentation/screens/main_navigation_screen.dart';
import 'package:xingcam/features/retro_camera/presentation/screens/camera_screen.dart';
import 'package:xingcam/features/retro_camera/presentation/screens/preview_screen.dart';
import 'package:xingcam/features/retro_camera/presentation/screens/recipe_library_screen.dart';
import 'package:xingcam/features/retro_camera/presentation/screens/video_recorder_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/ai_home_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/object_remover_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/skin_beautifier_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/sky_replacement_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/relighting_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/gobo_lighting_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/style_mimic_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/portrait_sculptor_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/zine_editor_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/wardrobe_sync_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/memory_revive_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/collection_harmonizer_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/makeup_studio_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/bg_replace_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/style_art_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/hair_colorist_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/story_templates_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/spot_remover_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/teeth_whitening_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/eye_bag_remover_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/skin_tone_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/body_sculpt_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/collage_editor_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/text_studio_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/smart_crop_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/face_swap_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/ai_outfit_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/ar_stickers_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/eyewear_tryon_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/magic_brush_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/mosaic_blur_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/artistic_borders_screen.dart';
import 'package:xingcam/features/ai_tools/presentation/screens/magic_eraser_screen.dart';
import 'package:xingcam/features/gallery/presentation/screens/gallery_screen.dart';
import 'package:xingcam/features/gallery/presentation/screens/batch_edit_screen.dart';
import 'package:xingcam/features/gallery/presentation/screens/ar_projector_screen.dart';
import 'package:xingcam/features/gallery/presentation/screens/photo_detail_screen.dart';
import 'package:xingcam/core/widgets/biometric_guard.dart';

final appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (_, __) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/camera',
      builder: (_, __) => const CameraScreen(),
    ),
    GoRoute(
      path: '/preview',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return PreviewScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/recipes',
      builder: (_, __) => const RecipeLibraryScreen(),
    ),
    GoRoute(
      path: '/video-recorder',
      builder: (_, __) => const VideoRecorderScreen(),
    ),
    GoRoute(
      path: '/gallery',
      builder: (_, __) => const GalleryScreen(),
    ),
    GoRoute(
      path: '/batch-edit',
      builder: (_, state) {
        final paths = state.extra as List<String>? ?? [];
        return BatchEditScreen(imagePaths: paths);
      },
    ),
    GoRoute(
      path: '/ar-projector',
      builder: (_, state) {
        final paths = state.extra as List<String>? ?? [];
        return ArProjectorScreen(imagePaths: paths);
      },
    ),
    GoRoute(
      path: '/photo-detail',
      builder: (_, state) {
        final imagePath = state.extra as String? ?? '';
        return PhotoDetailScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/ai-tools',
      builder: (_, __) => const AiHomeScreen(),
    ),
    GoRoute(
      path: '/remove-object',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return ObjectRemoverScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/skin-beautifier',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: SkinBeautifierScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/sky-replacement',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: SkyReplacementScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/relighting',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return RelightingScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/gobo-lighting',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return GoboLightingScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/style-mimic',
      builder: (_, __) => const StyleMimicScreen(),
    ),
    GoRoute(
      path: '/portrait-sculptor',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: PortraitSculptorScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/zine-editor',
      builder: (_, __) => const ZineEditorScreen(),
    ),
    GoRoute(
      path: '/wardrobe-sync',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return WardrobeSyncScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/memory-revive',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return MemoryReviveScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/collection-harmonizer',
      builder: (_, __) => const CollectionHarmonizerScreen(),
    ),
    GoRoute(
      path: '/makeup-studio',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: MakeupStudioScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/bg-replace',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: BgReplaceScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/style-art',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return StyleArtScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/hair-colorist',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return HairColoristScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/story-templates',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return StoryTemplatesScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/spot-remover',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return SpotRemoverScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/retouch-hub',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        // Unified Hub consolidates Spot, Teeth, Eye-bag, and Tone
        return BiometricGuard(child: TeethWhiteningScreen(imagePath: imagePath)); // Placeholder for unified logic (Phase 198)
      },
    ),
    GoRoute(
      path: '/eye-bag-remover',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: EyeBagRemoverScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/skin-tone',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: SkinToneScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/body-sculpt',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: BodySculptScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/collage-editor',
      builder: (_, __) => const CollageEditorScreen(),
    ),
    GoRoute(
      path: '/text-studio',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return TextStudioScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/smart-crop',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return SmartCropScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/face-swap',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: FaceSwapScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/ai-outfit',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return AiOutfitScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/ar-stickers',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: ArStickersScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/eyewear-tryon',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return BiometricGuard(child: EyewearTryonScreen(imagePath: imagePath));
      },
    ),
    GoRoute(
      path: '/magic-brush',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return MagicBrushScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/mosaic-blur',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return MosaicBlurScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/artistic-borders',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return ArtisticBordersScreen(imagePath: imagePath);
      },
    ),
    GoRoute(
      path: '/magic-eraser',
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final imagePath = extra['imagePath'] as String? ?? '';
        return MagicEraserScreen(imagePath: imagePath);
      },
    ),
  ],
);

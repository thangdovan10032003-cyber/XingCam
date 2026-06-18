import 'package:flutter/material.dart';

/// AppColors: The definitive color palette for an elite photography studio.
/// Focuses on color neutrality to ensure photo edits remain unbiased.
class AppColors {
  // Ultra-Premium Core Palette
  static const Color background = Color(0xFF000000); // True OLED Black
  static const Color surfaceDeep = Color(0xFF09090B); // Vantablack Navy
  static const Color surface = Color(0xFF111111);    // Soft OLED Gray
  static const Color primary = Color(0xFFE94560);    // Cinematic Rose
  static const Color accent = Color(0xFF00E5FF);     // Electric Cyan
  static const Color error = Color(0xFFFF3B30);      // iOS Native Red

  // Gradient palette tokens
  static const Color gradientPurple    = Color(0xFF6B21A8); // Onboarding slide 2
  static const Color gradientDeep      = Color(0xFF0F3460); // Deep navy
  static const Color gradientSlateBlue = Color(0xFF1E3A5F); // AI tool card trail

  // Semantic Tool Tokens
  static const Color paper        = Color(0xFFF2F0ED); // Zine Editor soft tone
  static const Color wardrobe     = Color(0xFFC33764); // Wardrobe Sync accent
  static const Color gold        = Color(0xFFFFD700); // Teeth Whitening/Lux accent
  static const Color mint        = Color(0xFF32D74B); // Spot Remover/Skin accent
  static const Color card        = Color(0xFF1C1C1E); // Apple true dark card

  static const Color skyBlue     = Color(0xFF60A5FA); // Sky Replacement base
  static const Color sunflower   = Color(0xFFFBBF24); // Relighting base
  static const Color lavender    = Color(0xFFA78BFA); // Gobo base
  static const Color blossom     = Color(0xFFF472B6); // Sculptor base

  static const Color surfaceLow  = Color(0xFF121212); // Secondary dark surface
  static const Color surfaceLight = Color(0xFF30363D); // Secondary light surface
  static const Color transparent = Color(0x00000000);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color secondary   = Color(0xFFE94560); // Cinematic Rose alias

  static const Color skinPorcelain = Color(0xFFF5E6D3);
  static const Color skinDewy = Color(0xFFFFCFC9);
  static const Color skinBronze = Color(0xFFC68642);
  static const Color skinGolden = Color(0xFFD4A562);
  static const Color skinMatte = Color(0xFFEAD5C0);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color border = Color(0xFF30363D);
  static const Color paperLight = Color(0xFFFAF9F6); // Lighter paper variant
  
  // Specific Tool Accent Variants (Purified)
  static const Color outfitBusiness = Color(0xFF607D8B); // BlueGrey
  static const Color outfitStreet   = Color(0xFFFF9800); // Orange
  static const Color outfitVintage  = Color(0xFF795548); // Brown
  static const Color outfitSummer   = Color(0xFFFFEB3B); // Yellow
  static const Color outfitCyber    = Color(0xFF9C27B0); // Purple
  
  static const Color backgroundDark = Color(0xFF09090B); // Darker background
}

/// AppIcons: Centralized icon tokens for architectural sensory purity.
class AppIcons {
  static const IconData camera = Icons.photo_camera_rounded;
  static const IconData gallery = Icons.photo_library_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData back = Icons.arrow_back_ios_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData ai = Icons.auto_awesome_rounded;
  static const IconData filter = Icons.filter_hdr_rounded;
  static const IconData adjust = Icons.tune_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData style = Icons.style_rounded;
  static const IconData library = Icons.auto_awesome_motion_outlined;
  static const IconData pin = Icons.push_pin_outlined;
  static const IconData save = Icons.download_rounded;
  static const IconData beautify = Icons.face_retouching_natural_outlined;
  static const IconData sky = Icons.cloud_outlined;
  static const IconData light = Icons.light_mode_outlined;
  static const IconData gobo = Icons.filter_vintage_outlined;
  static const IconData sculpt = Icons.face_outlined;
  static const IconData search = Icons.search_rounded;
  static const IconData brush = Icons.brush_outlined;
  static const IconData undo = Icons.undo_outlined;
  static const IconData clear = Icons.layers_clear_outlined;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_rounded;
  static const IconData forward = Icons.arrow_forward_ios_rounded;
  static const IconData quality = Icons.photo_size_select_large_outlined;
  static const IconData privacy = Icons.privacy_tip_outlined;
  static const IconData terms = Icons.description_outlined;
  static const IconData sweep = Icons.delete_sweep_outlined;
  static const IconData chevron = Icons.chevron_right_rounded;
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData stop = Icons.stop_rounded;
  static const IconData live = Icons.videocam_rounded;
  static const IconData stories = Icons.auto_stories_rounded;
  static const IconData addPhoto = Icons.add_photo_alternate_outlined;
  static const IconData layout = Icons.auto_awesome_motion_rounded;
  static const IconData themes = Icons.dashboard_customize_rounded;
  static const IconData textFields = Icons.text_fields_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData noPhoto = Icons.no_photography_rounded;
  static const IconData timer = Icons.timer_rounded;
  static const IconData pose = Icons.accessibility_new_rounded;
  static const IconData coffee = Icons.local_cafe_outlined;
  static const IconData beach = Icons.beach_access_outlined;
  static const IconData hourglass = Icons.hourglass_empty_rounded;
  static const IconData magic = Icons.auto_fix_high_rounded;
  static const IconData crop = Icons.crop_rounded;
  static const IconData ratio = ConversationalIcons.aspectRatio; // Placeholder or use Icons.aspect_ratio
  static const IconData square = Icons.crop_square_rounded;
  static const IconData portrait = Icons.portrait_rounded;
  static const IconData phone = Icons.smartphone_rounded;
  static const IconData tv = Icons.tv_rounded;
  static const IconData landscape = Icons.crop_landscape_rounded;
  static const IconData pan = Icons.pan_tool_rounded;
  static const IconData palette = Icons.palette_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData flashOn = Icons.flash_on_rounded;
  static const IconData flashOff = Icons.flash_off_rounded;
  static const IconData timerOff = Icons.timer_off_rounded;
  static const IconData help = Icons.help_outline_rounded;
  static const IconData videocam = Icons.videocam_rounded;
  static const IconData sync = Icons.sync_rounded;
  static const IconData skipBack = Icons.skip_previous_rounded;
  static const IconData skipForward = Icons.skip_next_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData paletteOutlined = Icons.palette_outlined;
  static const IconData texture = Icons.texture_outlined;
  static const IconData faceRetouch = Icons.face_retouching_natural_rounded;
  static const IconData blur = Icons.blur_on_rounded;
  static const IconData borderAll = Icons.border_all_rounded;
  static const IconData transform = Icons.transform_rounded;
  static const IconData mic = Icons.mic_rounded;
  static const IconData micOff = Icons.mic_none_rounded;
  static const IconData security = Icons.security_rounded;
  static const IconData history = Icons.history_edu_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData heart = Icons.favorite_rounded;
  static const IconData paint = Icons.format_paint_rounded;
  static const IconData undoRounded = Icons.undo_rounded;
  static const IconData refreshRounded = Icons.refresh_rounded;
  static const IconData qrCode = Icons.qr_code_2_rounded;
  
  // Newly added to fix missing getters
  static const IconData accent = Icons.color_lens_rounded;
  static const IconData sunny = Icons.wb_sunny_rounded;
  static const IconData mood = Icons.mood_rounded;
  static const IconData rocket = Icons.rocket_launch_rounded;
  static const IconData autoFix = Icons.auto_fix_high_rounded;
  static const IconData home = Icons.home_rounded;
  static const IconData flip = Icons.flip_camera_android_rounded;
  static const IconData grid = Icons.grid_on_rounded;
  static const IconData calendar = Icons.calendar_month_rounded;
  static const IconData lock = Icons.lock_rounded;
  static const IconData sunflower = Icons.local_florist_rounded;
  static const IconData aspectRatio = Icons.aspect_ratio_rounded;
}

class ConversationalIcons {
  static const IconData aspectRatio = Icons.aspect_ratio_rounded;
}

/// AppShadows: Premium elevation tokens.
class AppShadows {
  // Sharp, tight cast for floating tools
  static List<BoxShadow> tight = [
    BoxShadow(
      color: const Color(0x66000000),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Wide ambient glow for premium modal elevations
  static List<BoxShadow> ambient = [
    BoxShadow(
      color: const Color(0x44000000),
      blurRadius: 24,
      spreadRadius: 2,
      offset: const Offset(0, 12),
    ),
  ];
}

/// AppSpacing: Standardized spacing scale for consistent layouts.
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// AppRadius: Standardized corner radii for premium UI components.
class AppRadius {
  static const double sm = 8.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double circular = 99.0;
  
  static BorderRadius smRadius = BorderRadius.circular(sm);
  static BorderRadius mdRadius = BorderRadius.circular(md);
  static BorderRadius lgRadius = BorderRadius.circular(lg);
  static BorderRadius circularRadius = BorderRadius.circular(circular);
}

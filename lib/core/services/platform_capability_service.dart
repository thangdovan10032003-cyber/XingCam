import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Represents the processing capability tier of the device.
enum DeviceTier {
  /// Flagship — Snapdragon 8 Gen 2+, Apple A15+, Dimensity 9000+
  /// → Use native GPU pipeline, full-res AI, immediate processing
  high,

  /// Mid-range — Snapdragon 6/7xx, Apple A12-A14, Dimensity 800
  /// → Use Dart Isolate processing, 1080p proxy editing
  mid,

  /// Budget — Snapdragon 4xx, MediaTek Helio, older chips
  /// → Warn user, offer background task or hybrid cloud
  low,
}

class DeviceSpec {
  final DeviceTier tier;
  final int ramMb;
  final String chipName;
  final bool supportsVulkan;

  const DeviceSpec({
    required this.tier,
    required this.ramMb,
    required this.chipName,
    required this.supportsVulkan,
  });

  /// Estimated seconds to process a 12MP image for the given operation.
  int estimateProcessingSeconds(String operationType) {
    final base = switch (operationType) {
      'segmentation'      => 4,
      'depth_estimation'  => 3,
      'style_transfer'    => 12,
      'upscale_4x'        => 20,
      'face_retouch'      => 6,
      _                   => 5,
    };
    return switch (tier) {
      DeviceTier.high => (base * 0.5).round(),
      DeviceTier.mid  => base,
      DeviceTier.low  => (base * 3.5).round(),
    };
  }

  bool get needsBackgroundProcessing =>
      tier == DeviceTier.low || ramMb < 2048;

  bool get needsHybridWarning =>
      tier == DeviceTier.low;
}

/// PlatformCapabilityService — detects device hardware to route processing.
///
/// Caches the result after first call to avoid repeated system queries.
class PlatformCapabilityService {
  static DeviceSpec? _cached;
  static final _info = DeviceInfoPlugin();

  /// Returns cached [DeviceSpec]. Call once during app init for best performance.
  static Future<DeviceSpec> getDeviceSpec() async {
    if (_cached != null) return _cached!;
    _cached = await _detect();
    return _cached!;
  }

  static Future<DeviceSpec> _detect() async {
    try {
      if (Platform.isAndroid) {
        final info = await _info.androidInfo;
        return _classifyAndroid(info);
      } else if (Platform.isIOS) {
        final info = await _info.iosInfo;
        return _classifyIOS(info);
      }
    } catch (e) {
      debugPrint('[PlatformCapability] Detection failed: $e');
    }
    // Fallback — assume mid-tier
    return const DeviceSpec(
      tier: DeviceTier.mid,
      ramMb: 3000,
      chipName: 'Unknown',
      supportsVulkan: false,
    );
  }

  static DeviceSpec _classifyAndroid(AndroidDeviceInfo info) {
    final chip = info.hardware.toLowerCase();
    final board = info.board.toLowerCase();
    final sdk = info.version.sdkInt;

    // High-tier chips: Snapdragon 8xx, Dimensity 9xxx, Google Tensor G3/G4
    final isHigh = chip.contains('qcom') && _sdkToHighSoc(board) ||
        board.contains('tensor') ||
        board.contains('dimensity9') ||
        board.contains('sm8');

    // Budget chips: Snapdragon 4xx, old Helio
    final isLow = board.contains('mt67') ||
        board.contains('sm4') ||
        sdk < 29;

    final tier = isHigh
        ? DeviceTier.high
        : isLow
            ? DeviceTier.low
            : DeviceTier.mid;

    return DeviceSpec(
      tier: tier,
      ramMb: 3000, // Runtime RAM not directly accessible, use heuristic
      chipName: '${info.brand} ${info.hardware}',
      supportsVulkan: sdk >= 28,
    );
  }

  static bool _sdkToHighSoc(String board) {
    // Snapdragon 8 Gen 1/2/3 boards
    return board.contains('sm8450') ||
        board.contains('sm8550') ||
        board.contains('sm8650') ||
        board.contains('sm8750');
  }

  static DeviceSpec _classifyIOS(IosDeviceInfo info) {
    final model = info.utsname.machine;

    // Apple A15 Bionic+ (iPhone 13+, iPad Pro M1+)
    final isHigh = _isHighTierIOS(model);
    // Older than A12 (iPhone X era or older)
    final isLow = _isLowTierIOS(model);

    final tier = isHigh
        ? DeviceTier.high
        : isLow
            ? DeviceTier.low
            : DeviceTier.mid;

    return DeviceSpec(
      tier: tier,
      ramMb: isHigh ? 6000 : isLow ? 2000 : 4000,
      chipName: model,
      supportsVulkan: false, // iOS uses Metal
    );
  }

  static bool _isHighTierIOS(String model) {
    // iPhone 13+ (A15), 14+ (A15/A16), 15+ (A16/A17), 16+ (A18)
    final highModels = ['iPhone14', 'iPhone15', 'iPhone16', 'iPhone17',
                        'iPad13', 'iPad14', 'iPad15', 'iPad16'];
    return highModels.any((m) => model.startsWith(m));
  }

  static bool _isLowTierIOS(String model) {
    // iPhone 8 and older (A11 and below)
    final lowModels = ['iPhone8', 'iPhone7', 'iPhone6', 'iPhone5',
                       'iPhone9', 'iPhone10'];
    return lowModels.any((m) => model.startsWith(m));
  }
}

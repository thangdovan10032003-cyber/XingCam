import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RemoteConfigService: Offline-first stub.
/// Network delivery is removed for v1.0 sovereign release.
/// All filter configs are served from bundled local assets.
@lazySingleton
class RemoteConfigService {
  static const String _configKey = 'xingcam_remote_config_v1';

  /// Returns an empty map â€” all presets now come from bundled local assets.
  /// Server-Driven UI can be re-enabled in a future premium release.
  Future<Map<String, dynamic>> fetchFilterConfig() async {
    return {}; // Offline-first: local hardcoded presets in repository take over.
  }

  /// Stub retained for interface compatibility.
  Future<String?> downloadLut(String url, String fileName) async {
    return null; // No remote LUT download in offline-first mode.
  }

  /// Persists a local config snapshot (retained for future use).
  Future<void> cacheConfig(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, jsonString);
  }
}


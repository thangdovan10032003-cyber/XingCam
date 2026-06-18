import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// AiUsageService: Intelligently tracks tool usage to optimize Home Screen UI.
/// Powers the "Smart Recents" category for peak professional efficiency.
class AiUsageService extends ChangeNotifier {
  static const String _recentKey = 'xingcam_recent_tools_v1';
  static const int _maxRecents = 4;

  List<String> _recentToolIds = [];
  List<String> get recentToolIds => _recentToolIds;

  AiUsageService() {
    _loadRecents();
  }

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    _recentToolIds = prefs.getStringList(_recentKey) ?? [];
    notifyListeners();
  }

  /// Records a tool usage and moves it to the top of the recents list.
  Future<void> trackToolUsage(String toolId) async {
    _recentToolIds.remove(toolId);
    _recentToolIds.insert(0, toolId);
    
    if (_recentToolIds.length > _maxRecents) {
      _recentToolIds = _recentToolIds.sublist(0, _maxRecents);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recentToolIds);
    notifyListeners();
  }

  /// Returns true if there are enough recents to display.
  bool get hasRecents => _recentToolIds.isNotEmpty;
}

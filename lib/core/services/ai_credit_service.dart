import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Ensures sustainable AI processing usage through a credit-based system.
class AiCreditService extends ChangeNotifier {
  static const String _creditKey = 'xingcam_ai_credits_v1';
  static const String _proKey = 'xingcam_is_pro_v1';
  static const int _initialCredits = 10;

  int _currentCredits = _initialCredits;
  bool _isPro = false;

  int get currentCredits => _currentCredits;
  bool get isPro => _isPro;

  AiCreditService() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCredits = prefs.getInt(_creditKey) ?? _initialCredits;
    _isPro = prefs.getBool(_proKey) ?? false;
    notifyListeners();
  }

  /// Toggles Pro subscription status (Simulated for purchase integration).
  Future<void> setProStatus(bool pro) async {
    _isPro = pro;
    if (pro) {
      _currentCredits += 500; // Bonus for Pro trial
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proKey, pro);
    await prefs.setInt(_creditKey, _currentCredits);
    notifyListeners();
  }

  /// Awards 1 credit after watching a rewarded ad.
  Future<void> watchRewardedAd() async {
    // In production: Connects to AdMob/AppLovin Rewarded API
    await Future.delayed(const Duration(seconds: 1)); // Simulate ad delay
    await addCredits(1);
    notifyListeners();
  }

  /// Deducts a specific amount of credits for a heavy AI operation.
  /// Pro users get a 50% discount on credit costs.
  Future<bool> useCredits(int amount) async {
    final effectiveCost = _isPro ? (amount / 2).ceil() : amount;
    
    if (_currentCredits < effectiveCost) return false;
    
    _currentCredits -= effectiveCost;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_creditKey, _currentCredits);
    notifyListeners();
    return true;
  }

  /// Adds credits to the balance (e.g., after a purchase).
  Future<void> addCredits(int amount) async {
    _currentCredits += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_creditKey, _currentCredits);
    notifyListeners();
  }

  /// Returns true if the user has enough credits for a specific cost.
  bool hasEnoughCredits(int cost) => _currentCredits >= cost;
}

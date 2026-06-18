import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SubscriptionService {
  final String _appleApiKey = 'appl_YOUR_REVENUECAT_APPLE_KEY';
  final String _googleApiKey = 'goog_YOUR_REVENUECAT_GOOGLE_KEY';

  bool _isPro = false;
  bool get isPro => _isPro;

  Future<void> init() async {
    try {
      await Purchases.setLogLevel(LogLevel.info);
      
      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      } else {
        configuration = PurchasesConfiguration(_appleApiKey);
      }
      await Purchases.configure(configuration);
      await _checkSubscriptionStatus();
    } catch (e) {
      debugPrint("RevenueCat Init Error: \$e");
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPro = customerInfo.entitlements.all["pro_entitlement"]?.isActive ?? false;
    } catch (e) {
      debugPrint("Failed to fetch subscription status: \$e");
    }
  }

  Future<bool> purchasePro() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        final package = offerings.current!.availablePackages.first;
        final customerInfo = await Purchases.purchasePackage(package);
        _isPro = customerInfo.entitlements.all["pro_entitlement"]?.isActive ?? false;
        return _isPro;
      }
    } catch (e) {
      debugPrint("Purchase Failed: \$e");
    }
    return false;
  }
}

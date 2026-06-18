import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xingcam/core/services/biometric_consent_service.dart';
import 'package:xingcam/core/theme/design_tokens.dart';

/// Intercepts navigation to Biometric-heavy screens.
/// Pushes the consent dialog. If rejected, pops back.
class BiometricGuard extends StatefulWidget {
  final Widget child;
  const BiometricGuard({super.key, required this.child});

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard> {
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final granted = await BiometricConsentService.ensureConsent(context);
    if (!mounted) return;
    if (granted) {
      setState(() => _isAuthorized = true);
    } else {
      context.pop(); // User rejected, kick them out of the AI tool
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    return widget.child;
  }
}

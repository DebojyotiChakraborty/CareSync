import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/route_names.dart';
import '../../../../services/auth_controller.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/splash_reveal_overlay.dart';

/// Splash route. At launch the [SplashRevealOverlay] (mounted above the
/// router in [CareSync]) covers this screen with the identical visual; this
/// widget's job is session restore + picking the first destination, then
/// firing the overlay's zoom-reveal once that destination is beneath it.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Restore the session while the logo holds on screen; never reveal
    // before the minimum hold so the animation reads like the reference.
    final results = await Future.wait([
      AuthController.instance.restoreSession(),
      Future<void>.delayed(const Duration(milliseconds: 1500)),
    ]);

    if (!mounted) return;

    final result = results[0] as SessionRestoreResult;
    switch (result) {
      case SessionRestoreResult.success:
        _navigateToDashboard();
        break;
      case SessionRestoreResult.biometricFailed:
      case SessionRestoreResult.loginRequired:
        _goAndReveal(RouteNames.roleSelection);
        break;
    }
  }

  void _navigateToDashboard() {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    switch (profile?.role) {
      case 'doctor':
        _goAndReveal(RouteNames.doctorDashboard);
        break;
      case 'pharmacist':
        _goAndReveal(RouteNames.pharmacistDashboard);
        break;
      case 'patient':
      default:
        _goAndReveal(RouteNames.patientDashboard);
    }
  }

  /// Navigate, then start the zoom-reveal one frame later so the destination
  /// is already rendered beneath the overlay when it becomes transparent.
  void _goAndReveal(String location) {
    // Grab the controller now: go() disposes this widget, and ref must not
    // be touched after that. The controller itself outlives the route.
    final reveal = ref.read(splashRevealProvider.notifier);
    context.go(location);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reveal.state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mirrors the overlay so mid-session redirects to '/' (e.g. while a
    // profile reloads) show the same static branding.
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/app-icon.png',
          width: 160,
          height: 160,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

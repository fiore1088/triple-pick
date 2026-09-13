import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ));
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 120, height: 120, decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: const Icon(Icons.movie_filter, size: 60, color: AppTheme.textPrimaryColor)),
                const SizedBox(height: 24),
                Text('TriplePick', style: AppTheme.headlineLarge.copyWith(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Riguarda la scelta, non il catalogo', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryColor)),
                const SizedBox(height: 48),
                SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor.withOpacity(0.8)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
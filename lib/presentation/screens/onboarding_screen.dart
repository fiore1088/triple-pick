import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(icon: Icons.search, title: 'Cosa vuoi guardare?', description: 'Scrivi in linguaggio naturale cosa ti va di vedere stasera.', color: AppTheme.primaryColor),
    _OnboardingPage(icon: Icons.movie_filter, title: 'Solo 3 consigli', description: 'Niente piu paradosso della scelta. Ti mostreremo esattamente 3 titoli perfetti per te.', color: AppTheme.secondaryColor),
    _OnboardingPage(icon: Icons.play_circle_fill, title: 'Guarda subito', description: 'Ogni consiglio ha un link diretto. Clicca e si apre subito Netflix, Prime Video o Disney+.', color: AppTheme.primaryColor),
  ];

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  void _onPageChanged(int page) { setState(() { _currentPage = page; }); }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) { _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); }
    else { _navigateToHome(); }
  }

  void _navigateToHome() { Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen())); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(alignment: Alignment.topRight, child: TextButton(onPressed: _navigateToHome, child: Text('Salta', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMutedColor)))),
              Expanded(
                child: PageView.builder(controller: _pageController, itemCount: _pages.length, onPageChanged: _onPageChanged, itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 160, height: 160, decoration: BoxDecoration(color: page.color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: page.color.withOpacity(0.3), width: 2)), child: Icon(page.icon, size: 80, color: page.color)),
                    const SizedBox(height: 48),
                    Text(page.title, style: AppTheme.headlineMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(page.description, style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondaryColor), textAlign: TextAlign.center),
                  ]));
                }),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pages.length, (index) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _currentPage == index ? 24 : 8, height: 8, decoration: BoxDecoration(color: _currentPage == index ? AppTheme.primaryColor : AppTheme.textMutedColor.withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 32),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: _currentPage == _pages.length - 1 ? AppTheme.secondaryColor : AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_currentPage == _pages.length - 1 ? 'Inizia' : 'Avanti', style: AppTheme.buttonText)))),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _OnboardingPage({required this.icon, required this.title, required this.description, required this.color});
}
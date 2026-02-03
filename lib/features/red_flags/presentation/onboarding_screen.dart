import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'BREAK THE RULES',
      subtitle: 'Dating apps are boring. We\'re not.',
      description: 'No more pretending to be perfect. Show your real self.',
      alignment: Alignment.topLeft,
    ),
    OnboardingSlide(
      title: 'FIND YOUR MATCH IN MISCHIEF',
      subtitle: 'Connect with fellow rebels',
      description: 'Match with people who embrace chaos like you do.',
      alignment: Alignment.topRight,
    ),
    OnboardingSlide(
      title: 'NO MORE NICE',
      subtitle: 'Wear your red flags with pride',
      description: 'Collect badges, flex your toxicity score, be unapologetically you.',
      alignment: Alignment.bottomLeft,
    ),
    OnboardingSlide(
      title: 'JOIN THE REBELLION',
      subtitle: 'Swipe right for anarchy',
      description: 'The dating app for bad boys & bad girls.',
      alignment: Alignment.bottomRight,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _skip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Skip button
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Page view with illustrations
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(_slides[index], index, theme);
                  },
                ),
              ),

              // Bottom section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _slides.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 32 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.electricRose
                                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricRose,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.electricRose.withValues(alpha: 0.5),
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? 'GET STARTED'
                              : 'NEXT',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide, int index, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container with the combined image cropped
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricRose.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/onboarding/onboarding_combined.png',
                fit: BoxFit.cover,
                alignment: slide.alignment,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackIllustration(index);
                },
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 48),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.electricRose.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildFallbackIllustration(int index) {
    final icons = ['🔥', '🏍️', '😈', '✊'];
    final colors = [
      AppColors.electricRose,
      const Color(0xFF8B0000),
      const Color(0xFFB22222),
      const Color(0xFF800000),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[index].withValues(alpha: 0.8),
            colors[index].withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Center(
        child: Text(
          icons[index],
          style: const TextStyle(fontSize: 120),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String description;
  final Alignment alignment;

  OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.alignment,
  });
}

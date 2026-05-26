import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkle_lite/Data/models/onboarding_model.dart';
import 'package:sparkle_lite/core/constants/app_constants.dart';
import 'package:sparkle_lite/providers/auth_provider.dart';  
import 'package:sparkle_lite/shared/widgets/primary_button.dart';


/// Onboarding screen shown after login if user hasn't completed onboarding yet
/// This screen provides a multi-page introduction to the app's features and benefits. It uses a PageView to allow users to swipe through different onboarding pages, each highlighting a key aspect of the app. The final page includes a "Get Started" button that, when pressed, marks onboarding as complete in the AuthProvider and navigates the user to the health profile setup screen.
///   The onboarding process is designed to be engaging and informative, helping users understand the value of the app and encouraging them to complete their profile for a personalized experience. The UI includes icons, titles, and descriptions for each onboarding page, as well as visual indicators of the current page in the form of dots at the bottom of the screen.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Track Your Health Journey',
      description: 'Log symptoms, track periods, and monitor your wellness over time',
      icon: Icons.favorite,
      color: const Color(0xFFFF6B6B),
    ),
    OnboardingData(
      title: 'Private & Secure',
      description: 'Your health data stays private with generic notifications by default',
      icon: Icons.lock,
      color: const Color(0xFF4ECDC4),
    ),
    OnboardingData(
      title: 'Get Smart Insights',
      description: 'Receive non-diagnostic AI insights to prepare for doctor visits',
      icon: Icons.psychology,
      color: const Color(0xFF7B61FF),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    
    await ref.read(authProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppConstants.routeHealthProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),
            _buildBottomNavigation(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pages.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF7B61FF)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PrimaryButton(
            text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
            onPressed: () {
              if (_currentPage == _pages.length - 1) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}


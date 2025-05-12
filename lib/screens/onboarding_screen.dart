import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

// ─── Brand Colors ──────────────────────────────────────────────────────
const Color kNavy      = Color(0xFF0B1F2A);
const Color kCream     = Color(0xFFF3EDE6);
const Color kMustard   = Color(0xFFEABE2D);
const Color kBrickRed  = Color(0xFFD03F2F);
const Color kRoyalBlue = Color(0xFF2D6FA4);

// ─── OnboardingPage Model ─────────────────────────────────────────────
class OnboardingPage {
  final String imageAsset;
  final String title;
  final String description;

  const OnboardingPage({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}

// ─── Slides Data ───────────────────────────────────────────────────────
const List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    imageAsset: 'assets/images/slide1_welcome_to_langismate.png',
    title: 'Welcome to LangisMate',
    description: 'Never miss an oil change again for your motorcycle.',
  ),
  OnboardingPage(
    imageAsset: 'assets/images/slide2_find_nearby_shops.png',
    title: 'Find Nearby Shops',
    description: 'Locate trusted repair and maintenance shops around you.',
  ),
  OnboardingPage(
    imageAsset: 'assets/images/slide3_set_maintenance_reminders.png',
    title: 'Set Maintenance Reminders',
    description: 'Customize reminders so your bike always runs smoothly.',
  ),
];

// ─── OnboardingScreen ─────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: Stack(
        children: [
          // Swipeable Pages
          PageView.builder(
            controller: _controller,
            itemCount: onboardingPages.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) {
              final page = onboardingPages[i];
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(page.imageAsset, height: 300),
                    const SizedBox(height: 32),
                    Text(
                      page.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ).copyWith(color: kCream),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle().copyWith(color: kCream),
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip Button
          Positioned(
            right: 16,
            top: 40,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(color: kCream),
              ),
            ),
          ),

          // Dots Indicator
          Positioned(
            bottom: 24,
            left: 24,
            child: Row(
              children: List.generate(onboardingPages.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == i ? 12 : 8,
                  height: _currentIndex == i ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == i ? kMustard : kCream,
                  ),
                );
              }),
            ),
          ),

          // Next / Done Button
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kMustard,
                foregroundColor: kNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_currentIndex == onboardingPages.length - 1) {
                  _finishOnboarding();
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                _currentIndex == onboardingPages.length - 1 ? 'Done' : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/theme_provider.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    final themeProvider = ThemeService();
    themeProvider.setOnboardingComplete();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildSplashPage(),
              _buildWelcomePage(),
              _buildLanguagePage(),
              _buildNotificationPage(),
            ],
          ),
          // Skip button (top right) — only for light pages
          if (_currentPage > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: GestureDetector(
                onTap: _completeOnboarding,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.maroon.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Skip',
                    style: TextStyle(color: AppColors.maroon.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // PAGE 1: SPLASH — Dark maroon bg (matches mockup)
  // ═══════════════════════════════════════════════════
  Widget _buildSplashPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6B0000), AppColors.maroonDark],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Golden decorative border frame
            Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/others/logo.PNG',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.gold.withOpacity(0.08),
                    child: const Center(
                      child: Text('☸', style: TextStyle(fontSize: 80, color: AppColors.gold)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('NYINGMAPA',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 12,
              ),
            ),
            const SizedBox(height: 4),
            const Text('CALENDAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 16),
            Text('Ancient Wisdom, Modern Life',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 2,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(flex: 4),
            // RED/Maroon "Get Started" button (matches mockup)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.maroon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Page indicator
            Text('VARIANT 2 OF 4',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, letterSpacing: 1),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // PAGE 2: WELCOME — WHITE bg (matches mockup!)
  // ═══════════════════════════════════════════════════
  Widget _buildWelcomePage() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Maroon text welcome (matches mockup)
              const Text('Welcome to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text('Nyingmapa\nCalendar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.maroon,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Track sacred dates, lunar cycles,\nand auspicious occasions in the\nNyingma Buddhist tradition.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 1),
              // Page dots (maroon)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Container(
                  width: i == 1 ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == 1 ? AppColors.maroon : AppColors.maroon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // PAGE 3: LANGUAGE — WHITE bg (matches mockup!)
  // ═══════════════════════════════════════════════════
  Widget _buildLanguagePage() {
    final themeProvider = ThemeService();
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Red/maroon icon circle (matches mockup)
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.maroon.withOpacity(0.08),
                ),
                child: const Center(
                  child: Text('文', style: TextStyle(fontSize: 28, color: AppColors.maroon, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Select Your Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred language to begin your journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),

              // English option — WHITE card with maroon accent (matches mockup)
              _langOption(
                'WESTERN', 'English', 'US',
                themeProvider.language == 'en',
                () => themeProvider.setLanguage('en'),
              ),
              const SizedBox(height: 12),
              // Tibetan option
              _langOption(
                '', 'ད་རྗེས་བོད་ཡིག', '🏔',
                themeProvider.language == 'bo',
                () => themeProvider.setLanguage('bo'),
              ),

              const Spacer(flex: 2),

              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Container(
                  width: i == 2 ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == 2 ? AppColors.maroon : AppColors.maroon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const SizedBox(height: 20),

              // RED "Continue" button (matches mockup)
              GestureDetector(
                onTap: _nextPage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.maroon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Continue',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // PAGE 4: NOTIFICATIONS — WHITE bg (matches mockup!)
  // ═══════════════════════════════════════════════════
  Widget _buildNotificationPage() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Maroon icon circle (matches mockup)
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.maroon.withOpacity(0.08),
                ),
                child: const Center(
                  child: Text('🔔', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Enable Sacred\nAlerts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay aligned with the lunar cycle and\nnever miss an auspicious practice day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Notification options — WHITE card with maroon icon (matches mockup)
              _notifOption(Icons.brightness_3, 'Lunar Notifications',
                'Receive timely alerts for Guru Rinpoche Days, Medicine Buddha days, and other new/full moon days.'),
              const SizedBox(height: 12),
              _notifOption(Icons.sync, 'Calendar Sync',
                'Automatically sync sacred dates and practice reminders with your device calendar.'),

              const Spacer(flex: 2),

              // RED "Enable Access" button (matches mockup)
              GestureDetector(
                onTap: _completeOnboarding,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.maroon,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Enable Access',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // "MAYBE LATER" link (matches mockup)
              GestureDetector(
                onTap: _completeOnboarding,
                child: Text('MAYBE LATER',
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════
  Widget _langOption(String label, String title, String code, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.maroon : AppColors.cream,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(code, style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                )),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(label, style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: AppColors.navy.withOpacity(0.4),
                      letterSpacing: 1,
                    )),
                  Text(title, style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  )),
                ],
              ),
            ),
            // Radio button (maroon when selected)
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.maroon : AppColors.lightTextSecondary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12, height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.maroon,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notifOption(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cream),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maroon circle icon (matches mockup)
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.maroon.withOpacity(0.08),
            ),
            child: Icon(icon, size: 20, color: AppColors.maroon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  color: AppColors.navy, fontSize: 15, fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(
                  color: AppColors.navy.withOpacity(0.5), fontSize: 12, height: 1.4,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
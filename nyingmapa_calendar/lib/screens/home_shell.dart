import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/theme_provider.dart';
import '../services/translations.dart';
import 'calendar_home_screen.dart';
import 'auspicious_days_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CalendarHomeScreen(),
    const AuspiciousDaysScreen(),
    const EventsScreen(),
    const PracticeScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final lang = ref.watch(languageProvider);
    final isBo = lang == 'bo';

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.calendar_month_outlined, Icons.calendar_month, T.t('nav_calendar', isBo), isDark),
                _navItem(1, Icons.diamond_outlined, Icons.diamond, T.t('nav_auspicious', isBo), isDark),
                _navItem(2, Icons.assignment_outlined, Icons.assignment, T.t('nav_events', isBo), isDark),
                _navItem(3, Icons.person_outline, Icons.person, T.t('nav_practice', isBo), isDark),
                _navItem(4, Icons.settings_outlined, Icons.settings, T.t('nav_settings', isBo), isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label, bool isDark) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.maroon.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppColors.maroon : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.maroon : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            )),
          ],
        ),
      ),
    );
  }
}

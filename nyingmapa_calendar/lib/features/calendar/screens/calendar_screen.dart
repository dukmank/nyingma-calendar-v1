import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calendar_provider.dart';

import '../../../core/theme/app_colors.dart';

import '../widgets/calendar_grid.dart';
import '../widgets/calendar_hero_card.dart';
import '../widgets/calendar_month_header.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  @override
  Widget build(BuildContext context) {
    final monthAsync = ref.watch(currentMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const CalendarMonthHeader(),
            Expanded(
              child: monthAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accentGold),
                ),
                error: (_, __) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to load calendar data',
                        style: TextStyle(color: AppColors.inauspicious),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(currentMonthProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (days) {
                  if (days.isEmpty) {
                    return const Center(
                      child: Text(
                        'No calendar data available',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      const CalendarHeroCard(),
                      Expanded(child: CalendarGrid(days: days)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
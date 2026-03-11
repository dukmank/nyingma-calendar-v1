import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/calendar_day_vm.dart';
import '../providers/selected_day_provider.dart';
import '../../day_detail/screens/day_detail_screen.dart';
import '../../day_detail/view_models/day_detail_vm.dart';
import '../../events/providers/events_provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class CalendarGrid extends ConsumerWidget {
  final List<CalendarDayVM> days;

  const CalendarGrid({super.key, required this.days});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateKey = ref.watch(selectedDateKeyProvider);
    final languageAsync = ref.watch(languageProvider);

    return languageAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (language) {
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isSelected = selectedDateKey == day.dateKey;

            return GestureDetector(
              onTap: () async {
                ref.read(selectedDateKeyProvider.notifier).state = day.dateKey;

                final allEvents =
                    await ref.read(eventsMasterFutureProvider.future);

                final selectedEntity =
                    await ref.read(selectedDayEntityProvider.future);
                if (selectedEntity == null) return;

                final vm = DayDetailVM.fromData(
                  d: selectedEntity,
                  allEvents: allEvents,
                );

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DayDetailScreen(vm: vm),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentMaroon
                      : (day.isHighlight
                          ? AppColors.accentGold
                          : AppColors.backgroundCard),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.dayNumber.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: (isSelected || day.isHighlight)
                              ? AppColors.backgroundPrimary
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (language == AppLanguage.bo)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            day.lunarDate,
                            style: TextStyle(
                              fontSize: 10,
                              color: (isSelected || day.isHighlight)
                                  ? AppColors.backgroundPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
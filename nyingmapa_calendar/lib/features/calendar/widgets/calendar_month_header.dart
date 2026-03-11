import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/month_state_provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class CalendarMonthHeader extends ConsumerWidget {
  const CalendarMonthHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthState = ref.watch(monthStateProvider);
    final languageAsync = ref.watch(languageProvider);

    return languageAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (language) {
        final year = monthState.year;
        final month = monthState.month;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  ref.read(monthStateProvider.notifier).prevMonth();
                },
                icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
              ),
              Column(
                children: [
                  Text(
                    language == AppLanguage.en
                        ? _monthName(month)
                        : _monthNameBo(month),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    year.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(monthStateProvider.notifier).goToToday();
                    },
                    child: Text(
                      language == AppLanguage.en ? 'TODAY' : 'དེ་རིང་',
                      style: const TextStyle(color: AppColors.accentGold),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(languageProvider.notifier).toggle();
                    },
                    icon: Text(
                      language == AppLanguage.en ? 'EN' : 'བོད་',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(monthStateProvider.notifier).nextMonth();
                    },
                    icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  String _monthNameBo(int month) {
    const monthsBo = [
      'ཟླ་དང་པོ',
      'ཟླ་གཉིས་པ',
      'ཟླ་གསུམ་པ',
      'ཟླ་བཞི་པ',
      'ཟླ་ལྔ་པ',
      'ཟླ་དྲུག་པ',
      'ཟླ་བདུན་པ',
      'ཟླ་བརྒྱད་པ',
      'ཟླ་དགུ་པ',
      'ཟླ་བཅུ་པ',
      'ཟླ་བཅུ་གཅིག་པ',
      'ཟླ་བཅུ་གཉིས་པ',
    ];

    if (month < 1 || month > 12) return '';
    return monthsBo[month - 1];
  }
}

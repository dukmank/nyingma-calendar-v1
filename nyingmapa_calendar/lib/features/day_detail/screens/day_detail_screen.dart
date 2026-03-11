import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../view_models/day_detail_vm.dart';
import '../widgets/astrology_section.dart';

class DayDetailScreen extends ConsumerWidget {
  final DayDetailVM vm;

  const DayDetailScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageAsync = ref.watch(languageProvider);

    return languageAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (language) {
        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundPrimary,
            elevation: 0,
            title: Text(
              language == AppLanguage.en
                  ? '${vm.gregorianDay} ${vm.gregorianMonthLabel ?? ''} ${vm.gregorianYear}'
                  : '${vm.gregorianDay} ${vm.tibetanMonthLabel ?? ''} ${vm.tibetanYear ?? ''}',
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vm.heroImageKey != null && vm.heroImageKey!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 320,
                    child: Image.asset(
                      'assets/images/${vm.heroImageKey}.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              (language == AppLanguage.en
                                          ? vm.gregorianDayName
                                          : vm.tibetanDayLabel)
                                      ?.toUpperCase() ??
                                  '',
                              style: const TextStyle(
                                fontSize: 18,
                                letterSpacing: 2,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            AppSpacing.hSm,
                            Text(
                              vm.gregorianDay.toString(),
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            AppSpacing.hSm,
                            if (vm.hasEvents && vm.events.isNotEmpty)
                              Text(
                                language == AppLanguage.en
                                    ? vm.events.first.titleEn
                                    : (vm.events.first.titleBo ?? vm.events.first.titleEn),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      AppSpacing.hXxl,
                      Row(
                        children: [
                          Expanded(
                            child: _metaBlock(
                              language == AppLanguage.en ? 'DATE' : 'ཚེས་',
                              language == AppLanguage.en
                                  ? (vm.tibetanDay?.toString() ?? '')
                                  : (vm.tibetanDayLabel ?? ''),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _metaBlock(
                              language == AppLanguage.en ? 'MONTH' : 'ཟླ་',
                              language == AppLanguage.en
                                  ? (vm.tibetanMonth?.toString() ?? '')
                                  : (vm.tibetanMonthLabel ?? ''),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _metaBlock(
                              language == AppLanguage.en ? 'YEAR' : 'ལོ་',
                              vm.tibetanYear?.toString() ?? '',
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.hXxl,
                      if (vm.significance != null && vm.significance!.isNotEmpty) ...[
                        Text(
                          language == AppLanguage.en
                              ? 'DAY SIGNIFICANCE'
                              : 'ཉིན་གྱི་དོན་དམ',
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.hSm,
                        Text(
                          language == AppLanguage.en
                              ? vm.significance!
                              : (vm.entity.content.significanceBo ?? vm.significance!),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AppSpacing.hXl,
                      ],
                      if (vm.elementCombo != null && vm.elementCombo!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language == AppLanguage.en
                                    ? 'ELEMENT COMBINATION'
                                    : 'འབྱུང་བ་མཉམ་སྦྱོར',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              AppSpacing.hSm,
                              Text(
                                language == AppLanguage.en
                                    ? vm.elementCombo!
                                    : (vm.entity.visual.elementComboBo ?? vm.elementCombo!),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      AppSpacing.hXxl,
                      AstrologySection(cards: vm.astrologyCards),
                      Text(
                        language == AppLanguage.en
                            ? 'TODAY’S EVENTS'
                            : 'དེ་རིང་གི་དུས་ཆེན',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppSpacing.hMd,
                      if (!vm.hasEvents)
                        Text(
                          language == AppLanguage.en
                              ? 'No events for this day'
                              : 'དེ་རིང་དུས་ཆེན་མེད།',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ...vm.events.map(
                        (event) => Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language == AppLanguage.en
                                    ? event.titleEn
                                    : (event.titleBo ?? event.titleEn),
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (event.detailsEn != null && event.detailsEn!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    language == AppLanguage.en
                                        ? event.detailsEn!
                                        : (event.detailsBo ?? event.detailsEn!),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.hXxl,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                            backgroundColor: AppColors.accentMaroon,
                          ),
                          child: Text(
                            language == AppLanguage.en
                                ? 'ADD TO MY CALENDAR'
                                : 'ངའི་ཟླ་ཐོར་སྣོན་',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metaBlock(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.hXs,
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
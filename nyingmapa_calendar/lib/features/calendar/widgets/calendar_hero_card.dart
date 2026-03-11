import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/selected_day_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class CalendarHeroCard extends ConsumerWidget {
  const CalendarHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityAsync = ref.watch(selectedDayEntityProvider);

    return entityAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (entity) {
        if (entity == null) return const SizedBox.shrink();

        final g = entity.gregorian;
        final t = entity.tibetan;

        final languageAsync = ref.watch(languageProvider);

        final eventsMapAsync = ref.watch(eventsMapProvider);

        return languageAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (language) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Builder(
                builder: (_) {
                  final primaryId = entity.flags.primaryEventId;

                  String? primaryTitle;

                  if (primaryId != null) {
                    final eventsMap = eventsMapAsync.valueOrNull ?? {};
                    final match = eventsMap[primaryId];

                    if (match != null) {
                      primaryTitle = language == AppLanguage.en
                          ? (match.titleEn.isNotEmpty ? match.titleEn : null)
                          : (match.titleBo?.isNotEmpty == true
                              ? match.titleBo
                              : match.titleEn);
                    }
                  }

                  final eventCount = entity.eventIds.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language == AppLanguage.en
                            ? '${g.day} ${g.monthLabelEn ?? ''} ${g.year}'
                            : '${g.day} ${t.monthLabelBo ?? ''} ${t.year ?? ''}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppSpacing.hXs,
                      Text(
                        language == AppLanguage.en
                            ? (g.dayNameEn ?? '')
                            : (t.dayLabelBo ?? ''),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      AppSpacing.hMd,
                      Text(
                        language == AppLanguage.en
                            ? 'Tibetan: ${t.day ?? ''} ${t.monthLabelBo ?? ''}'
                            : 'བོད་: ${t.dayLabelBo ?? ''} ${t.monthLabelBo ?? ''}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        language == AppLanguage.en
                            ? 'Animal Month: ${t.animalMonthEn ?? ''}'
                            : 'ཟླ་བའི་གནམ་སྐྱེས: ${t.animalMonthBo ?? t.animalMonthEn ?? ''}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        language == AppLanguage.en
                            ? 'Lunar Status: ${t.lunarStatusEn ?? ''}'
                            : 'ཟླ་བའི་གནས་ཚུལ: ${t.lunarStatusBo ?? t.lunarStatusEn ?? ''}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      AppSpacing.hMd,
                      Text(
                        language == AppLanguage.en
                            ? 'Element Combo: ${entity.visual.elementComboEn ?? ''}'
                            : 'འབྱུང་བ་མཉམ་སྦྱོར: ${entity.visual.elementComboBo ?? entity.visual.elementComboEn ?? ''}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        language == AppLanguage.en
                            ? 'Coincidence Meaning: ${entity.visual.coincidenceMeaningEn ?? ''}'
                            : 'མཐུན་འབྲེལ་དོན: ${entity.visual.coincidenceMeaningBo ?? entity.visual.coincidenceMeaningEn ?? ''}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      AppSpacing.hMd,
                      Text(
                        'Extremely Auspicious: ${entity.flags.isExtremelyAuspicious}',
                        style: const TextStyle(color: AppColors.accentGold),
                      ),
                      Text(
                        'Event Count: $eventCount',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      AppSpacing.hMd,
                      if (primaryTitle != null)
                        Text(
                          'Primary Event: $primaryTitle',
                          style: const TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
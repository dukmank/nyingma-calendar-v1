import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/events_provider.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsMasterFutureProvider);
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
              language == AppLanguage.en ? 'Events' : 'དུས་ཆེན་',
            ),
          ),
          body: eventsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            ),
            error: (e, _) => Center(
              child: Text(
                language == AppLanguage.en
                    ? 'Error loading events: $e'
                    : 'དུས་ཆེན་འབོད་འདྲེན་ནོར་འཁྲུལ།',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    language == AppLanguage.en
                        ? 'No events available'
                        : 'དུས་ཆེན་མེད།',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                );
              }

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final e = events[index];

                  final title = language == AppLanguage.en
                      ? (e.titleEn.isEmpty ? '[EMPTY TITLE]' : e.titleEn)
                      : ((e.titleBo?.isNotEmpty == true)
                          ? e.titleBo!
                          : e.titleEn);

                  return Card(
                    color: AppColors.backgroundCard,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.hSm,
                          Text(
                            "ID: ${e.id}",
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          if ((language == AppLanguage.en
                                  ? e.detailsEn
                                  : e.detailsBo ?? e.detailsEn) !=
                              null &&
                              (language == AppLanguage.en
                                      ? e.detailsEn
                                      : e.detailsBo ?? e.detailsEn)!
                                  .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                              child: Text(
                                language == AppLanguage.en
                                    ? e.detailsEn!
                                    : (e.detailsBo ?? e.detailsEn!),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

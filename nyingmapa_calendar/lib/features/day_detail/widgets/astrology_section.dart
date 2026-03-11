import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/astrology/astrology_engine.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../screens/astrology_detail_screen.dart';

class AstrologySection extends ConsumerWidget {
  final List<AstrologyCard> cards;

  const AstrologySection({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageAsync = ref.watch(languageProvider);

    if (cards.isEmpty) return const SizedBox.shrink();

    return languageAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (language) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language == AppLanguage.en ? 'ASTROLOGY' : 'རྒྱུད་རྩིས',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.hMd,
            ...cards.map((card) {
              final title = language == AppLanguage.en ? card.titleEn : card.titleBo;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      // ✅ FULL SCREEN NAVIGATION (no bottom sheet)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AstrologyDetailScreen(card: card),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: _statusColor(card.status),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          card.iconKey != null && card.iconKey!.isNotEmpty
                              ? Image.asset(
                                  card.iconKey!,
                                  width: 22,
                                  height: 22,
                                  color: Colors.white,
                                )
                              : const Icon(Icons.auto_awesome, color: Colors.white),
                          AppSpacing.wMd,
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            card.isActive ? Icons.chevron_right : Icons.lock_outline,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            AppSpacing.hXxl,
          ],
        );
      },
    );
  }

  Color _statusColor(AstrologyStatus status) {
    switch (status) {
      case AstrologyStatus.auspicious:
        return AppColors.auspicious;
      case AstrologyStatus.inauspicious:
        return AppColors.inauspicious;
      case AstrologyStatus.caution:
        return AppColors.caution;
      case AstrologyStatus.direction:
        return AppColors.direction;
      case AstrologyStatus.neutral:
        return AppColors.neutral;
      case AstrologyStatus.unknown:
      default:
        return AppColors.unknown;
    }
  }
}
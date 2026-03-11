import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/astrology/astrology_engine.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../astrology/providers/astrology_providers.dart';

class AstrologyDetailScreen extends ConsumerWidget {
  final AstrologyCard card;
  const AstrologyDetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langAsync = ref.watch(languageProvider);

    return langAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('Language error'))),
      data: (lang) {
        final isBo = lang == AppLanguage.bo;
        final title = isBo ? card.titleBo : card.titleEn;

        return Scaffold(
          backgroundColor: const Color(0xFFECE6DD),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Nyingma Calendar',
              style: TextStyle(color: Color(0xFF6A1B1A), fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF6A1B1A)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: _AstrologyDetailBody(
                  card: card,
                  title: title,
                  isBo: isBo,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AstrologyDetailBody extends ConsumerWidget {
  final AstrologyCard card;
  final String title;
  final bool isBo;

  const _AstrologyDetailBody({
    required this.card,
    required this.title,
    required this.isBo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = _providerForCard(ref, card.id);

    return provider.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
      ),
      data: (items) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            children: [
              _Header(title: title, iconKey: card.iconKey),
              AppSpacing.hMd,

              Row(
                children: [
                  _StatusChip(status: card.status),
                  const SizedBox(width: 8),
                  _ActiveChip(active: card.isActive),
                ],
              ),

              AppSpacing.hLg,

              if ((card.popupRaw ?? '').trim().isNotEmpty) ...[
                _InfoBox(text: _normalize(card.popupRaw!)),
                AppSpacing.hLg,
              ],

              _ContentByType(
                cardId: card.id,
                items: items,
                isBo: isBo,
              ),

              AppSpacing.hXxl,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isBo ? 'སྒོ་རྒྱག' : 'CLOSE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Map card.id -> provider
  AsyncValue<List<Map<String, dynamic>>> _providerForCard(WidgetRef ref, String id) {
    switch (id) {
      case 'hair_cutting':
        return ref.watch(hairCuttingProvider);
      case 'naga_day':
      case 'naga_days':
        return ref.watch(nagaDaysProvider);
      case 'fire_rituals':
      case 'fire_deity':
        return ref.watch(fireRitualProvider);
      case 'empty_vase':
      case 'empty_vase_direction_bumtong':
      case 'empty_vase_bumtong':
        return ref.watch(emptyVaseProvider);
      case 'torma_day':
      case 'torma':
      case 'torma_offering_direction':
      case 'torma_offering':
        return ref.watch(tormaOfferingProvider);
      case 'auspicious_time':
      case 'auspicious_times':
      case 'auspicious_time_periods':
        return ref.watch(auspiciousTimingProvider);
      case 'flag_avoidance':
      case 'earth_lords':
      case 'flag_day':
        return ref.watch(flagAvoidanceProvider);
      case 'restrictions':
      case 'daily_restriction':
        return ref.watch(restrictionProvider);
      case 'life_force_male':
        return ref.watch(lifeForceMAleProvider);
      case 'life_force_female':
        return ref.watch(lifeForceFemaleProvider);
      case 'horse_death':
      case 'inauspicious_day':
        return ref.watch(horseDeathProvider);
      case 'gu_mig':
        return ref.watch(guMigProvider);
      case 'fatal_weekdays':
        return ref.watch(fatalWeekdaysProvider);
      case 'parkha':
        return ref.watch(tibetanAstrologyProvider);
      default:
        // fallback
        return ref.watch(dailyAstroCardsProvider);
    }
  }

  String _normalize(String s) => s.replaceAll('\\n', '\n').trim();
}

class _Header extends StatelessWidget {
  final String title;
  final String? iconKey;

  const _Header({required this.title, this.iconKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentGold, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGold.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ClipOval(
            child: iconKey != null && iconKey!.isNotEmpty
                ? Image.asset(
                    iconKey!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.auto_awesome, color: Color(0xFF8B0000), size: 44),
                      );
                    },
                  )
                : const Center(
                    child: Icon(Icons.auto_awesome, color: Color(0xFF8B0000), size: 44),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF6A1B1A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'NYINGMA ASTROLOGICAL TRADITION',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AstrologyStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AstrologyStatus.auspicious => ('GOOD DAY', AppColors.auspicious),
      AstrologyStatus.inauspicious => ('AVOID TODAY', AppColors.inauspicious),
      AstrologyStatus.caution => ('BE CAREFUL', AppColors.caution),
      AstrologyStatus.direction => ('AUSPICIOUS DIRECTION', AppColors.direction),
      AstrologyStatus.neutral => ('NEUTRAL DAY', AppColors.neutral),
      _ => ('ASTRO STATUS', AppColors.unknown),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final bool active;
  const _ActiveChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final text = active ? 'APPLIES TODAY' : 'NOT TODAY';
    final color = active ? AppColors.auspicious : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ContentByType extends StatelessWidget {
  final String cardId;
  final List<Map<String, dynamic>> items;
  final bool isBo;

  const _ContentByType({
    required this.cardId,
    required this.items,
    required this.isBo,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _InfoBox(text: 'No data available.');
    }

    switch (cardId) {
      case 'horse_death':
        return _HorseDeathVariant(items: items);
      case 'life_force_male':
        return _LifeForceVariant(
          title: 'Table of the Movement of the Life Force (Bla) - For Men',
          imagePath: 'assets/images/astrology/bla men eng.PNG',
          items: items,
          methodTitle: 'Methods for Protecting the “La” Location',
          methodIntro: 'Men-ngag Chö-wa Ring-söl',
          methodBody:
              'Visualize the deity of the life-force at the active location. Recite the following mantra 21 times:',
          mantra1: 'Om Tsa-ka Dri De we Trig söl-hü',
          mantra2: 'Men-ngag Chö-wa Ring-söl',
        );
      case 'life_force_female':
        return _LifeForceVariant(
          title: 'Table of the Movement of the Life Force (Bla) - For Women',
          imagePath: 'assets/images/astrology/bla women eng.PNG',
          items: items,
          methodTitle: 'Methods for Protecting the “La” Location',
          methodIntro: 'Rinchen Bangzö',
          methodBody:
              'Visualize the deity of the life-force at the active location. Recite the following mantra 21 times:',
          mantra1: 'Om Tsok Ah De wa Trig söl-hü',
          mantra2: 'Men-ngag Chö-wa Ring-söl',
        );
      case 'torma_day':
      case 'torma':
        return _AstroTableVariant(
          sectionTitle: 'Monthly Torma Offering Ways (Yalam)',
          columns: const ['TIBETAN\nMONTH', 'DIRECTION', 'BEARING'],
          rows: items
              .map((it) => [
                    (it['month'] ?? '').toString(),
                    (it['direction'] ?? '').toString(),
                    (it['bearing'] ?? '').toString(),
                  ])
              .toList(),
          footerTitle: 'IMPORTANT',
          footerBody:
              'The torma of monthly lunar month offering is generally directed to the direction shown in the table.',
        );
      case 'empty_vase':
        return _AstroTableVariant(
          sectionTitle: 'Empty Vase (Bumtong) Calendar',
          columns: const ['TIBETAN\nMONTH', 'START\nDAY', 'DIRECTION\nOF EMPTY VASE'],
          rows: items
              .map((it) => [
                    (it['month'] ?? '').toString(),
                    (it['starting_day'] ?? '').toString(),
                    (it['direction'] ?? '').toString(),
                  ])
              .toList(),
          footerTitle: 'CONNECTION TO MONTHLY TORMA',
          footerBody:
              'For opening the North, East, West or South directions, align to the Empty Vase directions shown here.',
        );
      case 'auspicious_time':
      case 'auspicious_times':
        return _AstroTableVariant(
          sectionTitle: 'The Table of Auspicious Timing and Harmonious Junctions',
          columns: const ['DAY OF WEEK', 'AUSPICIOUS DAYTIME', 'AUSPICIOUS NIGHT'],
          rows: items
              .map((it) => [
                    (it['day_of_week'] ?? '').toString(),
                    (it['daytime'] ?? '').toString(),
                    (it['nighttime'] ?? '').toString(),
                  ])
              .toList(),
          footerTitle: 'IMPORTANT OBSERVATION',
          footerBody:
              'Sunday, Tuesday and Saturday are traditionally considered “harsh” days. Monday, Wednesday, Thursday and Friday have special timing windows for ritual and ordinary actions.',
        );
      case 'naga_day':
      case 'naga_days':
        return _AstroTableVariant(
          sectionTitle: 'Naga Activity Days',
          columns: const ['MONTH', 'MAJOR NAGA DAY', 'MINOR NAGA DAY'],
          rows: items
              .map((it) => [
                    (it['month_name'] ?? '').toString(),
                    (it['major_days'] ?? '').toString(),
                    (it['minor_days'] ?? '').toString(),
                  ])
              .toList(),
          footerTitle: 'CAUTION',
          footerBody:
              'On the Lu Theb (Naga) days, performing activities connected to land, digging or disturbing the ground is generally discouraged.',
        );
      case 'fire_rituals':
      case 'fire_deity':
        final description = items
            .where((it) => it.containsKey('_description'))
            .map((it) => (it['_description'] ?? '').toString())
            .firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');
        final rows = items
            .where((it) => !it.containsKey('_description'))
            .map((it) => [
                  (it['month'] ?? '').toString(),
                  (it['auspicious_dates'] ?? '').toString(),
                  (it['total_days'] ?? '').toString(),
                ])
            .toList();
        return _AstroTableVariant(
          sectionTitle: 'The Calendar Table of the Fire Deity',
          topDescription: description,
          columns: const ['TIBETAN MONTH', 'AUSPICIOUS DATES', 'TOTAL DAYS'],
          rows: rows,
        );
      case 'hair_cutting':
        return _AstroTableVariant(
          sectionTitle: 'Hair Cutting Days',
          columns: const ['DAY', 'MEANING', 'STATUS'],
          rows: items
              .map((it) => [
                    (it['day'] ?? '').toString(),
                    (it['meaning'] ?? '').toString(),
                    (it['recommendation'] ?? '').toString(),
                  ])
              .toList(),
        );
      case 'flag_avoidance':
      case 'earth_lords':
        return _AstroTableVariant(
          sectionTitle: 'Flag Avoidance Days',
          columns: const ['MONTH', 'MONTH NAME', 'AVOID DAYS'],
          rows: items
              .map((it) => [
                    (it['month'] ?? '').toString(),
                    (it['month_name'] ?? '').toString(),
                    (it['avoid_days'] ?? '').toString(),
                  ])
              .toList(),
        );
      case 'restrictions':
        return _AstroTableVariant(
          sectionTitle: 'Restriction Activities',
          columns: const ['DAYS', 'NAME', 'RESTRICTION'],
          rows: items
              .map((it) => [
                    (it['days'] ?? '').toString(),
                    (it['name'] ?? '').toString(),
                    (it['restriction'] ?? '').toString(),
                  ])
              .toList(),
        );
      case 'gu_mig':
        return _AstroTableVariant(
          sectionTitle: 'Gu Mig Table',
          columns: const ['CATEGORY', 'AGES AFFECTED', 'TOTAL'],
          rows: items
              .map((it) => [
                    (it['category'] ?? '').toString(),
                    (it['ages_affected'] ?? '').toString(),
                    (it['total'] ?? '').toString(),
                  ])
              .toList(),
        );
      case 'fatal_weekdays':
        return _AstroTableVariant(
          sectionTitle: 'Fatal Weekdays',
          columns: const ['BIRTH SIGN', 'SOUL DAY', 'FATAL DAY'],
          rows: items
              .map((it) => [
                    (it['birth_sign'] ?? '').toString(),
                    (it['soul_day'] ?? '').toString(),
                    (it['fatal_day'] ?? '').toString(),
                  ])
              .toList(),
        );
      case 'parkha':
        return _AstroTableVariant(
          sectionTitle: 'Parkha Astrology',
          columns: const ['NAME', 'DESCRIPTION', 'NOTES'],
          rows: items
              .map((it) => [
                    (it[isBo ? 'name_bo' : 'name_en'] ?? '').toString(),
                    (it[isBo ? 'description_bo' : 'description_en'] ?? '').toString(),
                    (it[isBo ? 'notes_bo' : 'notes_en'] ?? '').toString(),
                  ])
              .toList(),
        );
      default:
        return _SimpleDump(items: items);
    }
  }
}

class _AstroTableVariant extends StatelessWidget {
  final String sectionTitle;
  final String? topDescription;
  final List<String> columns;
  final List<List<String>> rows;
  final String? footerTitle;
  final String? footerBody;

  const _AstroTableVariant({
    required this.sectionTitle,
    this.topDescription,
    required this.columns,
    required this.rows,
    this.footerTitle,
    this.footerBody,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8B0000),
          ),
        ),
        const SizedBox(height: 10),
        if ((topDescription ?? '').trim().isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              topDescription!,
              style: const TextStyle(
                fontSize: 11,
                height: 1.45,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        _AstroTable(columns: columns, rows: rows),
        if ((footerBody ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _FooterNoteBox(
            title: footerTitle ?? 'NOTE',
            body: footerBody!,
          ),
        ],
      ],
    );
  }
}

class _AstroTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;

  const _AstroTable({required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2D9CF)),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF8B0000),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: columns
                  .map(
                    (label) => Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final bg = index.isEven ? const Color(0xFFFBF9F6) : const Color(0xFFF2EEEA);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                border: index == rows.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: Color(0xFFE6DED5))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(columns.length, (cellIndex) {
                  final value = cellIndex < row.length ? row[cellIndex] : '';
                  return Expanded(
                    child: Text(
                      value,
                      textAlign: cellIndex == 0 ? TextAlign.left : TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.3,
                        color: cellIndex == 0 ? const Color(0xFF8B0000) : Colors.black87,
                        fontWeight: cellIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LifeForceVariant extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<Map<String, dynamic>> items;
  final String methodTitle;
  final String methodIntro;
  final String methodBody;
  final String mantra1;
  final String mantra2;

  const _LifeForceVariant({
    required this.title,
    required this.imagePath,
    required this.items,
    required this.methodTitle,
    required this.methodIntro,
    required this.methodBody,
    required this.mantra1,
    required this.mantra2,
  });

  @override
  Widget build(BuildContext context) {
    final rows = items
        .map((it) => [
              (it['date_1_10'] ?? '').toString(),
              (it['date_11_20'] ?? '').toString(),
              (it['date_21_30'] ?? '').toString(),
            ])
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8B0000),
          ),
        ),
        const SizedBox(height: 10),
        _AstroTable(
          columns: const ['DATE 1-10', 'DATE 11-20', 'DATE 21-30'],
          rows: rows,
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGold, width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.self_improvement),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _FooterNoteBox(
          title: methodTitle,
          body: '$methodIntro\n\n$methodBody\n\n“$mantra1”\n\n$mantra2',
        ),
      ],
    );
  }
}

class _HorseDeathVariant extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _HorseDeathVariant({required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = items
        .map((it) => [
              (it['lunar_days'] ?? '').toString(),
              (it['meaning'] ?? '').toString(),
              (it['status'] ?? '').toString(),
            ])
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The Six Day Energies',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8B0000),
          ),
        ),
        const SizedBox(height: 10),
        _AstroTable(
          columns: const ['DATE', 'NAME', 'MEANING'],
          rows: rows,
        ),
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGold, width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/astrology/horse death.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _FooterNoteBox(
          title: 'INSTRUCTIONAL GUIDE',
          body:
              'The six days of lunar month are connected to potentially unstable energy points. Avoid heavy disturbance of the body and important decision making on these days.',
        ),
      ],
    );
  }
}

class _FooterNoteBox extends StatelessWidget {
  final String title;
  final String body;

  const _FooterNoteBox({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DED5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF8B0000),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 11,
              height: 1.45,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _FireRitualView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _FireRitualView({required this.items});

  @override
  Widget build(BuildContext context) {
    String? desc;
    final rows = <Map<String, dynamic>>[];
    for (final it in items) {
      if (it.containsKey('_description')) {
        desc = it['_description']?.toString();
      } else {
        rows.add(it);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((desc ?? '').trim().isNotEmpty) ...[
          _InfoBox(text: desc!.trim()),
          const SizedBox(height: 12),
        ],
        _SimpleList(
          items: rows,
          leftKey: 'month',
          titleKey: 'auspicious_dates',
          subtitleKey: 'total_days',
        ),
      ],
    );
  }
}

class _SimpleList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String leftKey;
  final String titleKey;
  final String? subtitleKey;
  final String? badgeKey;

  const _SimpleList({
    required this.items,
    required this.leftKey,
    required this.titleKey,
    this.subtitleKey,
    this.badgeKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((it) {
        final left = (it[leftKey] ?? '').toString();
        final title = (it[titleKey] ?? '').toString();
        final subtitle = subtitleKey == null ? '' : (it[subtitleKey] ?? '').toString();
        final badge = badgeKey == null ? '' : (it[badgeKey] ?? '').toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (it['image'] != null && it['image'].toString().isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      it['image'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
              SizedBox(
                width: 90,
                child: Text(
                  left,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6A1B1A), fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.35)),
                    ],
                  ],
                ),
              ),
              if (badge.trim().isNotEmpty) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentMaroon.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentMaroon)),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LifeForceView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _LifeForceView({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((it) {
        final d1 = (it['date_1_10'] ?? '').toString();
        final d2 = (it['date_11_20'] ?? '').toString();
        final d3 = (it['date_21_30'] ?? '').toString();
        final image = (it['image'] ?? '').toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d1, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(d2),
              const SizedBox(height: 4),
              Text(d3),
              if (image.isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(image, height: 90, fit: BoxFit.cover),
                )
              ]
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _HorseDeathView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _HorseDeathView({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((it) {
        final days = (it['lunar_days'] ?? '').toString();
        final meaning = (it['meaning'] ?? '').toString();
        final status = (it['status'] ?? '').toString();
        final image = (it['image'] ?? '').toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(days,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF6A1B1A))),
                  ),
                  if (status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(status,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.red)),
                    )
                ],
              ),
              const SizedBox(height: 6),
              Text(meaning),
              if (image.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(image, height: 110, fit: BoxFit.cover),
                )
              ]
            ],
          ),
        );
      }).toList(),
    );
  }
}
class _SimpleDump extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _SimpleDump({required this.items});

  @override
  Widget build(BuildContext context) {
    return _InfoBox(text: items.take(10).map((e) => e.toString()).join('\n\n'));
  }
}
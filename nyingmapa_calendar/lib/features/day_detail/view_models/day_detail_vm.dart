import '../../../domain/entities/day_entity.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../core/astrology/astrology_engine.dart';

class DayDetailVM {
  // ===== Core =====
  final DayEntity entity;
  final String dateKey;

  // ===== Gregorian =====
  final int gregorianDay;
  final int gregorianMonth;
  final int gregorianYear;
  final String? gregorianMonthLabel;
  final String? gregorianDayName;

  // ===== Tibetan =====
  final int? tibetanDay;
  final int? tibetanMonth;
  final int? tibetanYear;
  final String? tibetanMonthLabel;
  final String? tibetanDayLabel;
  final String? animalMonth;
  final String? lunarStatus;

  // ===== Hero / Visual =====
  final String? heroImageKey;
  final String? elementCombo;
  final String? coincidenceMeaning;

  // ===== Content =====
  final String? significance;
  final String? notes;

  // ===== Flags =====
  final bool showAuspiciousBadge;
  final bool hasEvents;
  final bool hasAstrology;
  final bool hasRestrictions;

  // ===== Astrology =====
  final List<AstrologyCard> astrologyCards;

  // ===== Events =====
  final List<String> eventIds;
  final List<EventEntity> events;

  const DayDetailVM({
    required this.entity,
    required this.dateKey,
    required this.gregorianDay,
    required this.gregorianMonth,
    required this.gregorianYear,
    required this.gregorianMonthLabel,
    required this.gregorianDayName,
    required this.tibetanDay,
    required this.tibetanMonth,
    required this.tibetanYear,
    required this.tibetanMonthLabel,
    required this.tibetanDayLabel,
    required this.animalMonth,
    required this.lunarStatus,
    required this.heroImageKey,
    required this.elementCombo,
    required this.coincidenceMeaning,
    required this.significance,
    required this.notes,
    required this.showAuspiciousBadge,
    required this.hasEvents,
    required this.hasAstrology,
    required this.hasRestrictions,
    required this.astrologyCards,
    required this.eventIds,
    required this.events,
  });

  factory DayDetailVM.fromData({
    required DayEntity d,
    required List<EventEntity> allEvents,
  }) {
    final resolvedEvents = allEvents
        .where((e) => d.eventIds.contains(e.id))
        .toList();

    return DayDetailVM(
      entity: d,
      dateKey: d.dateKey,

      // Gregorian
      gregorianDay: d.gregorian.day,
      gregorianMonth: d.gregorian.month,
      gregorianYear: d.gregorian.year,
      gregorianMonthLabel: d.gregorian.monthLabelEn,
      gregorianDayName: d.gregorian.dayNameEn,

      // Tibetan
      tibetanDay: d.tibetan.day,
      tibetanMonth: d.tibetan.month,
      tibetanYear: d.tibetan.year,
      tibetanMonthLabel: d.tibetan.monthLabelBo,
      tibetanDayLabel: d.tibetan.dayLabelBo,
      animalMonth: d.tibetan.animalMonthEn,
      lunarStatus: d.tibetan.lunarStatusEn,

      // Visual
      heroImageKey: d.visual.heroImageKey,
      elementCombo: d.visual.elementComboEn,
      coincidenceMeaning: d.visual.coincidenceMeaningEn,

      // Content
      significance: d.content.significanceEn,
      notes: d.content.notes,

      // Flags
      showAuspiciousBadge: d.flags.isExtremelyAuspicious,
      hasEvents: resolvedEvents.isNotEmpty,
      hasAstrology: d.flags.hasAstrology,
      hasRestrictions: d.flags.hasRestrictions,

      astrologyCards: AstrologyEngine.buildCards(d),
      eventIds: d.eventIds,
      events: resolvedEvents,
    );
  }
}
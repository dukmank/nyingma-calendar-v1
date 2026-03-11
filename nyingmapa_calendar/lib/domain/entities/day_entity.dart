/// Lightweight domain types used by the UI.
///
/// Keep these as simple, stable shapes so we can iterate fast for demo.
/// Later we can move them into their own files and add richer typing.

// Domain entities for Calendar schema v2.

class DayEntity {
  final String dateKey; // YYYY-MM-DD
  final GregorianEntity gregorian;
  final TibetanEntity tibetan;

  final DayContentEntity content;
  final DayVisualEntity visual;
  final DayExtraLabelsEntity extraLabels;

  final List<String> eventIds;
  final Map<String, AstroItemEntity> astrology;
  final DayFlagsEntity flags;

  const DayEntity({
    required this.dateKey,
    required this.gregorian,
    required this.tibetan,
    required this.content,
    required this.visual,
    required this.extraLabels,
    required this.eventIds,
    required this.astrology,
    required this.flags,
  });

  // Backward compatibility for old UI
  int get day => gregorian.day;
}

class GregorianEntity {
  final int year;
  final int month;
  final int day;
  final String? monthLabelEn;
  final String? monthLabelBo;
  final String? yearLabelBo;
  final String? dayNameEn;
  final String? dayNameBo;
  final String? dayLabelBo;

  const GregorianEntity({
    required this.year,
    required this.month,
    required this.day,
    this.monthLabelEn,
    this.monthLabelBo,
    this.yearLabelBo,
    this.dayNameEn,
    this.dayNameBo,
    this.dayLabelBo,
  });
}

class TibetanEntity {
  final int? year;
  final int? month;
  final int? day;
  final String? yearLabelBo;
  final String? monthLabelBo;
  final String? dayLabelBo;
  final String? animalMonthEn;
  final String? animalMonthBo;
  final String? lunarStatusEn;
  final String? lunarStatusBo;

  const TibetanEntity({
    this.year,
    this.month,
    this.day,
    this.yearLabelBo,
    this.monthLabelBo,
    this.dayLabelBo,
    this.animalMonthEn,
    this.animalMonthBo,
    this.lunarStatusEn,
    this.lunarStatusBo,
  });
}

class DayContentEntity {
  final String? auspiciousDayInfoEn;
  final String? auspiciousDayShortDescEn;
  final String? significanceEn;
  final String? significanceBo;
  final String? notes;

  const DayContentEntity({
    this.auspiciousDayInfoEn,
    this.auspiciousDayShortDescEn,
    this.significanceEn,
    this.significanceBo,
    this.notes,
  });
}

class DayVisualEntity {
  final String? heroImageKey;
  final String? elementComboEn;
  final String? elementComboBo;
  final String? coincidenceMeaningEn;
  final String? coincidenceMeaningBo;

  const DayVisualEntity({
    this.heroImageKey,
    this.elementComboEn,
    this.elementComboBo,
    this.coincidenceMeaningEn,
    this.coincidenceMeaningBo,
  });
}

class DayExtraLabelsEntity {
  final String? auspiciousExtraLabel1;
  final String? auspiciousExtraLabel2;
  final String? popupNagaLabel;
  final String? popupFlagLabel;
  final String? popupFireLabel;
  final String? popupTormaLabel;
  final String? popupEmptyVaseLabel;
  final String? popupHairLabel;
  final String? popupInauspiciousLabel;
  final String? popupRestrictionLabel;
  final String? popupAuspiciousTimeLabel;

  const DayExtraLabelsEntity({
    this.auspiciousExtraLabel1,
    this.auspiciousExtraLabel2,
    this.popupNagaLabel,
    this.popupFlagLabel,
    this.popupFireLabel,
    this.popupTormaLabel,
    this.popupEmptyVaseLabel,
    this.popupHairLabel,
    this.popupInauspiciousLabel,
    this.popupRestrictionLabel,
    this.popupAuspiciousTimeLabel,
  });
}

class AstroItemEntity {
  final String? raw;
  final String? statusKey;
  final String? imageKey;
  final String? popup;
  final bool isActive;

  const AstroItemEntity({
    this.raw,
    this.statusKey,
    this.imageKey,
    this.popup,
    required this.isActive,
  });
}

class DayFlagsEntity {
  final bool hasEvents;
  final String? primaryEventId;
  final bool hasAstrology;
  final bool hasRestrictions;
  final bool isExtremelyAuspicious;

  const DayFlagsEntity({
    required this.hasEvents,
    required this.primaryEventId,
    required this.hasAstrology,
    required this.hasRestrictions,
    required this.isExtremelyAuspicious,
  });

  // Backward compatibility for old UI (was isHighlight)
  bool get isHighlight => isExtremelyAuspicious;
}
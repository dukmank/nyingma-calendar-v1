import '../../domain/entities/day_entity.dart';

class DayModel {
  final String dateKey;
  final GregorianEntity gregorian;
  final TibetanEntity tibetan;
  final DayContentEntity content;
  final DayVisualEntity visual;
  final DayExtraLabelsEntity extraLabels;
  final List<String> eventIds;
  final Map<String, AstroItemEntity> astrology;
  final DayFlagsEntity flags;

  const DayModel({
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

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  static bool _asBool(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    if (v is num) return v != 0;
    return fallback;
  }

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return <String, dynamic>{};
  }

  static List<dynamic> _asList(dynamic v) {
    if (v is List) return v;
    return const [];
  }

  factory DayModel.fromJson(Map<String, dynamic> json) {
    final g = _asMap(json['gregorian']);
    final t = _asMap(json['tibetan']);
    final c = _asMap(json['content']);
    final v = _asMap(json['visual']);
    final xl = _asMap(json['extra_labels']);
    final a = _asMap(json['astrology']);
    final f = _asMap(json['flags']);

    final astroItems = <String, AstroItemEntity>{};
    for (final entry in a.entries) {
      final key = entry.key;
      final item = _asMap(entry.value);
      astroItems[key] = AstroItemEntity(
        raw: _asString(item['raw']),
        statusKey: _asString(item['status_key']),
        imageKey: _asString(item['image_key']),
        popup: _asString(item['popup']),
        isActive: _asBool(item['is_active'], fallback: true),
      );
    }

    return DayModel(
      dateKey: _asString(json['date_key']) ?? '',
      gregorian: GregorianEntity(
        year: _asInt(g['year']),
        month: _asInt(g['month']),
        day: _asInt(g['day']),
        monthLabelEn: _asString(g['month_label_en']),
        monthLabelBo: _asString(g['month_label_bo']),
        yearLabelBo: _asString(g['year_label_bo']),
        dayNameEn: _asString(g['day_name_en']),
        dayNameBo: _asString(g['day_name_bo']),
        dayLabelBo: _asString(g['day_label_bo']),
      ),
      tibetan: TibetanEntity(
        year: (t['year'] == null) ? null : _asInt(t['year']),
        month: (t['month'] == null) ? null : _asInt(t['month']),
        day: (t['day'] == null) ? null : _asInt(t['day']),
        yearLabelBo: _asString(t['year_label_bo']),
        monthLabelBo: _asString(t['month_label_bo']),
        dayLabelBo: _asString(t['day_label_bo']),
        animalMonthEn: _asString(t['animal_month_en']),
        animalMonthBo: _asString(t['animal_month_bo']),
        lunarStatusEn: _asString(t['lunar_status_en']),
        lunarStatusBo: _asString(t['lunar_status_bo']),
      ),
      content: DayContentEntity(
        auspiciousDayInfoEn: _asString(c['auspicious_day_info_en']),
        auspiciousDayShortDescEn: _asString(c['auspicious_day_short_desc_en']),
        significanceEn: _asString(c['significance_en']),
        significanceBo: _asString(c['significance_bo']),
        notes: _asString(c['notes']),
      ),
      visual: DayVisualEntity(
        heroImageKey: _asString(v['hero_image_key']),
        elementComboEn: _asString(v['element_combo_en']),
        elementComboBo: _asString(v['element_combo_bo']),
        coincidenceMeaningEn: _asString(v['coincidence_meaning_en']),
        coincidenceMeaningBo: _asString(v['coincidence_meaning_bo']),
      ),
      extraLabels: DayExtraLabelsEntity(
        auspiciousExtraLabel1: _asString(xl['auspicious_extra_label_1']),
        auspiciousExtraLabel2: _asString(xl['auspicious_extra_label_2']),
        popupNagaLabel: _asString(xl['popup_naga_label']),
        popupFlagLabel: _asString(xl['popup_flag_label']),
        popupFireLabel: _asString(xl['popup_fire_label']),
        popupTormaLabel: _asString(xl['popup_torma_label']),
        popupEmptyVaseLabel: _asString(xl['popup_empty_vase_label']),
        popupHairLabel: _asString(xl['popup_hair_label']),
        popupInauspiciousLabel: _asString(xl['popup_inauspicious_label']),
        popupRestrictionLabel: _asString(xl['popup_restriction_label']),
        popupAuspiciousTimeLabel: _asString(xl['popup_auspicious_time_label']),
      ),
      eventIds: _asList(json['event_ids']).map((e) => e.toString()).toList(),
      astrology: astroItems,
      flags: DayFlagsEntity(
        hasEvents: _asBool(f['has_events']),
        primaryEventId: _asString(f['primary_event_id']),
        hasAstrology: _asBool(f['has_astrology'], fallback: true),
        hasRestrictions: _asBool(f['has_restrictions'], fallback: false),
        isExtremelyAuspicious:
            _asBool(f['is_extremely_auspicious'], fallback: false),
      ),
    );
  }

  DayEntity toEntity() {
    return DayEntity(
      dateKey: dateKey,
      gregorian: gregorian,
      tibetan: tibetan,
      content: content,
      visual: visual,
      extraLabels: extraLabels,
      eventIds: eventIds,
      astrology: astrology,
      flags: flags,
    );
  }
}
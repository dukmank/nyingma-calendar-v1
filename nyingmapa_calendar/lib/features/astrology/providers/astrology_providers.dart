import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/json_loader.dart';

// ═══════════════════════════════════════════════════════
// ASTROLOGY DATA PROVIDERS — properly parsed per JSON
// ═══════════════════════════════════════════════════════

Future<List<dynamic>> _loadRawList(String filename) =>
    loadJsonList('assets/data/raw/$filename');


String _mainKey(Map m) => m.keys.first.toString();

// Detect Tibetan characters anywhere in a row
bool _containsTibetan(Map item) {
  final tibetanRegex = RegExp(r'[\u0F00-\u0FFF]');
  for (final v in item.values) {
    if (v != null && tibetanRegex.hasMatch(v.toString())) {
      return true;
    }
  }
  return false;
}

// ──────────────────────────────────────
// 1. Hair Cutting Days (WORKING)
// ──────────────────────────────────────
final hairCuttingProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('hair_cutting_days.json');
  final result = <Map<String, dynamic>>[];
  for (final item in items) {
    if (item is! Map) continue;
    for (final key in item.keys) {
      final val = item[key]?.toString() ?? '';
      final match = RegExp(r'Day\s+(\d+):\s+(.+)').firstMatch(val);
      if (match != null) {
        final dayNum = int.parse(match.group(1)!);
        final meaning = match.group(2)!.trim();
        final isGood = meaning.contains('Long life') || meaning.contains('Wealth') ||
            meaning.contains('Auspicious') || meaning.contains('Good') ||
            meaning.contains('Sharp') || meaning.contains('Increase') ||
            meaning.contains('Radiant') || meaning.contains('Virtue') ||
            meaning.contains('Goodness') || meaning.contains('Strength');
        final isBad = meaning.contains('sickness') || meaning.contains('Danger') ||
            meaning.contains('Fading') || meaning.contains('Disputes') ||
            meaning.contains('Loss') || meaning.contains('Infectious') ||
            meaning.contains('Conflict') || meaning.contains('wandering') ||
            meaning.contains('deceased') || meaning.contains('Problems');
        result.add({
          'day': dayNum,
          'meaning': meaning,
          'recommendation': isGood ? 'Good' : (isBad ? 'Avoid' : 'Neutral'),
        });
      }
    }
  }
  result.sort((a, b) => (a['day'] as int).compareTo(b['day'] as int));
  return result;
});

// ──────────────────────────────────────
// 2. Naga Days (WORKING)
// ──────────────────────────────────────
final nagaDaysProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('naga_days_klu_theb.json');
  final result = <Map<String, dynamic>>[];
  for (final item in items) {
    if (item is! Map) continue;
    // Skip rows that contain Tibetan text in any column
    if (_containsTibetan(item)) continue;
    final name = item[_mainKey(item)]?.toString() ?? '';
    if (name.contains('Dawa') || name.contains('dawa')) {
      result.add({
        'month_name': name,
        'major_days': item['Unnamed: 1']?.toString() ?? '',
        'minor_days': item['Unnamed: 2']?.toString() ?? '',
      });
    }
  }
  return result;
});

// ──────────────────────────────────────
// 3. Flag Avoidance / Earth Lords (WORKING)
// ──────────────────────────────────────
final flagAvoidanceProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('earth_lords_flag_days.json');
  final result = <Map<String, dynamic>>[];
  for (final item in items) {
    if (item is! Map) continue;
    // Skip rows that contain Tibetan text in any column
    if (_containsTibetan(item)) continue;
    final monthVal = item[_mainKey(item)];
    if (monthVal is int) {
      result.add({
        'month': monthVal,
        'month_name': item['Unnamed: 1']?.toString() ?? '',
        'avoid_days': item['Unnamed: 2']?.toString() ?? '',
      });
    }
  }
  return result;
});

// ──────────────────────────────────────
// 4. Restriction Activities (WORKING)
// ──────────────────────────────────────
final restrictionProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('restriction_activities.json');
  final result = <Map<String, dynamic>>[];

  for (final item in items) {
    if (item is! Map) continue;

    // Skip Tibetan rows by checking the English column only
    final tibetanRegex = RegExp(r'[\u0F00-\u0FFF]');
    final name = item['English Name']?.toString() ?? '';
    if (name.isEmpty || tibetanRegex.hasMatch(name)) continue;

    result.add({
      'days': item['Days']?.toString() ?? '',
      'name': name,
      'restriction': item['Restriction']?.toString() ?? '',
    });
  }

  return result;
});

// ──────────────────────────────────────
// 5. Auspicious Timing
// Row 0 = description, Row 1 = header, Rows 2+ = data
// ──────────────────────────────────────
final auspiciousTimingProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('auspicious_timing.json');
  final result = <Map<String, dynamic>>[];
  bool headerFound = false;
  for (final item in items) {
    if (item is! Map) continue;
    // Skip rows that contain Tibetan text in any column
    if (_containsTibetan(item)) continue;
    final mainKey = _mainKey(item);
    final val = item[mainKey]?.toString() ?? '';
    if (val.contains('Day of Week') || val.contains('Day')) {
      headerFound = true;
      continue;
    }
    if (!headerFound) continue;
    if (val.isEmpty || val == 'null') continue;
    result.add({
      'day_of_week': val,
      'daytime': item['Unnamed: 1']?.toString() ?? '',
      'nighttime': item['Unnamed: 2']?.toString() ?? '',
    });
  }
  return result;
});

// ──────────────────────────────────────
// 6. Fire Ritual (Fire Deity)
// Row 0-2 = descriptions, Row 3 = header (Tibetan Month/Auspicious Dates/Total Days)
// ──────────────────────────────────────
final fireRitualProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('fire_rituals.json');
  final result = <Map<String, dynamic>>[];
  bool headerFound = false;
  String description = '';
  final tibetanRegex = RegExp(r'[\u0F00-\u0FFF]');
  for (final item in items) {
    if (item is! Map) continue;
    final mainKey = _mainKey(item);
    final val = item[mainKey];
    final valStr = val?.toString() ?? '';
    if (tibetanRegex.hasMatch(valStr)) continue;
    if (valStr.contains('Tibetan Month')) {
      headerFound = true;
      continue;
    }
    if (!headerFound) {
      // Capture description
      if (valStr.isNotEmpty && valStr != 'null' && description.isEmpty) {
        description = valStr;
      }
      continue;
    }
    if (val == null) continue;
    result.add({
      'month': val is int ? 'Month $val' : valStr,
      'auspicious_dates': item['Unnamed: 1']?.toString() ?? '',
      'total_days': item['Unnamed: 2']?.toString() ?? '',
    });
  }
  // Add description as first item if available
  if (description.isNotEmpty) {
    result.insert(0, {'_description': description});
  }
  return result;
});

// ──────────────────────────────────────
// 7. Empty Vase (Bumtong) (WORKING)
// ──────────────────────────────────────
final emptyVaseProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('empty_vase_bumtong.json');
  final result = <Map<String, dynamic>>[];

  for (final item in items) {
    if (item is! Map) continue;

    final mainKey = _mainKey(item);
    final monthCell = item[mainKey]?.toString().trim() ?? '';

    // Extract month number from strings like "1st Month", "2nd Month", etc.
    final match = RegExp(r'^(\d{1,2})(st|nd|rd|th)?\s*Month', caseSensitive: false)
        .firstMatch(monthCell);

    if (match == null) continue;

    final month = match.group(1);

    result.add({
      'month': month,
      'starting_day': item['Unnamed: 1']?.toString() ?? '',
      'direction': item['Unnamed: 2']?.toString() ?? '',
    });
  }

  return result;
});

// ──────────────────────────────────────
// 8. Life Force Male
// Row 3 = header ("Date 1-10", "Date 11-20", "Date 21-30")
// Rows 4+ = data like "1: Big toe", "11: Forearm", "21: Ribs"
// ──────────────────────────────────────
final lifeForceMAleProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('life_force_male.json');
  return _parseLifeForce(items);
});

// ──────────────────────────────────────
// 9. Life Force Female
// ──────────────────────────────────────
final lifeForceFemaleProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('life_force_female.json');
  return _parseLifeForce(items);
});

List<Map<String, dynamic>> _parseLifeForce(List<dynamic> items) {
  final result = <Map<String, dynamic>>[];
  bool headerFound = false;
  for (final item in items) {
    if (item is! Map) continue;
    // Skip Tibetan rows entirely
    if (_containsTibetan(item)) continue;
    final mainKey = _mainKey(item);
    final val = item[mainKey]?.toString() ?? '';
    if (val.contains('Date 1') || val.contains('Day')) {
      headerFound = true;
      continue;
    }
    if (!headerFound) continue;
    if (val.isEmpty || val == 'null') continue;
    // Parse "1: Big toe" format from 3 columns
    final col1 = val;
    final col2 = item['Unnamed: 1']?.toString() ?? '';
    final col3 = item['Unnamed: 2']?.toString() ?? '';
    result.add({
      'date_1_10': col1,
      'date_11_20': col2,
      'date_21_30': col3,
    });
  }
  return result;
}

// ──────────────────────────────────────
// 10. Horse Death (Ta Shi)
// Row 2 = header ("Lunar Day", "Meaning", "Status")
// Row 3+ = "1,7,13,19,25" / "Goddess Palthang" / "extremely auspicious"
// ──────────────────────────────────────
final horseDeathProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('horse_death_ta_shi.json');
  final result = <Map<String, dynamic>>[];
  bool headerFound = false;
  for (final item in items) {
    if (item is! Map) continue;
    // Skip rows that contain Tibetan text in any column
    if (_containsTibetan(item)) continue;
    final mainKey = _mainKey(item);
    final val = item[mainKey]?.toString() ?? '';
    if (val == 'Lunar Day') {
      headerFound = true;
      continue;
    }
    if (!headerFound) continue;
    if (val.isEmpty || val == 'null') continue;
    result.add({
      'lunar_days': val,
      'meaning': item['Unnamed: 1']?.toString() ?? '',
      'status': item['Unnamed: 2']?.toString() ?? '',
    });
  }
  return result;
});

// ──────────────────────────────────────
// 11. Gu Mig
// Row 3 = header ("Category", "Ages Affected...", "Total Ages")
// Rows 4-7 = EN data, Row 9-13 = BO data
// ──────────────────────────────────────
final guMigProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('gu_mig.json');
  final result = <Map<String, dynamic>>[];
  bool headerFound = false;
  for (final item in items) {
    if (item is! Map) continue;
    // Skip rows that contain Tibetan text in any column
    if (_containsTibetan(item)) continue;
    final mainKey = _mainKey(item);
    final val = item[mainKey]?.toString() ?? '';
    if (val.contains('Category') || val.contains('དབྱེ་བ')) {
      headerFound = true;
      continue;
    }
    if (!headerFound) continue;
    if (val.isEmpty || val == 'null') continue;
    result.add({
      'category': val,
      'ages_affected': item['Unnamed: 1']?.toString() ?? '',
      'total': item['Unnamed: 2']?.toString() ?? '',
    });
  }
  return result;
});

// ──────────────────────────────────────
// 12. Fatal Weekdays
// Row 3 = header ("Birth Sign", "Soul & Life-Force (auspicious)", "Fatal Day (Inauspicious)")
// ──────────────────────────────────────
final fatalWeekdaysProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('fatal_weekdays.json');
  final result = <Map<String, dynamic>>[];
  bool headerFound = false;
  for (final item in items) {
    if (item is! Map) continue;
    // Skip rows that contain Tibetan text in any column
    if (_containsTibetan(item)) continue;
    final mainKey = _mainKey(item);
    final val = item[mainKey]?.toString() ?? '';
    if (val.contains('Birth Sign') || val.contains('སྐྱེ་བའི')) {
      headerFound = true;
      continue;
    }
    if (!headerFound) continue;
    if (val.isEmpty || val == 'null') continue;
    result.add({
      'birth_sign': val,
      'soul_day': item['Unnamed: 1']?.toString() ?? '',
      'fatal_day': item['Unnamed: 2']?.toString() ?? '',
    });
  }
  return result;
});

// ──────────────────────────────────────
// 13. Torma Offering (WORKING)
// ──────────────────────────────────────
final tormaOfferingProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('torma_offering.json');
  final result = <Map<String, dynamic>>[];
  bool headerFound = false;
  for (final item in items) {
    if (item is! Map) continue;
    // Skip rows that contain Tibetan text in any column
    if (_containsTibetan(item)) continue;
    final mainKey = _mainKey(item);
    final val = item[mainKey];
    final valStr = val?.toString() ?? '';
    if (valStr.contains('Tibetan Month')) {
      headerFound = true;
      continue;
    }
    if (!headerFound) continue;
    if (val == null) continue;
    result.add({
      'month': val.toString(),
      'direction': item['Unnamed: 1']?.toString() ?? '',
      'bearing': item['Unnamed: 2']?.toString() ?? '',
    });
  }
  return result;
});

// ──────────────────────────────────────
// 14. Tibetan Astrology (comprehensive)
// Row 0 = header mapping, Rows 1+ = data
// ──────────────────────────────────────
final tibetanAstrologyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('tibetan_astrology.json');
  final result = <Map<String, dynamic>>[];
  for (int i = 1; i < items.length; i++) {
    final item = items[i];
    if (item is! Map) continue;
    final mainKey = _mainKey(item);
    final name = item[mainKey]?.toString() ?? '';
    if (name.isEmpty || name == 'null') continue;
    result.add({
      'name_en': name,
      'name_bo': item['Unnamed: 1']?.toString() ?? '',
      'image': item['Unnamed: 2']?.toString() ?? '',
      'description_en': item['Unnamed: 4']?.toString() ?? '',
      'description_bo': item['Unnamed: 5']?.toString() ?? '',
      'notes_en': item['Unnamed: 12']?.toString() ?? '',
      'notes_bo': item['Unnamed: 13']?.toString() ?? '',
    });
  }
  return result;
});

// ──────────────────────────────────────
// 15. Daily Astrological Cards (9)
// ──────────────────────────────────────
final dailyAstroCardsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final items = await _loadRawList('9_daily_astrological_cards.json');
  return items.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
});

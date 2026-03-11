import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/json_loader.dart';

// ─── Month Parsing Helpers ──────────────────────────────────────────────
int? _parseMonthValue(dynamic raw) {
  if (raw == null) return null;
  final value = raw.toString().trim();
  if (value.isEmpty) return null;

  final direct = int.tryParse(value);
  if (direct != null) return direct;

  final lower = value.toLowerCase();
  const monthMap = {
    '1': 1,
    'first': 1,
    'chu dawa': 1,
    'chu-dawa': 1,
    '2': 2,
    'second': 2,
    'wo dawa': 2,
    'wo-dawa': 2,
    'dbo dawa': 2,
    'dbo-dawa': 2,
    '3': 3,
    'third': 3,
    'nagpa dawa': 3,
    'nagpa-dawa': 3,
    'nag dawa': 3,
    'nag-dawa': 3,
    '4': 4,
    'fourth': 4,
    'saga dawa': 4,
    'saga-dawa': 4,
    'sa ga dawa': 4,
    'sa-ga dawa': 4,
    '5': 5,
    'fifth': 5,
    'nön dawa': 5,
    'non dawa': 5,
    'nön-dawa': 5,
    'non-dawa': 5,
    'snron dawa': 5,
    'snron-dawa': 5,
    '6': 6,
    'sixth': 6,
    'chutö dawa': 6,
    'chuto dawa': 6,
    'chutö-dawa': 6,
    'chuto-dawa': 6,
    'chu stod': 6,
    'chu-stod': 6,
    '7': 7,
    'seventh': 7,
    'drozhin dawa': 7,
    'drozhin-dawa': 7,
    'gro bzhin': 7,
    'gro-bzhin': 7,
    '8': 8,
    'eighth': 8,
    'trum dawa': 8,
    'trum-dawa': 8,
    'khrums': 8,
    '9': 9,
    'ninth': 9,
    'takar dawa': 9,
    'takar-dawa': 9,
    'tha skar': 9,
    'tha-skar': 9,
    '10': 10,
    'tenth': 10,
    'mindrug dawa': 10,
    'mindrug-dawa': 10,
    'smin drug': 10,
    'smin-drug': 10,
    '11': 11,
    'eleventh': 11,
    'go dawa': 11,
    'go-dawa': 11,
    'mgo': 11,
    '12': 12,
    'twelfth': 12,
    'gyal dawa': 12,
    'gyal-dawa': 12,
    'rgyal': 12,
  };

  return monthMap[lower];
}

String _normalizedMonthLabel(dynamic raw) {
  final value = raw?.toString().trim() ?? '';
  if (value.isEmpty) return 'all';
  return value;
}

/// Auspicious Day entity
class AuspiciousDayEntity {
  final String month;
  final int? monthNumber;
  final int day;
  final String nameEn;
  final String nameBo;
  final String shortDescriptionEn;
  final String shortDescriptionBo;
  final String descriptionEn;
  final String descriptionBo;

  AuspiciousDayEntity({
    required this.month,
    required this.monthNumber,
    required this.day,
    required this.nameEn,
    required this.nameBo,
    required this.shortDescriptionEn,
    required this.shortDescriptionBo,
    required this.descriptionEn,
    required this.descriptionBo,
  });

  factory AuspiciousDayEntity.fromJson(Map<String, dynamic> json) {
    final rawMonth = json[' Month'] ?? json['Month'];
    final rawNameEn = json['English Name']?.toString().trim() ?? '';
    final rawNameBo = json['Tibetan Name']?.toString().trim() ?? '';

    return AuspiciousDayEntity(
      month: _normalizedMonthLabel(rawMonth),
      monthNumber: _parseMonthValue(rawMonth),
      day: json['Day'] is int ? json['Day'] : (int.tryParse(json['Day']?.toString() ?? '') ?? 0),
      nameEn: rawNameEn,
      nameBo: rawNameBo,
      shortDescriptionEn: json['Short Description']?.toString().trim() ?? '',
      shortDescriptionBo: json['Short Description (Tibetan)']?.toString().trim() ?? '',
      descriptionEn: json['English Description']?.toString().trim() ?? '',
      descriptionBo: json['Tibetan Description']?.toString().trim() ?? '',
    );
  }
}

/// Load auspicious days from JSON
final auspiciousDaysFutureProvider = FutureProvider<List<AuspiciousDayEntity>>((ref) async {
  final data = await loadJsonList('assets/data/raw/auspicious_days_reference.json');
  final items = data as List<dynamic>? ?? [];

  final result = items
      .whereType<Map>()
      .map((e) => AuspiciousDayEntity.fromJson(e.cast<String, dynamic>()))
      .where((e) {
        final lowerEn = e.nameEn.toLowerCase();
        return e.day > 0 &&
            (e.nameEn.isNotEmpty || e.nameBo.isNotEmpty) &&
            !lowerEn.contains('manifestation name') &&
            !lowerEn.contains('english name');
      })
      .toList();

  result.sort((a, b) {
    final monthCompare = (a.monthNumber ?? 99).compareTo(b.monthNumber ?? 99);
    if (monthCompare != 0) return monthCompare;
    return a.day.compareTo(b.day);
  });

  // Ensure canonical Tibetan lunar auspicious days always exist
  const canonicalDays = {
    8:  {'en': 'Medicine Buddha Day', 'bo': 'སྨན་བླའི་ཉིན།'},
    10: {'en': 'Guru Rinpoche Day',  'bo': 'གུ་རུ་རིན་པོ་ཆེའི་ཉིན།'},
    15: {'en': 'Full Moon Day',      'bo': 'ཟླ་བ་ཉ་ཚེས།'},
    25: {'en': 'Dakini Day',         'bo': 'མཁའ་འགྲོའི་ཉིན།'},
    29: {'en': 'Protector Day',      'bo': 'སྲུང་མའི་ཉིན།'},
  };

  final existingDays = result.map((e) => e.day).toSet();

  for (final entry in canonicalDays.entries) {
    if (!existingDays.contains(entry.key)) {
      result.add(
        AuspiciousDayEntity(
          month: 'all',
          monthNumber: null,
          day: entry.key,
          nameEn: entry.value['en']!,
          nameBo: entry.value['bo']!,
          shortDescriptionEn: '',
          shortDescriptionBo: '',
          descriptionEn: '',
          descriptionBo: '',
        ),
      );
    }
  }

  // Re-sort after injecting canonical entries
  result.sort((a, b) {
    final monthCompare = (a.monthNumber ?? 99).compareTo(b.monthNumber ?? 99);
    if (monthCompare != 0) return monthCompare;
    return a.day.compareTo(b.day);
  });

  return result;
});

/// Get auspicious days for a specific month (or 'all')
final auspiciousDaysByMonthProvider = FutureProvider.family<List<AuspiciousDayEntity>, String>((ref, month) async {
  final allDays = await ref.watch(auspiciousDaysFutureProvider.future);
  if (month == 'all') return allDays;

  final targetNum = int.tryParse(month);
  return allDays.where((d) {
    if (d.month == 'all') return true;
    if (targetNum != null) return d.monthNumber == targetNum;
    return d.month.trim().toLowerCase() == month.trim().toLowerCase();
  }).toList();
});

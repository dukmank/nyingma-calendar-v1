import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/json_loader.dart';

/// Naga Days entity
class NagaDaysEntity {
  final int month;
  final String monthNameEn;
  final String monthNameBo;
  final String majorDays;
  final String minorDays;

  NagaDaysEntity({
    required this.month,
    required this.monthNameEn,
    required this.monthNameBo,
    required this.majorDays,
    required this.minorDays,
  });
}

/// Load Naga Days from JSON
final nagaDaysFutureProvider = FutureProvider<List<NagaDaysEntity>>((ref) async {
  final data = await loadJsonList('assets/data/raw/naga_days_klu_theb.json');
  final items = data as List<dynamic>? ?? [];
  final result = <NagaDaysEntity>[];

  // Data rows start at index 3 (after header rows)
  for (int i = 3; i < items.length; i++) {
    final item = items[i];
    if (item is! Map) continue;

    final monthStr = item['NAGA DAYS (ཟླ་བ།)']?.toString() ?? '';
    if (monthStr.isEmpty) continue;

    // Parse month name to extract month number
    final monthMatch = RegExp(r'(\d+)(?:st|nd|rd|th)').firstMatch(monthStr);
    final monthNum = monthMatch != null ? int.parse(monthMatch.group(1)!) : 0;

    if (monthNum >= 1 && monthNum <= 12) {
      result.add(NagaDaysEntity(
        month: monthNum,
        monthNameEn: monthStr,
        monthNameBo: '',
        majorDays: item['Unnamed: 1']?.toString() ?? '',
        minorDays: item['Unnamed: 2']?.toString() ?? '',
      ));
    }
  }

  result.sort((a, b) => a.month.compareTo(b.month));
  return result;
});

/// Get Naga Days for a specific month
final nagaDaysByMonthProvider = FutureProvider.family<NagaDaysEntity?, int>((ref, month) async {
  final allDays = await ref.watch(nagaDaysFutureProvider.future);
  return allDays.firstWhere((d) => d.month == month, orElse: () => null as NagaDaysEntity);
});

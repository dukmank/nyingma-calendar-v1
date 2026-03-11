import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/json_loader.dart';

/// Flag Avoidance Days entity
class FlagAvoidanceEntity {
  final int month;
  final String monthNameEn;
  final String monthNameBo;
  final String avoidDays;

  FlagAvoidanceEntity({
    required this.month,
    required this.monthNameEn,
    required this.monthNameBo,
    required this.avoidDays,
  });
}

/// Load Flag Avoidance Days from JSON
final flagAvoidanceFutureProvider = FutureProvider<List<FlagAvoidanceEntity>>((ref) async {
  final data = await loadJsonList('assets/data/raw/earth_lords_flag_days.json');
  final items = data as List<dynamic>? ?? [];
  final result = <FlagAvoidanceEntity>[];

  // Data rows start at index 3 (after header rows)
  for (int i = 3; i < items.length; i++) {
    final item = items[i];
    if (item is! Map) continue;

    final monthVal = item['FLAG DAYS - AVOID HANGING PRAYER FLAGS (༈ ས་བདག་བ་དན།)'];
    if (monthVal is! int) continue;

    result.add(FlagAvoidanceEntity(
      month: monthVal,
      monthNameEn: item['Unnamed: 1']?.toString() ?? '',
      monthNameBo: '',
      avoidDays: item['Unnamed: 2']?.toString() ?? '',
    ));
  }

  result.sort((a, b) => a.month.compareTo(b.month));
  return result;
});

/// Get Flag Avoidance for a specific month
final flagAvoidanceByMonthProvider = FutureProvider.family<FlagAvoidanceEntity?, int>((ref, int month) async {
  final allDays = await ref.watch(flagAvoidanceFutureProvider.future);
  return allDays.firstWhere((d) => d.month == month, orElse: () => null as FlagAvoidanceEntity);
});

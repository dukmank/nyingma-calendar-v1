import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyingmapa_calendar/domain/entities/day_entity.dart';
import 'calendar_provider.dart';

/// Holds currently selected dateKey (YYYY-MM-DD)
final selectedDateKeyProvider =
    StateProvider<String?>((ref) => null);

/// Derive selected DayEntity from current month data
final selectedDayEntityProvider =
    FutureProvider<DayEntity?>((ref) async {
  final selectedKey = ref.watch(selectedDateKeyProvider);
  if (selectedKey == null) return null;

  final repo = ref.read(calendarRepoProvider);
  return repo.getDay(selectedKey);
});

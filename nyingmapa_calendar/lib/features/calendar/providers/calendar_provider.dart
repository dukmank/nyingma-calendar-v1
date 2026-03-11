import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/repositories/calendar_repository.dart';
import '../../../data/repositories/calendar_repository_impl.dart';
import '../../../data/datasources/calendar_local_ds.dart';
import '../view_models/calendar_day_vm.dart';
import 'month_state_provider.dart';

/// Repository
final calendarRepoProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl(CalendarLocalDataSource());
});


/// Month data provider (reacts to year/month change)
final currentMonthProvider =
    FutureProvider<List<CalendarDayVM>>((ref) async {
  final repo = ref.read(calendarRepoProvider);

  final monthState = ref.watch(monthStateProvider);

  final entities =
      await repo.getMonth(monthState.year, monthState.month);

  return entities
      .map((e) => CalendarDayVM.fromEntity(e))
      .toList();
});
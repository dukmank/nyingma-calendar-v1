import '../../domain/entities/day_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_ds.dart';
import '../models/day_model.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource local;

  CalendarRepositoryImpl(this.local);

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val));
    }
    return <String, dynamic>{};
  }

  @override
  Future<List<DayEntity>> getMonth(int year, int month) async {
    final raw = await local.loadMonth(year, month);
    final daysMap = _asMap(raw['days']);

    final result = daysMap.entries
        .where((e) => e.value is Map)
        .map((e) => DayModel.fromJson(_asMap(e.value)).toEntity())
        .toList();

    return result;
  }

  @override
  Future<DayEntity?> getDay(String dateKey) async {
    final parts = dateKey.split('-');
    if (parts.length < 2) return null;

    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;

    if (year == 0 || month == 0) return null;

    final monthRaw = await local.loadMonth(year, month);
    final daysMap = _asMap(monthRaw['days']);
    final dayJson = daysMap[dateKey];

    if (dayJson is Map) {
      final safeMap = dayJson is Map<String, dynamic>
          ? dayJson
          : dayJson.map((k, v) => MapEntry(k.toString(), v));

      final model = DayModel.fromJson(safeMap);
      return model.toEntity();
    }

    return null;
  }
}
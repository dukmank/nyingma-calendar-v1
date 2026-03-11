import '../entities/day_entity.dart';

abstract class CalendarRepository {
  Future<List<DayEntity>> getMonth(int year, int month);
  Future<DayEntity?> getDay(String dateKey);
}
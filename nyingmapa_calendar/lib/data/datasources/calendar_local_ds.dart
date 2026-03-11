import 'json_loader.dart';

class CalendarLocalDataSource {
  Future<Map<String, dynamic>> loadMonth(int year, int month) =>
      loadJsonMap('assets/data/calendar/$year/${year}_${month.toString().padLeft(2, '0')}.json');

  Future<Map<String, dynamic>> loadEventsMaster() =>
      loadJsonMap('assets/data/events/events_master.json');
}
import 'json_loader.dart';

class EventLocalDataSource {
  Future<Map<String, dynamic>> loadMaster() =>
      loadJsonMap('assets/data/events/events_master.json');
}
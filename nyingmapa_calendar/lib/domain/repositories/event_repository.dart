import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<EventEntity?> getById(String id);
  Future<List<EventEntity>> getByDate(String dateKey);

  /// Used for Events tab (load all events)
  Future<List<EventEntity>> getAll();
}
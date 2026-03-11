
import '../datasources/event_local_ds.dart';

import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  Map<String, dynamic>? _cache;

  final EventLocalDataSource _localDs = EventLocalDataSource();

  Future<Map<String, dynamic>> _loadMaster() async {
    if (_cache != null) return _cache!;

    final decoded = await _localDs.loadMaster();
    _cache = decoded;
    return decoded;
  }

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val));
    }
    return <String, dynamic>{};
  }

  String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
  }

  EventEntity? _mapToEntity(String id, Map<String, dynamic> json) {
    final title = _asMap(json['title']);
    final details = _asMap(json['details']);
    final assets = _asMap(json['assets']);

    return EventEntity(
      id: _asString(json['id']) ?? id,
      dateKey: _asString(json['date_key']) ?? '',
      titleEn: _asString(title['en']) ?? '',
      titleBo: _asString(title['bo']),
      detailsEn: _asString(details['en']),
      detailsBo: _asString(details['bo']),
      imageKey: _asString(
        assets['hero_key'] ?? assets['thumbnail_key'],
      ),
    );
  }

  @override
  Future<EventEntity?> getById(String id) async {
    final master = await _loadMaster();
    final byId = _asMap(master['by_id']);

    final raw = byId[id];
    if (raw is! Map) return null;

    final json = _asMap(raw);
    return _mapToEntity(id, json);
  }

  @override
  Future<List<EventEntity>> getByDate(String dateKey) async {
    final master = await _loadMaster();

    final byDate = _asMap(master['by_date']);
    final byId = _asMap(master['by_id']);

    final ids = byDate[dateKey];
    if (ids is! List) return [];

    final results = <EventEntity>[];

    for (final id in ids) {
      final raw = byId[id];
      if (raw is Map) {
        final json = _asMap(raw);
        final entity = _mapToEntity(id.toString(), json);
        if (entity != null) {
          results.add(entity);
        }
      }
    }

    return results;
  }
  @override
  Future<List<EventEntity>> getAll() async {
    final master = await _loadMaster();

    final items = master['items'];
    if (items is! List) return [];

    final results = <EventEntity>[];

    for (final raw in items) {
      if (raw is Map) {
        final json = _asMap(raw);
        final id = _asString(json['id']) ?? '';
        final entity = _mapToEntity(id, json);
        if (entity != null) {
          results.add(entity);
        }
      }
    }

    return results;
  }
}
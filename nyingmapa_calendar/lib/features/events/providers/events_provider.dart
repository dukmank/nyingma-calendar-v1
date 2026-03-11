import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/event_local_ds.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../data/models/event_model.dart';

final _eventLocalDsProvider = Provider((ref) => EventLocalDataSource());

/// Load all events from events_master.json
final eventsMasterFutureProvider =
    FutureProvider<List<EventEntity>>((ref) async {
  final ds = ref.read(_eventLocalDsProvider);
  final raw = await ds.loadMaster();

  // events_master.json has both 'items' array and 'by_id' map
  // Use 'items' first, fallback to 'by_id' values
  List<dynamic> items = [];
  
  if (raw['items'] != null && raw['items'] is List) {
    items = raw['items'] as List<dynamic>;
  } else if (raw['by_id'] != null && raw['by_id'] is Map) {
    items = (raw['by_id'] as Map).values.toList();
  }

  final result = <EventEntity>[];
  for (final item in items) {
    if (item is! Map) continue;
    try {
      final model = EventModel.fromJson(
        item.cast<String, dynamic>(),
      );
      if (model.titleEn.isNotEmpty) {
        result.add(model.toEntity());
      }
    } catch (_) {
      // Skip malformed entries
    }
  }

  // Sort by date
  result.sort((a, b) => a.dateKey.compareTo(b.dateKey));
  return result;
});

/// Events filtered by month
final eventsByMonthProvider =
    FutureProvider.family<List<EventEntity>, int>((ref, month) async {
  final all = await ref.watch(eventsMasterFutureProvider.future);
  return all.where((e) {
    if (e.dateKey.length >= 7) {
      final m = int.tryParse(e.dateKey.substring(5, 7));
      return m == month;
    }
    return false;
  }).toList();
});

/// Optimized lookup map (O(1) access by id)
final eventsMapProvider =
    FutureProvider<Map<String, EventEntity>>((ref) async {
  final list = await ref.watch(eventsMasterFutureProvider.future);
  return {
    for (final e in list) e.id: e,
  };
});
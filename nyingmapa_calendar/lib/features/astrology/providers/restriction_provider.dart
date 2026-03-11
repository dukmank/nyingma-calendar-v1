import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/json_loader.dart';

/// Restriction Activity entity
class RestrictionEntity {
  final String days;
  final String nameEn;
  final String nameBo;
  final String restrictionEn;
  final String restrictionBo;

  RestrictionEntity({
    required this.days,
    required this.nameEn,
    required this.nameBo,
    required this.restrictionEn,
    required this.restrictionBo,
  });
}

/// Load Restriction Activities from JSON
final restrictionsFutureProvider = FutureProvider<List<RestrictionEntity>>((ref) async {
  final data = await loadJsonList('assets/data/raw/restriction_activities.json');
  final items = data as List<dynamic>? ?? [];

  final result = items
      .whereType<Map>()
      .where((e) {
        final name = e['English Name']?.toString() ?? '';
        // Skip Tibetan header row
        return name.isNotEmpty && name != 'མིང་བྱང་།';
      })
      .map((e) => RestrictionEntity(
        days: e['Days']?.toString() ?? '',
        nameEn: e['English Name']?.toString() ?? '',
        nameBo: '',
        restrictionEn: e['Restriction']?.toString() ?? '',
        restrictionBo: '',
      ))
      .toList();

  return result;
});

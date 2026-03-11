import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/json_loader.dart';

/// Hair Cutting Day entity
class HairCuttingDayEntity {
  final int lunarDay;
  final String meaningEn;
  final String meaningBo;
  final String recommendation;

  HairCuttingDayEntity({
    required this.lunarDay,
    required this.meaningEn,
    required this.meaningBo,
    required this.recommendation,
  });
}

/// Parse hair cutting days from the special format
final hairCuttingDaysFutureProvider = FutureProvider<List<HairCuttingDayEntity>>((ref) async {
  final data = await loadJsonList('assets/data/raw/hair_cutting_days.json');
  final items = data as List<dynamic>? ?? [];
  final result = <HairCuttingDayEntity>[];

  // Parse the special format: "Day N: meaning"
  for (final item in items.whereType<Map>()) {
    for (final key in ['HAIR CUTTING DAYS (Tra Yi - སྐྲ་ཡྱི་)', 'Unnamed: 1', 'Unnamed: 2']) {
      final val = item[key]?.toString() ?? '';
      final match = RegExp(r'Day\s+(\d+):\s+(.+)').firstMatch(val);
      if (match != null) {
        final dayNum = int.parse(match.group(1)!);
        final meaning = match.group(2)!.trim();

        // Determine recommendation based on meaning
        final isGood = meaning.contains('Long life') || meaning.contains('Wealth') ||
            meaning.contains('Auspicious') || meaning.contains('Good') ||
            meaning.contains('Sharp') || meaning.contains('Increase') ||
            meaning.contains('Radiant') || meaning.contains('Great influence') ||
            meaning.contains('Virtue') || meaning.contains('Goodness') ||
            meaning.contains('Strength') || meaning.contains('food & drink');
        final isBad = meaning.contains('sickness') || meaning.contains('Danger') ||
            meaning.contains('Fading') || meaning.contains('Disputes') ||
            meaning.contains('Loss') || meaning.contains('Infectious') ||
            meaning.contains('Conflict') || meaning.contains('wandering') ||
            meaning.contains('deceased') || meaning.contains('Problem') ||
            meaning.contains('Sickness');

        result.add(HairCuttingDayEntity(
          lunarDay: dayNum,
          meaningEn: meaning,
          meaningBo: '',
          recommendation: isGood ? 'Good' : (isBad ? 'Avoid' : 'Neutral'),
        ));
      }
    }
  }

  result.sort((a, b) => a.lunarDay.compareTo(b.lunarDay));
  return result;
});

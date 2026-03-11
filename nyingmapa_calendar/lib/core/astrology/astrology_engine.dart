import '../../domain/entities/day_entity.dart';

/// UI-ready structured model for one astrology card.
class AstrologyCard {
  final String id; // e.g. naga_day, fire_rituals
  final String titleEn;
  final String titleBo;
  final AstrologyStatus status;
  final String? iconKey;
  final bool isActive;
  final String? popupRaw; // keep raw popup for now (can structure later)

  const AstrologyCard({
    required this.id,
    required this.titleEn,
    required this.titleBo,
    required this.status,
    required this.iconKey,
    required this.isActive,
    required this.popupRaw,
  });
}

/// Strongly typed status instead of raw string
enum AstrologyStatus {
  auspicious,
  inauspicious,
  caution,
  neutral,
  direction,
  unknown,
}

class AstrologyEngine {
  /// Stable UI order independent of backend key order
  static const List<String> _priorityOrder = [
    'naga_day',
    'fire_rituals',
    'torma_day',
    'empty_vase',
    'hair_cutting',
    'auspicious_time',
  ];
  /// Main entry: convert raw day.astrology map into structured cards.
  static List<AstrologyCard> buildCards(DayEntity day) {
    final entries = day.astrology.entries.toList();

    final cards = entries.map((entry) {
      final key = entry.key;
      final item = entry.value;

      return AstrologyCard(
        id: key,
        titleEn: _titleEn(key),
        titleBo: _titleBo(key),
        status: _mapStatus(item.statusKey),
        iconKey: item.imageKey,
        isActive: item.isActive,
        popupRaw: item.popup,
      );
    }).toList();

    // Enforce stable UI order independent of backend key order
    cards.sort((a, b) {
      final aIndex = _priorityOrder.indexOf(a.id);
      final bIndex = _priorityOrder.indexOf(b.id);

      // If both exist in priority list, sort by defined order
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }

      // If only one exists in priority list, it comes first
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;

      // Fallback: alphabetical for unknown keys
      return a.id.compareTo(b.id);
    });

    return cards;
  }

  /// Map backend status_key to strongly typed enum
  static AstrologyStatus _mapStatus(String? raw) {
    switch (raw) {
      case 'auspicious':
        return AstrologyStatus.auspicious;
      case 'inauspicious':
      case 'avoid':
        return AstrologyStatus.inauspicious;
      case 'caution':
        return AstrologyStatus.caution;
      case 'direction':
        return AstrologyStatus.direction;
      case 'neutral':
        return AstrologyStatus.neutral;
      default:
        return AstrologyStatus.unknown;
    }
  }

  /// Temporary title mapping (can later move to reference.json driven config)
  static String _titleEn(String key) {
    switch (key) {
      case 'naga_day':
        return 'Naga Day';
      case 'fire_rituals':
        return 'Fire Rituals';
      case 'torma_day':
        return 'Torma Day';
      case 'empty_vase':
        return 'Empty Vase';
      case 'hair_cutting':
        return 'Hair Cutting';
      case 'auspicious_time':
        return 'Auspicious Time';
      default:
        return key;
    }
  }

  static String _titleBo(String key) {
    switch (key) {
      case 'naga_day':
        return 'ཀླུ་གཏོར་ཉིན་';
      case 'fire_rituals':
        return 'མེ་ཆོག';
      case 'torma_day':
        return 'གཏོར་མའི་ཉིན་';
      case 'empty_vase':
        return 'བུམ་པ་སྟོང་པ';
      case 'hair_cutting':
        return 'སྐྲ་བཞག';
      case 'auspicious_time':
        return 'དུས་བཟང་';
      default:
        return key;
    }
  }
}
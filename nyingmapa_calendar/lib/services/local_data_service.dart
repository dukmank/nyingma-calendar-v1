import 'dart:convert';
import 'package:flutter/services.dart';

/// Local data service that reads JSON files from assets
/// Replaces the HTTP-based ApiService with local data
class LocalDataService {
  // Cache for loaded data
  static Map<String, dynamic>? _eventsCache;
  static final Map<String, Map<String, dynamic>> _calendarCache = {};

  /// Load and parse a JSON asset file as Map
  static Future<Map<String, dynamic>> _loadJsonMap(String path) async {
    final raw = await rootBundle.loadString(path);
    return json.decode(raw) as Map<String, dynamic>;
  }

  /// Load and parse a JSON asset file as List
  static Future<List<dynamic>> _loadJsonList(String path) async {
    final raw = await rootBundle.loadString(path);
    return json.decode(raw) as List<dynamic>;
  }

  /// Load events master data (cached)
  static Future<Map<String, dynamic>> _loadEventsMaster() async {
    _eventsCache ??= await _loadJsonMap('assets/data/events/events_master.json');
    return _eventsCache!;
  }

  /// Load calendar month data (cached)
  static Future<Map<String, dynamic>> _loadCalendarMonth(int year, int month) async {
    final key = '${year}_${month.toString().padLeft(2, '0')}';
    if (!_calendarCache.containsKey(key)) {
      try {
        _calendarCache[key] = await _loadJsonMap(
            'assets/data/calendar/$year/$key.json');
      } catch (_) {
        _calendarCache[key] = {'days': {}};
      }
    }
    return _calendarCache[key]!;
  }

  // ─── Calendar ──────────────────────────────────
  static Future<List<Map<String, dynamic>>> getCalendarMonth(int year, int month) async {
    try {
      final data = await _loadCalendarMonth(year, month);
      final days = data['days'] as Map<String, dynamic>? ?? {};
      return days.entries
          .where((e) => e.value is Map)
          .map((e) {
            final day = Map<String, dynamic>.from(e.value as Map);
            day['date_key'] = e.key;
            return _flattenDay(day);
          })
          .toList()
        ..sort((a, b) => (a['gregorian_date'] ?? 0).compareTo(b['gregorian_date'] ?? 0));
    } catch (_) {
      return [];
    }
  }

    /// Get raw (unflattened) calendar day data with all astrology/extra_labels
  static Future<Map<String, dynamic>?> getRawCalendarDay(String dateStr) async {
    try {
      final parts = dateStr.split('-');
      if (parts.length < 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final data = await _loadCalendarMonth(year, month);
      final days = data['days'] as Map<String, dynamic>? ?? {};
      final dayData = days[dateStr];
      if (dayData is Map) {
        final day = Map<String, dynamic>.from(dayData);
        day['date_key'] = dateStr;
        return day;
      }
    } catch (_) {}
    return null;
  }

  /// Get event by ID
  static Future<Map<String, dynamic>?> getEventById(String eventId) async {
    try {
      final master = await _loadEventsMaster();
      final byId = master['by_id'] as Map<String, dynamic>? ?? {};
      final event = byId[eventId];
      if (event is Map) {
        return _flattenEvent(Map<String, dynamic>.from(event));
      }
    } catch (_) {}
    return null;
  }

  /// Get multiple events by their IDs
  static Future<List<Map<String, dynamic>>> getEventsByIds(List<String> ids) async {
    final results = <Map<String, dynamic>>[];
    for (final id in ids) {
      final ev = await getEventById(id);
      if (ev != null) results.add(ev);
    }
    return results;
  }

  static Future<Map<String, dynamic>?> getCalendarDay(String dateStr) async {
    try {
      final parts = dateStr.split('-');
      if (parts.length < 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final data = await _loadCalendarMonth(year, month);
      final days = data['days'] as Map<String, dynamic>? ?? {};
      final dayData = days[dateStr];
      if (dayData is Map) {
        final day = Map<String, dynamic>.from(dayData);
        day['date_key'] = dateStr;
        return _flattenDay(day);
      }
    } catch (_) {}
    return null;
  }

  /// Flatten nested day structure to match what existing UI expects
  static Map<String, dynamic> _flattenDay(Map<String, dynamic> raw) {
    final gregorian = _asMap(raw['gregorian']);
    final tibetan = _asMap(raw['tibetan']);
    final content = _asMap(raw['content']);
    final visual = _asMap(raw['visual']);
    final flags = _asMap(raw['flags']);

    return {
      'date_key': raw['date_key'] ?? '',
      'gregorian_year': gregorian['year'],
      'gregorian_month': gregorian['month'],
      'gregorian_date': gregorian['day'],
      'day_name': gregorian['day_name_en'],
      'tibetan_year': tibetan['year'],
      'tibetan_month': tibetan['month'],
      'tibetan_day': tibetan['day'],
      'animal': tibetan['animal_month_en'] ?? 'Dragon',
    'animal_bo': tibetan['animal_month_bo'] ?? 'འབྲུག་ཟླ།',
      'lunar_phase': tibetan['lunar_status_en'] ?? 'NORMAL',
      'hero_image': visual['hero_image_key'],
      'element': visual['element_combo_en'] ?? 'Earth-Fire',
      'auspicious_day_info': content['auspicious_day_info_en'],
      'significance': content['significance_en'],
      'has_events': flags['has_events'] ?? false,
      'event_ids': raw['event_ids'] ?? [],
      'is_auspicious': flags['is_extremely_auspicious'] ?? false,
    };
  }

  // ─── Events ────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getEvents({String? lineage, int? month}) async {
    try {
      final master = await _loadEventsMaster();
      final byId = master['by_id'] as Map<String, dynamic>? ?? {};

      final events = byId.values
          .whereType<Map>()
          .map((e) => _flattenEvent(Map<String, dynamic>.from(e)))
          .toList();

      // Filter by month if provided
      if (month != null) {
        return events.where((e) {
          final dateKey = e['date_key'] as String? ?? '';
          if (dateKey.length >= 7) {
            final eventMonth = int.tryParse(dateKey.substring(5, 7));
            return eventMonth == month;
          }
          return false;
        }).toList();
      }

      return events;
    } catch (_) {
      return [];
    }
  }

  /// Flatten event structure to match what existing UI expects
  static Map<String, dynamic> _flattenEvent(Map<String, dynamic> raw) {
    final title = _asMap(raw['title']);
    final details = _asMap(raw['details']);
    final category = _asMap(raw['category']);
    final assets = _asMap(raw['assets']);

    return {
      'id': raw['id'] ?? '',
      'date_key': raw['date_key'] ?? '',
      'western_date': raw['date_key'] ?? '',
      'title_en': title['en'] ?? '',
      'title_bo': title['bo'] ?? '',
      'details_en': details['en'] ?? '',
      'details_bo': details['bo'] ?? '',
      'description_en': details['en'] ?? '',
      'category_en': category['en'] ?? '',
      'category_bo': category['bo'] ?? '',
      'lineage': 'all',
      'image_path': _resolveImagePath(assets['thumbnail_key'] ?? assets['hero_key']),
    };
  }

  /// Try to resolve image path from a key
  static String _resolveImagePath(dynamic key) {
    if (key == null) return 'others/guru.jpg';
    final k = key.toString().toLowerCase().replaceAll(' ', '_');
    // Events
    if (k == 'losar') return 'events 2/Losar.PNG';
    if (k.contains('chotrul')) return 'events 2/chotrul duchen.png';
    if (k.contains('chokhor')) return 'Events 3/Chokhor Duchen.PNG';
    if (k.contains('monlam')) return 'Events 3/Monlam Chenmo.PNG';
    if (k.contains('nine_bad')) return 'Events 3/Nine Bad Omens.PNG';
    if (k.contains('zangpo')) return 'Events 3/Zangpo Chu Dzom.PNG';
    if (k == 'sawa_dawa') return 'Events 3/sawa dawa.PNG';
    if (k.contains('sawadawa')) return 'events 2/sawadawaduchen.png';
    if (k.contains('incense')) return 'events 2/incense.PNG';
    if (k.contains('black_hat')) return 'events 2/Black Hat Vajra Dance.PNG';
    if (k.contains('cham')) return 'events 2/Cham Dance.PNG';
    if (k.contains('drubchen')) return 'events 2/Drubchen.PNG';
    if (k.contains('gutor')) return 'events 2/Gutor Commencement.PNG';
    if (k.contains('krodhikali')) return 'events 2/Krodhikali .PNG';
    if (k.contains('torma_repel')) return 'events 2/Torma Repelling.PNG';
    if (k.contains('translated_words')) return 'events 2/Translated Words of the Buddha.PNG';
    // Birthday images
    if (k.contains('dungse_garab')) return 'Birthday/Birthday of Kyabje Dungse Garab Rinpoche.PNG';
    if (k.contains('yangshi_dungse')) return 'Birthday/Birthday. of Kyabje Yangshi Dungse Gyana ta Rinpoche.PNG';
    if (k.contains('gold_medal')) return 'Birthday/gold_medal_westerndate.PNG';
    if (k.contains('yangsi_drub')) return 'Birthday/yangsi Drubwang.png';
    if (k == 'img_1776') return 'Birthday/IMG_1776.PNG';
    if (k == 'img_1777') return 'Birthday/IMG_1777.PNG';
    if (k == 'img_1779') return 'Birthday/IMG_1779.PNG';
    if (k == 'img_1780') return 'Birthday/IMG_1780.PNG';
    if (k == 'img_1781') return 'Birthday/IMG_1781.PNG';
    if (k == 'img_1782') return 'Birthday/IMG_1782.PNG';
    if (k == 'img_1783') return 'Birthday/IMG_1783.PNG';
    if (k == 'img_1785') return 'Birthday/IMG_1785.PNG';
    if (k == 'img_1786') return 'Birthday/IMG_1786.PNG';
    if (k == 'img_1787') return 'Birthday/IMG_1787.PNG';
    if (k == 'img_1789') return 'Birthday/IMG_1789.PNG';
    // Others / Lamas
    if (k == 'img_1903') return 'others/IMG_1903.JPG';
    if (k == 'img_1904' || k == 'guru') return 'others/IMG_1904.PNG';
    if (k == 'img_7180') return 'others/IMG_7180.JPG';
    if (k.contains('odisha')) return 'others/OdishaDudjom.JPG';
    if (k.contains('d576094b')) return 'others/d576094b-5120-4556-9241-964905b095c2.jpg';
    // Parinirvana / specific lamas
    if (k.contains('kyabjepenor')) return 'parinirvana/KyabjePenor.PNG';
    if (k.contains('parinirvana')) return 'parinirvana/KyabjePenor.PNG';
    // Auspicious days
    if (k.contains('fullmoon') || k.contains('vesak')) return 'Auspicious days/fullmoon.PNG';
    if (k.contains('newmoon')) return 'Auspicious days/newmoon.PNG';
    if (k.contains('dakini')) return 'Auspicious days/dakini.PNG';
    if (k.contains('medicine')) return 'Auspicious days/medicinebuddha.PNG';
    if (k.contains('dharma') || k.contains('protector')) return 'Auspicious days/dharmaprotector.PNG';
    // Lama name fallbacks (use parinirvana folder where available)
    if (k.contains('dudjomlingpa')) return 'parinirvana/DudjomLingpa.PNG';
    if (k.contains('dudjomrinpoche')) return 'parinirvana/DudjomRinpoche.PNG';
    if (k.contains('yangsidudjom')) return 'parinirvana/YangsiDudjom.PNG';
    if (k.contains('dudjom')) return 'parinirvana/DudjomRinpoche.PNG';
    if (k.contains('dilgokhyentse') || k.contains('dilgo')) return 'parinirvana/DilgoKhyentse.PNG';
    if (k.contains('jamyang_khyentse') || k.contains('jamyang')) return 'parinirvana/Jamyang Khyentse Wangpo .PNG';
    if (k.contains('longchenrabjam') || k.contains('longchen')) return 'parinirvana/LongchenRabjam.PNG';
    if (k.contains('jigmelingpa') || k.contains('jigmeling')) return 'parinirvana/JigmeLingpa-BookLaunch.PNG';
    if (k.contains('chatralsangye') || k.contains('chatral')) return 'parinirvana/ChatralSangye.PNG';
    if (k.contains('nyoshulkhen') || k.contains('nyoshul')) return 'parinirvana/NyoshulKhen.PNG';
    if (k.contains('jigmephuntsok')) return 'parinirvana/JigmePhuntsok.PNG';
    if (k.contains('jumipham')) return 'parinirvana/JuMipham.PNG';
    if (k.contains('minlingtrichen') || k.contains('minling')) return 'parinirvana/MinlingTrichen.JPG';
    if (k.contains('minlngterchen')) return 'parinirvana/MinlngTerchen.PNG';
    if (k.contains('rabjam_gyurme') || k.contains('rabjam')) return 'parinirvana/Rabjam Gyurme.PNG';
    if (k.contains('taklungtsetrul') || k.contains('taklung')) return 'parinirvana/TaklungTsetrul.PNG';
    if (k.contains('tertonmingyur')) return 'parinirvana/TertonMingyur.PNG';
    if (k.contains('thinleynorbu') || k.contains('thinley')) return 'parinirvana/ThinleyNorbu.PNG';
    if (k.contains('thulshekripoche') || k.contains('thulshek')) return 'parinirvana/ThulshekRipoche.PNG';
    if (k.contains('yangthangrinpoche') || k.contains('yangthang')) return 'parinirvana/YangthangRinpoche.PNG';
    if (k.contains('zhenphendawa')) return 'parinirvana/ZhenphenDawa.PNG';
    if (k.contains('dodrupchen')) return 'parinirvana/Dodrupchen.PNG';
    // Generic
    if (k.contains('birthday') || k.contains('birth')) return 'Birthday/IMG_1780.PNG';
    if (k.contains('guru')) return 'others/IMG_1904.PNG';
    if (k.contains('saga')) return 'Auspicious days/fullmoon.PNG';
    return 'others/guru.jpg';
  }

  // ─── Auspicious Days ───────────────────────────
  static Future<List<Map<String, dynamic>>> getAuspiciousDays() async {
    try {
      final items = await _loadJsonList('assets/data/raw/auspicious_days_reference.json');
      // Filter out null, header, and "Month" rows
      return items
          .whereType<Map>()
          .where((e) {
            final name = e['English Name'];
            return name != null && name.toString().isNotEmpty &&
                   name != 'Manifestation Name (English)';
          })
          .map((e) => <String, dynamic>{
            'name_en': e['English Name']?.toString()?.trim() ?? '',
            'name_bo': e['Tibetan Name']?.toString() ?? '',
            'tibetan_day_number': e['Day'] is int ? e['Day'] : int.tryParse(e['Day']?.toString() ?? '') ?? 0,
            'tibetan_day_bo': e['Day (tibetan)']?.toString() ?? '',
            'month': e[' Month'],  // note: leading space in key
            'description_en': e['Short Description']?.toString() ?? '',
            'description_bo': e['Short Description (Tibetan)']?.toString() ?? '',
            'practices_en': e['English Description']?.toString() ?? '',
            'practices_bo': e['Tibetan Description']?.toString() ?? '',
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getNextAuspiciousDay() async => null;

  // ─── Astrology ─────────────────────────────────
  static Future<List<Map<String, dynamic>>> getHairCuttingDays() async {
    try {
      final items = await _loadJsonList('assets/data/raw/hair_cutting_days.json');
      final result = <Map<String, dynamic>>[];

      // Parse the special format: "Day N: meaning"
      for (final item in items) {
        if (item is! Map) continue;
        for (final key in [
          'HAIR CUTTING DAYS (Tra Yi - སྐྲ་ཡྱི་)',
          'Unnamed: 1',
          'Unnamed: 2'
        ]) {
          final val = item[key]?.toString() ?? '';
          final match = RegExp(r'Day\s+(\d+):\s+(.+)').firstMatch(val);
          if (match != null) {
            final dayNum = int.parse(match.group(1)!);
            final meaning = match.group(2)!.trim();
            final isGood = meaning.contains('Long life') ||
                meaning.contains('Wealth') ||
                meaning.contains('Auspicious') ||
                meaning.contains('Good') ||
                meaning.contains('Sharp') ||
                meaning.contains('Increase') ||
                meaning.contains('Radiant') ||
                meaning.contains('Great influence') ||
                meaning.contains('happy') ||
                meaning.contains('Virtue') ||
                meaning.contains('Goodness') ||
                meaning.contains('Strength');
            final isBad = meaning.contains('sickness') ||
                meaning.contains('Danger') ||
                meaning.contains('Fading') ||
                meaning.contains('Disputes') ||
                meaning.contains('Loss') ||
                meaning.contains('Infectious') ||
                meaning.contains('Conflict') ||
                meaning.contains('wandering') ||
                meaning.contains('deceased') ||
                meaning.contains('Problems');

            result.add({
              'tibetan_day': dayNum,
              'meaning_en': meaning,
              'recommendation': isGood ? 'Good' : (isBad ? 'Avoid' : 'Neutral'),
            });
          }
        }
      }
      result.sort((a, b) => (a['tibetan_day'] as int).compareTo(b['tibetan_day'] as int));
      return result;
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getGuruManifestation(int month) async => null;

  static Future<Map<String, dynamic>?> getNagaDays(int month) async {
    try {
      final items = await _loadJsonList('assets/data/raw/naga_days_klu_theb.json');
      // Data rows start at index 3 (after header rows), months 1-12
      final dataRows = items.where((e) {
        if (e is! Map) return false;
        final name = e['NAGA DAYS (ཟླ་བ།)']?.toString() ?? '';
        return name.contains('Dawa') || name.contains('Dawa');
      }).toList();

      // Month index (0-based in the filtered list)
      if (month < 1 || month > dataRows.length) return null;
      final row = dataRows[month - 1] as Map;
      return {
        'tibetan_month': month,
        'major_days': row['Unnamed: 1']?.toString() ?? '',
        'minor_days': row['Unnamed: 2']?.toString() ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getFlagAvoidance(int month) async {
    try {
      final items = await _loadJsonList('assets/data/raw/earth_lords_flag_days.json');
      // Data rows with numeric month start at index 3
      final dataRows = items.where((e) {
        if (e is! Map) return false;
        final monthVal = e['FLAG DAYS - AVOID HANGING PRAYER FLAGS (༈ ས་བདག་བ་དན།)'];
        return monthVal is int;
      }).toList();

      final row = dataRows.firstWhere(
        (e) => (e as Map)['FLAG DAYS - AVOID HANGING PRAYER FLAGS (༈ ས་བདག་བ་དན།)'] == month,
        orElse: () => null,
      );
      if (row == null) return null;

      return {
        'tibetan_month': month,
        'month_name': (row as Map)['Unnamed: 1']?.toString() ?? '',
        'avoid_days': row['Unnamed: 2']?.toString() ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getDailyRestrictions() async {
    try {
      final items = await _loadJsonList('assets/data/raw/restriction_activities.json');
      return items
          .whereType<Map>()
          .where((e) {
            final name = e['English Name'];
            return name != null && name.toString().isNotEmpty &&
                   name != 'མིང་བྱང་།';  // skip Tibetan header
          })
          .map((e) => <String, dynamic>{
            'days': e['Days']?.toString() ?? '',
            'name': e['English Name']?.toString() ?? '',
            'restriction': e['Restriction']?.toString() ?? '',
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Practices (local-only features) ─────────
  static final List<Map<String, dynamic>> _userPractices = [];

  static Future<Map<String, dynamic>?> getPracticeStats() async {
    return {
      "total": _userPractices.length,
    };
  }

  static Future<List<Map<String, dynamic>>> getUserPractices() async {
    return List<Map<String, dynamic>>.from(_userPractices);
  }

  static Future<bool> createUserPractice(Map<String, dynamic> practice) async {
    final newPractice = Map<String, dynamic>.from(practice);

    // ensure ID is always a string so UI + repositories read it consistently
    newPractice["id"] = DateTime.now().millisecondsSinceEpoch.toString();

    _userPractices.add(newPractice);
    return true;
  }

  static Future<bool> deleteUserPractice(int id) async {
    _userPractices.removeWhere((e) => e["id"] == id);
    return true;
  }

  static Future<bool> trackPractice(String name, String date, bool completed) async {
    return true;
  }

  static Future<bool> updatePractice(int id, Map<String, dynamic> data) async {
    final index = _userPractices.indexWhere((e) => e["id"] == id);
    if (index == -1) return false;

    _userPractices[index] = {..._userPractices[index], ...data};
    return true;
  }

  // ─── User Events (local-only) ──────────────

static final List<Map<String, dynamic>> _userEvents = [];

static Future<List<Map<String, dynamic>>> getUserEvents() async {
  return List<Map<String, dynamic>>.from(_userEvents);
}

static Future<bool> createUserEvent(Map<String, dynamic> event) async {
  final newEvent = Map<String, dynamic>.from(event);

  newEvent["id"] = DateTime.now().millisecondsSinceEpoch;

  _userEvents.add(newEvent);

  return true;
}

static Future<bool> deleteUserEvent(int id) async {
  _userEvents.removeWhere((e) => e["id"] == id);
  return true;
}

  // ─── Profile (local-only) ───────────────────
  static Map<String, dynamic>? _profile;

  static Future<Map<String, dynamic>?> getProfile() async {
    return _profile;
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    _profile = {...?_profile, ...data};
    return true;
  }

  // ─── Bodhisattva Practices ─────────────────
  static Future<List<Map<String, dynamic>>> getBodhisattvaPractices() async => [];

  // ─── Helpers ───────────────────────────────
  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return <String, dynamic>{};
  }
}
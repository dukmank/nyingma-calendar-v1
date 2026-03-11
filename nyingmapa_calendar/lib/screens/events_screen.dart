import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../features/events/providers/events_provider.dart';
import '../domain/entities/event_entity.dart';
import '../services/theme_provider.dart';
import '../services/translations.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  int _selectedMonth = 0; // 0 = All

  static const _monthsEn = [
    'All', 'January', 'February', 'March', 'April', 'May',
    'June', 'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _monthsBo = [
    'ཚང་མ།', 'ཟླ་དང་པོ།', 'ཟླ་གཉིས་པ།', 'ཟླ་གསུམ་པ།', 'ཟླ་བཞི་པ།', 'ཟླ་ལྔ་པ།',
    'ཟླ་དྲུག་པ།', 'ཟླ་བདུན་པ།', 'ཟླ་བརྒྱད་པ།', 'ཟླ་དགུ་པ།', 'ཟླ་བཅུ་པ།', 'ཟླ་བཅུ་གཅིག', 'ཟླ་བཅུ་གཉིས།',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final isTibetan = lang == 'bo';
    final eventsAsync = ref.watch(eventsMasterFutureProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(T.t('yearly_events', isTibetan), style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.navy,
                  )),
                  const Spacer(),
                  Text(isTibetan ? 'དུས་ཆེན་བཙལ།' : 'Filter Events by', style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white38 : const Color(0xFF999999),
                  )),
                ],
              ),
            ),

            // ─── Month Filter Chips ────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 0, 10),
              child: SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _monthsEn.length,
                  itemBuilder: (_, i) {
                    final isSelected = i == _selectedMonth;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMonth = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.maroon : (isDark ? AppColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? null : Border.all(color: AppColors.maroon.withOpacity(0.25)),
                        ),
                        child: Text(isTibetan ? _monthsBo[i] : _monthsEn[i], style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.navy),
                        )),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ─── Content ─────────────────────
            Expanded(
              child: eventsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.maroon)),
                error: (e, st) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.maroon),
                      const SizedBox(height: 8),
                      Text(isTibetan ? 'དུས་ཆེན་མནན་མ་ཐུབ།' : 'Error loading events', style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.navy,
                      )),
                      const SizedBox(height: 4),
                      Text('$e', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
                data: (events) {
                  // Filter events to only those with valid date_key (yyyy-MM-dd)
                  var filtered = events.where((e) => e.dateKey.length >= 7).toList();

                  // Apply month filter
                  if (_selectedMonth > 0) {
                    filtered = filtered.where((e) {
                      final m = int.tryParse(e.dateKey.substring(5, 7));
                      return m == _selectedMonth;
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_busy, size: 48, color: AppColors.lightTextSecondary),
                          const SizedBox(height: 8),
                          Text(isTibetan ? 'དུས་ཆེན་མ་རྙེད།' : 'No events found', style: TextStyle(color: AppColors.lightTextSecondary)),
                        ],
                      ),
                    );
                  }

                  // Group by month
                  final grouped = <int, List<EventEntity>>{};
                  for (final e in filtered) {
                    final m = int.tryParse(e.dateKey.substring(5, 7)) ?? 0;
                    grouped.putIfAbsent(m, () => []).add(e);
                  }

                  final sortedMonths = grouped.keys.toList()..sort();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: sortedMonths.length,
                    itemBuilder: (_, secIndex) {
                      final month = sortedMonths[secIndex];
                      final monthEvents = grouped[month]!;
                      final monthName = isTibetan ? _monthsBo[month] : _getMonthName(month);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month header with divider
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 4, left: 4),
                            child: Text(monthName.toUpperCase(), style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                              color: AppColors.maroon.withOpacity(0.7),
                            )),
                          ),
                          Divider(color: AppColors.maroon.withOpacity(0.12), height: 1, thickness: 1),
                          const SizedBox(height: 10),
                          // Event cards
                          ...monthEvents.map((event) => _eventCard(event, isDark, isTibetan)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return 'Unknown';
    }
  }

  /// Convert a date_key like "2026-07-06" to a styled date string "Jul 06, 2026"
  String _formatSolarDate(String dateKey) {
    try {
      final dt = DateTime.parse(dateKey);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
    } catch (_) {
      return dateKey;
    }
  }

  /// Derive a rough Tibetan lunar date from the solar date
  /// This is approximate - in reality it would come from the calendar data
  String _deriveLunarDate(String dateKey) {
    try {
      final dt = DateTime.parse(dateKey);
      // Approximate: Tibetan months are roughly 1 month behind solar
      // This is a simplified mapping for display
      int lunarMonth = dt.month - 1;
      int lunarDay = dt.day;
      if (lunarMonth <= 0) lunarMonth = 12;

      String monthStr;
      switch (lunarMonth) {
        case 1: monthStr = '1st Month'; break;
        case 2: monthStr = '2nd Month'; break;
        case 3: monthStr = '3rd Month'; break;
        default: monthStr = '${lunarMonth}th Month'; break;
      }

      String dayStr;
      switch (lunarDay) {
        case 1: dayStr = '1st Day'; break;
        case 2: dayStr = '2nd Day'; break;
        case 3: dayStr = '3rd Day'; break;
        default: dayStr = '${lunarDay}th Day'; break;
      }

      return '$monthStr, $dayStr';
    } catch (_) {
      return '';
    }
  }

  Widget _eventCard(EventEntity event, bool isDark, bool isTibetan) {
    final title = isTibetan ? (event.titleBo ?? event.titleEn) : event.titleEn;
    final imgPath = _resolveEventImage(event.imageKey);
    final solarDate = _formatSolarDate(event.dateKey);
    final lunarDate = _deriveLunarDate(event.dateKey);

    final labelColor = isDark ? Colors.white38 : const Color(0xFF9E9E9E);
    final solarDateColor = isDark ? Colors.white70 : const Color(0xFF333333);

    return GestureDetector(
      onTap: () => _showEventDetail(context, event, isDark, isTibetan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 60, height: 60,
                color: AppColors.cream,
                child: Image.asset(
                  imgPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.maroon.withOpacity(0.08),
                    child: Icon(Icons.event, color: AppColors.maroon, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(title, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  // Solar Calendar row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(isTibetan ? 'ཉི་མའི་\nཟླ་ཐོ།' : 'SOLAR\nCALENDAR', style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: 0.8,
                          color: labelColor,
                        )),
                      ),
                      Text(solarDate, style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: solarDateColor,
                      )),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Lunar Calendar row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(isTibetan ? 'ཟླ་བའི་ཟླ་ཐོ།' : 'LUNAR CALENDAR', style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: 0.8,
                          color: labelColor,
                        )),
                      ),
                      Text(lunarDate, style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.maroon,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white24 : const Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  /// Map thumbnail_key → actual asset path
  String _resolveEventImage(String? key) {
    if (key == null || key.isEmpty) return 'assets/images/others/guru.jpg';
    final k = key.toLowerCase().replaceAll(' ', '');

    // Exact thumbnail_key mappings from events_master.json
    final exactMap = <String, String>{
      'losar': 'assets/images/Events 3/Losar.PNG',
      'chotrul_duchen': 'assets/images/events 2/chotrul duchen.png',
      'guru': 'assets/images/others/guru.jpg',
      'minlingtrichen': 'assets/images/parinirvana/MinlingTrichen.JPG',
      'jamyang_khyentse_wangpo': 'assets/images/parinirvana/Jamyang Khyentse Wangpo .PNG',
      'drubchen': 'assets/images/events 2/Drubchen.PNG',
      'cham_dance': 'assets/images/events 2/Cham Dance.PNG',
      'kyabjepenor': 'assets/images/parinirvana/KyabjePenor.PNG',
      'odishadudjom': 'assets/images/others/OdishaDudjom.JPG',
      'minlngterchen': 'assets/images/parinirvana/MinlngTerchen.PNG',
      'krodhikali': 'assets/images/events 2/Krodhikali .PNG',
      'd576094b_5120_4556_9241_964905b095c2': 'assets/images/others/d576094b-5120-4556-9241-964905b095c2.jpg',
      'img_1779': 'assets/images/Birthday/IMG_1779.PNG',
      'zhenphendawa': 'assets/images/parinirvana/ZhenphenDawa.PNG',
      'tertonmingyur': 'assets/images/parinirvana/TertonMingyur.PNG',
      'torma_repelling': 'assets/images/events 2/Torma Repelling.PNG',
      'sawa_dawa': 'assets/images/Events 3/sawa dawa.PNG',
      'sawadawaduchen': 'assets/images/events 2/sawadawaduchen.png',
      'jumipham': 'assets/images/parinirvana/JuMipham.PNG',
      'img_1777': 'assets/images/Birthday/IMG_1777.PNG',
      'img_1904': 'assets/images/Guru Rinpoche 12 manefistation/IMG_1904.PNG',
      'translated_words_of_the_buddha': 'assets/images/events 2/Translated Words of the Buddha.PNG',
      'incense': 'assets/images/events 2/incense.PNG',
      'img_1780': 'assets/images/Birthday/IMG_1780.PNG',
      'chokhor_duchen': 'assets/images/events 2/Chokhor Duchen .PNG',
      'img_1781': 'assets/images/Birthday/IMG_1781.PNG',
      'nyoshulkhen': 'assets/images/parinirvana/NyoshulKhen.PNG',
      'thulshekripoche': 'assets/images/parinirvana/ThulshekRipoche.PNG',
      'longchenrabjam': 'assets/images/parinirvana/LongchenRabjam.PNG',
      'dudjomrinpoche': 'assets/images/parinirvana/DudjomRinpoche.PNG',
      'dilgokhyentse': 'assets/images/parinirvana/DilgoKhyentse.PNG',
      'dodrupchen': 'assets/images/parinirvana/Dodrupchen.PNG',
      'dudjomlingpa': 'assets/images/parinirvana/DudjomLingpa.PNG',
      'jigmelingpa': 'assets/images/parinirvana/JigmeLingpa-BookLaunch.PNG',
      'jigmephuntsok': 'assets/images/parinirvana/JigmePhuntsok.PNG',
      'taklung_tsetrul': 'assets/images/parinirvana/TaklungTsetrul.PNG',
      'thinleynorbu': 'assets/images/parinirvana/ThinleyNorbu.PNG',
      'yangthangrinpoche': 'assets/images/parinirvana/YangthangRinpoche.PNG',
      'img_1782': 'assets/images/Birthday/IMG_1782.PNG',
      'img_1783': 'assets/images/Birthday/IMG_1783.PNG',
      'img_1785': 'assets/images/Birthday/IMG_1785.PNG',
      'img_1786': 'assets/images/Birthday/IMG_1786.PNG',
      'img_1787': 'assets/images/Birthday/IMG_1787.PNG',
      'img_1789': 'assets/images/Birthday/IMG_1789.PNG',
      'img_1776': 'assets/images/Birthday/IMG_1776.PNG',
      'monlam_chenmo': 'assets/images/Events 3/Monlam Chenmo.PNG',
      'gutor_commencement': 'assets/images/events 2/Gutor Commencement.PNG',
      'black_hat_vajra_dance': 'assets/images/events 2/Black Hat Vajra Dance.PNG',
      'zangpo_chu_dzom': 'assets/images/Events 3/Zangpo Chu Dzom.PNG',
    };

    if (exactMap.containsKey(k)) return exactMap[k]!;

    // Fuzzy fallback
    for (final entry in exactMap.entries) {
      if (k.contains(entry.key) || entry.key.contains(k)) return entry.value;
    }

    return 'assets/images/others/guru.jpg';
  }

  void _showEventDetail(BuildContext context, EventEntity event, bool isDark, bool isTibetan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _EventDetailPage(
          event: event,
          isDark: isDark,
          isTibetan: isTibetan,
          resolveImage: _resolveEventImage,
          formatSolarDate: _formatSolarDate,
          deriveLunarDate: _deriveLunarDate,
        ),
      ),
    );
  }
}

// ─── Full‑screen Event Detail Page ────────────────────────────────────────────

class _EventDetailPage extends StatelessWidget {
  final EventEntity event;
  final bool isDark;
  final bool isTibetan;
  final String Function(String?) resolveImage;
  final String Function(String) formatSolarDate;
  final String Function(String) deriveLunarDate;

  const _EventDetailPage({
    required this.event,
    required this.isDark,
    required this.isTibetan,
    required this.resolveImage,
    required this.formatSolarDate,
    required this.deriveLunarDate,
  });

  String _formatFullSolarDate(String dateKey) {
    try {
      final dt = DateTime.parse(dateKey);
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];

      String daySuffix;
      if (dt.day == 1 || dt.day == 21 || dt.day == 31) {
        daySuffix = 'st';
      } else if (dt.day == 2 || dt.day == 22) {
        daySuffix = 'nd';
      } else if (dt.day == 3 || dt.day == 23) {
        daySuffix = 'rd';
      } else {
        daySuffix = 'th';
      }

      return '$dayName - $monthName ${dt.day}$daySuffix - ${dt.year}';
    } catch (_) {
      return dateKey;
    }
  }

  String _formatFullLunarDate(String dateKey) {
    try {
      final dt = DateTime.parse(dateKey);
      int lunarMonth = dt.month - 1;
      int lunarDay = dt.day;
      if (lunarMonth <= 0) lunarMonth = 12;

      // Tibetan year is ~127 years ahead for the Rabjung cycle
      int tibYear = dt.year + 27;

      String daySuffix;
      if (lunarDay == 1 || lunarDay == 21 || lunarDay == 31) {
        daySuffix = 'st';
      } else if (lunarDay == 2 || lunarDay == 22) {
        daySuffix = 'nd';
      } else if (lunarDay == 3 || lunarDay == 23) {
        daySuffix = 'rd';
      } else {
        daySuffix = 'th';
      }

      String monthSuffix;
      if (lunarMonth == 1 || lunarMonth == 21) {
        monthSuffix = 'st';
      } else if (lunarMonth == 2 || lunarMonth == 22) {
        monthSuffix = 'nd';
      } else if (lunarMonth == 3 || lunarMonth == 23) {
        monthSuffix = 'rd';
      } else {
        monthSuffix = 'th';
      }

      return '$lunarDay$daySuffix Day - $lunarMonth$monthSuffix Month - $tibYear';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isTibetan ? (event.titleBo ?? event.titleEn) : event.titleEn;
    final desc = isTibetan
        ? (event.detailsBo ?? event.detailsEn ?? '')
        : (event.detailsEn ?? '');
    final imgPath = resolveImage(event.imageKey);
    final solarDateFull = _formatFullSolarDate(event.dateKey);
    final lunarDateFull = _formatFullLunarDate(event.dateKey);

    final bgColor = isDark ? AppColors.darkSurface : const Color(0xFFFDF8F3);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ─── Main scrollable content ─────────────────────────────
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // ─── Hero Image ─────────────────────────────────────
              SizedBox(
                height: 320,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imgPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.maroon.withOpacity(0.1),
                        child: const Center(
                          child: Icon(Icons.image, size: 64, color: AppColors.maroon),
                        ),
                      ),
                    ),
                    // Gradient overlay at bottom for readability
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              bgColor.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Title ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Date Info Box ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFFFFBF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE8E0D4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Solar Date row
                      Row(
                        children: [
                          const Text('☀️ ', style: TextStyle(fontSize: 14)),
                          Text(
                            isTibetan ? 'ཉི་མའི་ཚེས་གྲངས།' : 'Solar Date:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white54 : const Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              solarDateFull,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : const Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Lunar Date row
                      Row(
                        children: [
                          const Text('🌙 ', style: TextStyle(fontSize: 14)),
                          Text(
                            isTibetan ? 'ཟླ་བའི་ཚེས་གྲངས།' : 'Lunar Date:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white54 : const Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              lunarDateFull,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white70 : const Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── DETAIL label ───────────────────────────────────
              if (desc.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    isTibetan ? 'ཞིབ་ཕྲ།' : 'DETAIL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: AppColors.maroon.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ─── Detail Card ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : const Color(0xFFFFF9F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : const Color(0xFFE8DDD0),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      desc,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.8,
                        color: isDark ? AppColors.darkText : const Color(0xFF444444),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ─── SYNC TO CALENDAR button ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isTibetan ? 'ཟླ་ཐོར་སྣོན་ཟིན།' : 'Synced to calendar!'),
                        backgroundColor: AppColors.maroon,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.maroon,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.event_available, size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'SYNC TO CALENDAR',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ─── SET REMINDER button ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isTibetan ? 'དྲན་སྐུལ་བཀོད་ཟིན།' : 'Reminder set!'),
                        backgroundColor: const Color(0xFFC99A2E),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFC99A2E),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.notifications_active, size: 20, color: Color(0xFFC99A2E)),
                        SizedBox(width: 10),
                        Text(
                          'SET REMINDER',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Color(0xFFC99A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),

          // ─── Top overlay buttons ────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      // Favorite button
                      _circleButton(
                        icon: Icons.favorite_border_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      // Share button
                      _circleButton(
                        icon: Icons.share_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

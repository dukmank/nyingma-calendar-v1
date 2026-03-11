import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../theme/app_theme.dart';
import '../services/local_data_service.dart';
import '../services/theme_provider.dart';
import '../services/translations.dart';
import '../features/astrology/providers/astrology_providers.dart';
import 'day_details_screen.dart';
import '../features/day_detail/screens/astrology_detail_screen.dart';
import '../core/astrology/astrology_engine.dart';

// Tibetan month names for English UI
const tibetanMonthNames = {
  1: 'Chu Dawa',
  2: 'Wo Dawa',
  3: 'Nagpa Dawa',
  4: 'Saga Dawa',
  5: 'Nön Dawa',
  6: 'Chutö Dawa',
  7: 'Drozhin Dawa',
  8: 'Trum Dawa',
  9: 'Takar Dawa',
  10: 'Mindrug Dawa',
  11: 'Go Dawa',
  12: 'Gyal Dawa',
};

class CalendarHomeScreen extends ConsumerStatefulWidget {
  const CalendarHomeScreen({super.key});
  @override ConsumerState<CalendarHomeScreen> createState() => _CalendarHomeScreenState();
}

class _CalendarHomeScreenState extends ConsumerState<CalendarHomeScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  Map<String, dynamic>? _dayInfo;
  List<Map<String, dynamic>> _monthEvents = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final results = await Future.wait([
      LocalDataService.getCalendarDay(dateStr),
      LocalDataService.getEvents(month: _focusedMonth.month),
    ]);
    if (mounted) {
      setState(() {
        _dayInfo = results[0] as Map<String, dynamic>?;
        _monthEvents = results[1] as List<Map<String, dynamic>>;
        _loading = false;
      });
    }
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = date);
    _loadData();
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _lastLoadedMonth = 0; // Reset cache to reload tibetan days
    });
    _loadData();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedMonth = DateTime.now();
    });
    _loadData();
  }

  // Tibetan astrology items — keys match T.t() keys
  static const _astrologyItemKeys = [
    {'icon': Icons.access_time_filled, 'key': 'auspicious_times'},
    {'icon': Icons.explore, 'key': 'parkha'},
    {'icon': Icons.local_fire_department, 'key': 'fire_deity'},
    {'icon': Icons.format_color_fill, 'key': 'empty_vase'},
    {'icon': Icons.favorite, 'key': 'life_force_male'},
    {'icon': Icons.favorite_border, 'key': 'life_force_female'},
    {'icon': Icons.pest_control, 'key': 'horse_death'},
    {'icon': Icons.visibility, 'key': 'gu_mig'},
    {'icon': Icons.public, 'key': 'earth_lords'},
    {'icon': Icons.water, 'key': 'naga_days'},
    {'icon': Icons.card_giftcard, 'key': 'torma'},
    {'icon': Icons.warning_amber, 'key': 'fatal_weekdays'},
    {'icon': Icons.content_cut, 'key': 'hair_cutting'},
    {'icon': Icons.flag, 'key': 'flag_avoidance'},
    {'icon': Icons.block, 'key': 'restrictions'},
  ];

  // Map keys to actual image files in assets/images/astrology/
  static const _astrologyImages = {
    'auspicious_times': 'astrology/auspicious time.PNG',
    'parkha': 'astrology/parkha.PNG',
    'fire_deity': 'astrology/fire deity.PNG',
    'empty_vase': 'astrology/empty_vase.PNG',
    'life_force_male': 'astrology/bla men eng.PNG',
    'life_force_female': 'astrology/bla women eng.PNG',
    'horse_death': 'astrology/horse death.png',
    'gu_mig': 'astrology/gu mik.PNG',
    'earth_lords': 'astrology/earth-lords(flag).PNG',
    'naga_days': 'astrology/Naga-major.png',
    'torma': 'astrology/torma.PNG',
    'fatal_weekdays': 'astrology/IMG_1807.PNG',
    'hair_cutting': 'astrology/Hair cut.PNG',
    'flag_avoidance': 'astrology/earth-lords(flag).PNG',
    'restrictions': 'astrology/IMG_1851.PNG',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final isBo = lang == 'bo';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.maroon,
          child: CustomScrollView(
            slivers: [
              // â”€â”€â”€ App Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(child: _buildAppBar(isDark, isBo)),
              // â”€â”€â”€ Hero Date Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(child: _buildHeroCard(isDark)),
              // â”€â”€â”€ Calendar Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(child: _buildCalendarGrid(isDark)),
              // â”€â”€â”€ Tibetan Astrology Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              SliverToBoxAdapter(child: _buildAstrologySection(isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, bool isBo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Logo + Title
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/images/others/logo.PNG',
                width: 36, height: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isBo ? 'རྙིང་མ' : 'Nyingmapa', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900,
                color: isDark ? AppColors.maroon : AppColors.maroon,
                letterSpacing: 0.3,
              )),
              Text(isBo ? 'ཟླ་ཐོ།' : 'Calendar', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900,
                color: isDark ? AppColors.maroon : AppColors.maroon,
                letterSpacing: 0.3,
              )),
            ],
          ),
          const Spacer(),
          // Language toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : AppColors.navy).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _langChip('EN', !isBo, () => ref.read(languageProvider.notifier).setLanguage('en')),
                const SizedBox(width: 2),
                _langChip('བོ', isBo, () => ref.read(languageProvider.notifier).setLanguage('bo')),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Today button
          GestureDetector(
            onTap: _goToToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.maroon, AppColors.maroonDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.maroon.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.today, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(isBo ? 'དེ་རིང' : 'TODAY', style: const TextStyle(
                    color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 0.5,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _langChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: active ? AppColors.maroon : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: active ? Colors.white : AppColors.lightTextSecondary,
        )),
      ),
    );
  }

  Widget _buildHeroCard(bool isDark) {
    final isBo = ref.read(languageProvider) == 'bo';
    final day = _selectedDate.day;
    final tibDay = _dayInfo?['tibetan_day'] ?? _selectedDate.day;

    // Determine Tibetan month safely (prefer month calendar data)
    final key = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final m = _monthCalData[key];

    int tibMonth = 1;
    // Use dataset only to avoid incorrect month mixing
    if (m != null && m['tibetan_month'] != null) {
      tibMonth = m['tibetan_month'];
    } else if (_monthCalData.isNotEmpty) {
      tibMonth = _monthCalData.values.first['tibetan_month'] ?? 1;
    }

    final month = isBo
        ? _tibMonthName(tibMonth)
        : (tibetanMonthNames[tibMonth] ?? DateFormat('MMMM').format(_selectedDate));

    final element = _dayInfo?['element'] ?? 'Earth-Fire';
    final animal = _dayInfo?['animal'] ?? 'Dragon';
    final tibYear = 'Fire Horse';
    final lunarStr = '${tibMonth.toString().padLeft(2, '0')}-${tibDay.toString().padLeft(2, '0')}-${_selectedDate.year}';

    // Check if it's a special day
    final isGuruDay = tibDay == 10;

    // Get the primary event name for badge
    String? specialDayLabel;
    if (isGuruDay) {
      specialDayLabel = isBo ? 'གུ་རུ་རིན་པོ་ཆེའི་དུས་ཆེན།' : 'GURU RINPOCHE DAY';
    }

    // Choose background image for header
    // Rule:
    // - Red-dot / special lunar days -> use fixed known-good images
    // - All other days -> rotate 8 header images
    String bgImage = '';

    // Read Tibetan lunar day from loaded month data for the selected solar date
    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final selectedDayData = _monthCalData[selectedKey] ?? _dayInfo;
    final tibDayRaw = selectedDayData?['tibetan_day'];
    final int? selectedTibDay = tibDayRaw is int ? tibDayRaw : int.tryParse('$tibDayRaw');

    // Use correct asset paths for special days; all other days use the rotating header images
    if (selectedTibDay != null) {
      switch (selectedTibDay) {
        case 8:
          bgImage = 'assets/images/Auspicious days/medicinebuddha.PNG';
          break;
        case 10:
          const mn = ['jan','feb','mar','april','may','jun','july','aug','sep','oct','nov','dec'];
          bgImage = 'assets/images/Guru Rinpoche 12 manefistation/${mn[_selectedDate.month - 1]}guru.PNG';
          break;
        case 15:
          bgImage = 'assets/images/Auspicious days/fullmoon.PNG';
          break;
        case 25:
          bgImage = 'assets/images/Auspicious days/dakini.PNG';
          break;
        case 29:
          bgImage = 'assets/images/Auspicious days/dharmaprotector.PNG';
          break;
        case 30:
          bgImage = 'assets/images/Auspicious days/newmoon.PNG';
          break;
        default:
          // Rotate 8 header images for normal days
          final headerImages = [
            'assets/images/header_images/1.png',
            'assets/images/header_images/2.png',
            'assets/images/header_images/3.png',
            'assets/images/header_images/4.png',
            'assets/images/header_images/5.png',
            'assets/images/header_images/6.png',
            'assets/images/header_images/7.jpg',
            'assets/images/header_images/8.png',
          ];

          // Use date to deterministically rotate images
          final index = _selectedDate.day % headerImages.length;
          bgImage = headerImages[index];
      }
    }

    // Safety fallback: ensure bgImage is never empty
    if (bgImage.isEmpty) {
      final headerImages = [
        'assets/images/header_images/1.png',
        'assets/images/header_images/2.png',
        'assets/images/header_images/3.png',
        'assets/images/header_images/4.png',
        'assets/images/header_images/5.png',
        'assets/images/header_images/6.png',
        'assets/images/header_images/7.jpg',
        'assets/images/header_images/8.png',
      ];
      bgImage = headerImages[_selectedDate.day % headerImages.length];
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DayDetailsScreen(date: _selectedDate),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 260,
            child: Stack(
              children: [
                // Background image – full bleed
                Positioned.fill(
                  child: Image.asset(
                    bgImage,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, __, ___) {
                      debugPrint('Missing header image: $bgImage');
                      return Image.asset(
                        'assets/images/others/monastery.png',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF2C1810),
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlays for readability – darker overall to match expected design
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.60),
                          Colors.black.withOpacity(0.40),
                          Colors.black.withOpacity(0.35),
                          Colors.black.withOpacity(0.45),
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),
                // Top-left: Day + Month
                Positioned(
                  top: 20,
                  left: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$day',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 4)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        month.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Special day badge – golden style matching expected design
                if (specialDayLabel != null)
                  Positioned(
                    top: 118,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBF953F), Color(0xFFD4A843)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBF953F).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        specialDayLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                // Bottom gold floating box – Lunar Date + Elements
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBF953F), Color(0xFFD4A843), Color(0xFFBF953F)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Lunar Date section – no border, free text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isBo ? 'ཟླ་ཚེས།' : 'LUNAR DATE',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lunarStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        // Single divider between LUNAR DATE and DAY/MONTH/YEAR
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(width: 14),
                        // Day / Month / Year – no dividers between them
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _goldInfoChip(isBo ? 'ཉིན།' : 'DAY', element),
                              _goldInfoChip(isBo ? 'ཟླ།' : 'MONTH', animal),
                              _goldInfoChip(isBo ? 'ལོ།' : 'YEAR', tibYear),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _goldInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _goldDivider() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withOpacity(0.3),
    );
  }

  // Cache for month calendar data (tibetan days)
  Map<String, Map<String, dynamic>> _monthCalData = {};
  int _lastLoadedMonth = 0;

  Future<void> _loadMonthCalData() async {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    if (_lastLoadedMonth == year * 100 + month) return;
    final days = await LocalDataService.getCalendarMonth(year, month);
    final map = <String, Map<String, dynamic>>{};
    for (final d in days) {
      final key = d['date_key'] as String? ?? '';
      if (key.isNotEmpty) map[key] = d;
    }
    if (mounted) {
      setState(() {
        _monthCalData = map;
        _lastLoadedMonth = year * 100 + month;
      });
    }
  }

  /// Generate the month display for Tibetan script header
  String _getTibMonthDisplay(int gregMonth, bool isBo) {
    // Tibetan month names (traditional names based on position)
    const tibMonthNames = {
      1: 'ཟླ་བ་དང་པོ།',    // 1st month
      2: 'ཟླ་བ་གཉིས་པ།',   // 2nd month
      3: 'ཟླ་བ་གསུམ་པ།',   // 3rd month
      4: 'ཟླ་བ་བཞི་པ།',    // 4th month
      5: 'ཟླ་བ་ལྔ་པ།',     // 5th month
      6: 'ཟླ་བ་དྲུག་པ།',   // 6th month
      7: 'ཟླ་བ་བདུན་པ།',   // 7th month
      8: 'ཟླ་བ་བརྒྱད་པ།',  // 8th month
      9: 'ཟླ་བ་དགུ་པ།',    // 9th month
      10: 'ཟླ་བ་བཅུ་པ།',   // 10th month
      11: 'ཟླ་བ་བཅུ་གཅིག',  // 11th month
      12: 'ཟླ་བ་བཅུ་གཉིས།', // 12th month
    };

    // If we have data, use the tibetan month from it
    if (_monthCalData.isNotEmpty) {
      final firstDay = _monthCalData.values.first;
      final tibMonth = firstDay['tibetan_month'] as int?;
      if (tibMonth != null) {
        return '${tibMonthNames[tibMonth] ?? 'ཟླ་བ $tibMonth'} ${_focusedMonth.year}';
      }
    }
    return '${tibMonthNames[gregMonth] ?? 'ཟླ་བ $gregMonth'} ${_focusedMonth.year}';
  }

  Widget _buildCalendarGrid(bool isDark) {
    final isBo = ref.read(languageProvider) == 'bo';
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0=Sun

    // Previous month info
    final daysInPrevMonth = DateTime(year, month, 0).day;

    final monthName = isBo
        ? _getTibMonthDisplay(month, true)
        : DateFormat('MMMM yyyy').format(_focusedMonth);

    // Determine Tibetan month from selected day (accurate even when lunar month changes mid‑Gregorian month)
    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final selectedDayData = _monthCalData[selectedKey];

    int monthNum;
    if (selectedDayData != null && selectedDayData['tibetan_month'] != null) {
      monthNum = selectedDayData['tibetan_month'];
    } else if (_monthCalData.isNotEmpty) {
      monthNum = _monthCalData.values.first['tibetan_month'] ?? 1;
    } else {
      monthNum = 1;
    }

    final tibInfoPart1 = isBo
        ? _tibMonthName(monthNum)
        : (tibetanMonthNames[monthNum] ?? 'Month $monthNum');
    final tibInfoPart2 = isBo
        ? 'མེ་རྟའི་ལོ།'
        : 'YEAR OF THE FIRE HORSE';

    // Load month calendar data for tibetan days
    _loadMonthCalData();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Title + Navigation (OUTSIDE the card) ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(monthName, style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900,
                      fontFamily: 'Serif',
                      color: isDark ? Colors.white : AppColors.maroon,
                    )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(tibInfoPart1, style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.gold : const Color(0xFFB8860B),
                        )),
                        Text('  •  ', style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        )),
                        Flexible(
                          child: Text(tibInfoPart2, style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _arrowBtn(Icons.chevron_left, () => _changeMonth(-1), isDark),
                  const SizedBox(width: 6),
                  _arrowBtn(Icons.chevron_right, () => _changeMonth(1), isDark),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ─── Calendar Card (ONLY grid inside) ───
          Container(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Weekday headers
                Row(
                  children: (isBo ? ['ཉི', 'ཟལ', 'མིག', 'ལྷག', 'ཕུར', 'པ', 'སྤེན'] : ['S', 'M', 'T', 'W', 'T', 'F', 'S']).map((d) =>
                    Expanded(child: Center(child: Text(d, style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ))))
                  ).toList(),
                ),
                const SizedBox(height: 6),
                // Calendar days grid
                ...List.generate(6, (week) {
                  return Row(
                    children: List.generate(7, (col) {
                      final cellIndex = week * 7 + col;
                      final dayIndex = cellIndex - startWeekday + 1;

                      bool isCurrentMonth = dayIndex >= 1 && dayIndex <= daysInMonth;
                      int displayDay;
                      DateTime cellDate;

                      if (dayIndex < 1) {
                        displayDay = daysInPrevMonth + dayIndex;
                        cellDate = DateTime(year, month - 1, displayDay);
                      } else if (dayIndex > daysInMonth) {
                        displayDay = dayIndex - daysInMonth;
                        cellDate = DateTime(year, month + 1, displayDay);
                      } else {
                        displayDay = dayIndex;
                        cellDate = DateTime(year, month, dayIndex);
                      }

                      if (week >= 5 && cellIndex - startWeekday + 1 > daysInMonth + 7) {
                        return const Expanded(child: SizedBox(height: 52));
                      }

                      final isToday = _isToday(cellDate);
                      final isSelected = isCurrentMonth && _isSameDay(cellDate, _selectedDate);

                      // Get tibetan day (handle int or string)
                      final dateKey = DateFormat('yyyy-MM-dd').format(cellDate);
                      final dayData = _monthCalData[dateKey];
                      final tibDayRaw = dayData?['tibetan_day'];
                      final tibDay = tibDayRaw is int ? tibDayRaw : int.tryParse('$tibDayRaw');
                      final tibDayStr = tibDay != null ? '$tibDay' : '';
                      final hasData = dayData != null;

                      // Special/festival days by Tibetan lunar day
                      final auspiciousDays = [8, 10, 15, 25, 29, 30];
                      final inauspiciousDays = [2, 8, 14, 20, 26];

                      final isAuspicious = isCurrentMonth && tibDay != null && auspiciousDays.contains(tibDay);
                      final isInauspicious = isCurrentMonth && tibDay != null && !isAuspicious && inauspiciousDays.contains(tibDay);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (isCurrentMonth && hasData) {
                              _selectDate(cellDate);
                            }
                          },
                          child: Container(
                            height: 52,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.maroon : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: isToday && !isSelected
                                  ? Border.all(color: AppColors.gold, width: 1.8)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Solar date
                                Text('$displayDay', style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : !hasData
                                          ? (isDark ? Colors.white24 : Colors.grey.shade300)
                                          : (isDark ? Colors.white : AppColors.navy),
                                )),
                                // Tibetan lunar date
                                if (tibDayStr.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(tibDayStr, style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white70
                                            : !isCurrentMonth ? (isDark ? Colors.white12 : Colors.grey.shade300)
                                            : const Color(0xFFB8860B),
                                      )),
                                      if (tibDay != null && (isAuspicious || isInauspicious) && !isSelected) ...[
                                        const SizedBox(width: 2),
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isAuspicious ? Colors.red : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ],
                                  )
                                else if (isCurrentMonth)
                                  const SizedBox(height: 11),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: isDark ? Colors.white : AppColors.navy),
      ),
    );
  }

  Widget _buildAstrologySection(bool isDark) {
    final isBo = ref.read(languageProvider) == 'bo';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/others/astrology_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.maroon.withOpacity(0.1),
                      child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(T.t('tibetan_astrology', isBo), style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: isDark ? Colors.white : AppColors.navy,
              )),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: _astrologyItemKeys.length,
            itemBuilder: (context, i) {
              final item = _astrologyItemKeys[i];
              final imgKey = item['key'] as String;
              final label = T.t(imgKey, isBo);
              final imgPath = _astrologyImages[imgKey] ?? 'astrology/Tibetan astrology.jpg';
              return GestureDetector(
                onTap: () => _showAstrologyModal(context, item, isDark),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 40, height: 40,
                          child: Image.asset(
                            'assets/images/$imgPath',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.maroon.withOpacity(0.08),
                              child: Icon(item['icon'] as IconData, size: 20, color: AppColors.maroon),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(label, textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAstrologyModal(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final key = item['key'] as String;
    
    final imgPath = _astrologyImages[key] ?? 'astrology/Tibetan astrology.jpg';
    final card = AstrologyCard(
      id: key,
      titleEn: T.t(key, false),
      titleBo: T.t(key, true),
      status: AstrologyStatus.neutral,
      iconKey: 'assets/images/$imgPath',
      isActive: true,
      popupRaw: '',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AstrologyDetailScreen(card: card),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildMonthlyEvents(bool isDark) {
    final isBo = ref.read(languageProvider) == 'bo';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isBo ? 'ཟལ་རེའི་དུས་ཆེན༔' : 'MONTHLY EVENTS', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: isDark ? Colors.white : AppColors.navy,
              )),
              Text(isBo ? 'ཟང་མ་བལཏ༔' : 'View All', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.maroon,
              )),
            ],
          ),
          const SizedBox(height: 12),
          if (_monthEvents.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 32, color: AppColors.lightTextSecondary),
                    const SizedBox(height: 8),
                    Text(isBo ? 'ཟལ་བ་འདིའི་དུས་ཆེན་མེད༔' : 'No events this month', style: TextStyle(
                      fontSize: 13, color: AppColors.lightTextSecondary,
                    )),
                  ],
                ),
              ),
            ),
          ...(_monthEvents.take(4).map((event) => _eventTile(event, isDark, isBo))),
        ],
      ),
    );
  }

  Widget _eventTile(Map<String, dynamic> event, bool isDark, bool isBo) {
    final title = isBo ? (event['title_bo'] ?? event['title_en'] ?? '') : (event['title_en'] ?? '');
    final imgPath = event['image_path'] ?? 'others/guru.jpg';
    final dateStr = event['western_date'] ?? '';

    return GestureDetector(
      onTap: () => _showEventDetail(context, event, isDark, isBo),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 48, height: 48,
                color: AppColors.cream,
                child: Image.asset(
                  'assets/images/$imgPath',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.event, color: AppColors.maroon, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.navy,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(isBo ? 'ཉི་མའི་ཟལ་ཐོ༔ $dateStr' : 'Solar: $dateStr', style: TextStyle(
                    fontSize: 11, color: AppColors.lightTextSecondary,
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }

  void _showEventDetail(BuildContext context, Map<String, dynamic> event, bool isDark, bool isBo) {
    final title = isBo ? (event['title_bo'] ?? event['title_en'] ?? '') : (event['title_en'] ?? '');
    final description = isBo ? (event['details_bo'] ?? event['details_en'] ?? '') : (event['details_en'] ?? '');
    final category = isBo ? (event['category_bo'] ?? event['category_en'] ?? '') : (event['category_en'] ?? '');
    final imgPath = event['image_path'] ?? 'others/guru.jpg';
    final dateStr = event['western_date'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : const Color(0xFFFAF5EF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle
              Center(child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              )),
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 200, width: double.infinity,
                  child: Image.asset(
                    'assets/images/$imgPath',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.maroon.withOpacity(0.08),
                      child: const Center(child: Icon(Icons.event, size: 48, color: AppColors.maroon)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Category chip
              if (category.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.maroon.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.maroon)),
                  ),
                ),
              const SizedBox(height: 8),
              // Title
              Text(title, style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.navy,
              )),
              const SizedBox(height: 6),
              // Date
              Row(children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.maroon),
                const SizedBox(width: 6),
                Text(isBo ? 'ཉི་མའི་ཟལ་ཐོ༔ $dateStr' : 'Solar: $dateStr', style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary)),
              ]),
              const SizedBox(height: 16),
              // Description
              if (description.isNotEmpty) ...[
                Text(isBo ? 'འགྲེལ་བཤད།' : 'Description', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.maroon, letterSpacing: 1,
                )),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(
                  fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.6,
                )),
              ],
              const SizedBox(height: 20),
              // Close
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isBo ? 'སྒོ་རྒྱག' : 'Close', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _tibMonthName(int m) {
    const names = ['', 'ཟླ་བ་དང་པོ', 'ཟླ་བ་གཉིས་པ', 'ཟླ་བ་གསུམ་པ', 'ཟླ་བ་བཞི་པ',
      'ཟླ་བ་ལྔ་པ', 'ཟླ་བ་དྲུག་པ', 'ཟླ་བ་བདུན་པ', 'ཟླ་བ་བརྒྱད་པ',
      'ཟླ་བ་དགུ་པ', 'ཟླ་བ་བཅུ་པ', 'ཟླ་བ་བཅུ་གཅིག', 'ཟླ་བ་བཅུ་གཉིས'];
    return m >= 1 && m <= 12 ? names[m] : 'ཟླ་བ $m';
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Astrology Detail Bottom Sheet
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _AstrologyDetailSheet extends ConsumerStatefulWidget {
  final String itemKey;
  final String label;
  final bool isDark;
  const _AstrologyDetailSheet({required this.itemKey, required this.label, required this.isDark});
  @override ConsumerState<_AstrologyDetailSheet> createState() => _AstrologyDetailSheetState();
}

class _AstrologyDetailSheetState extends ConsumerState<_AstrologyDetailSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : const Color(0xFFFAF5EF),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.maroon,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: _buildProviderContent(ScrollController()),
            ),

            // Bottom close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    ref.read(languageProvider) == 'bo' ? 'སྒོ་རྒྱག' : 'Close',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderContent(ScrollController controller) {
    final cleanLabel = widget.label.replaceAll('\n', ' ').trim();
    
    // Get the right provider based on key
    AsyncValue<List<Map<String, dynamic>>>? providerData;
    switch (widget.itemKey) {
      case 'hair_cutting':
        providerData = ref.watch(hairCuttingProvider);
        break;
      case 'naga_days':
        providerData = ref.watch(nagaDaysProvider);
        break;
      case 'flag_avoidance':
      case 'earth_lords':
        providerData = ref.watch(flagAvoidanceProvider);
        break;
      case 'restrictions':
        providerData = ref.watch(restrictionProvider);
        break;
      case 'auspicious_times':
        providerData = ref.watch(auspiciousTimingProvider);
        break;
      case 'fire_deity':
        providerData = ref.watch(fireRitualProvider);
        break;
      case 'empty_vase':
        providerData = ref.watch(emptyVaseProvider);
        break;
      case 'life_force_male':
        providerData = ref.watch(lifeForceMAleProvider);
        break;
      case 'life_force_female':
        providerData = ref.watch(lifeForceFemaleProvider);
        break;
      case 'horse_death':
        providerData = ref.watch(horseDeathProvider);
        break;
      case 'gu_mig':
        providerData = ref.watch(guMigProvider);
        break;
      case 'fatal_weekdays':
        providerData = ref.watch(fatalWeekdaysProvider);
        break;
      case 'torma':
        providerData = ref.watch(tormaOfferingProvider);
        break;
      case 'parkha':
        providerData = ref.watch(tibetanAstrologyProvider);
        break;
    }

    if (providerData == null) {
      return _wrapScroll(controller, cleanLabel, [_buildGenericContent()]);
    }

    return providerData.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.maroon)),
      error: (e, _) => _wrapScroll(controller, cleanLabel, [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.maroon.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Error loading data: $e', style: TextStyle(color: AppColors.maroon)),
        ),
      ]),
      data: (items) {
        if (items.isEmpty) {
          return _wrapScroll(controller, cleanLabel, [_buildGenericContent()]);
        }
        return _wrapScroll(controller, cleanLabel, [_buildDataContent(widget.itemKey, items)]);
      },
    );
  }

  Widget _wrapScroll(ScrollController controller, String label, List<Widget> children) {
    final isBo = ref.read(languageProvider) == 'bo';
    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Center(
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.maroon.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getIcon(widget.itemKey), size: 32, color: AppColors.maroon),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(label.toUpperCase(), style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w800,
            color: AppColors.maroon, letterSpacing: 1,
          ), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            isBo ? 'རྙིང་མའི་སྐར་རྩིས་ཀྱི་ལམ་སྲོལ།' : 'NYINGMA ASTROLOGICAL TRADITION',
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.lightTextSecondary, letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }


  Widget _buildDataContent(String key, List<Map<String, dynamic>> items) {
    switch (key) {
      case 'hair_cutting':
        return _buildHairCuttingRiverpod(items);
      case 'naga_days':
        return _buildNagaDaysRiverpod(items);
      case 'flag_avoidance':
      case 'earth_lords':
        return _buildFlagRiverpod(items);
      case 'restrictions':
        return _buildRestrictionsRiverpod(items);
      case 'auspicious_times':
        return _buildAuspiciousTimingView(items);
      case 'fire_deity':
        return _buildFireDeityView(items);
      case 'empty_vase':
        return _buildEmptyVaseView(items);
      case 'horse_death':
        return _buildHorseDeathView(items);
      case 'life_force_male':
      case 'life_force_female':
        return _buildLifeForceView(items);
      case 'gu_mig':
        return _buildGuMigView(items);
      case 'fatal_weekdays':
        return _buildFatalWeekdaysView(items);
      case 'torma':
        return _buildTormaView(items);
      case 'parkha':
        return _buildTibAstrologyView(items);
      default:
        return _buildGenericDataTable(items);
    }
  }

  Widget _buildHairCuttingRiverpod(List<Map<String, dynamic>> items) {
    final today = DateTime.now().day;
    final todayItem = items.firstWhere(
      (d) => d['day'] == today,
      orElse: () => items.isNotEmpty ? items.first : {'day': 0, 'meaning': '', 'recommendation': 'Unknown'},
    );
    final isGood = todayItem['recommendation'] == 'Good';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isGood ? Colors.green.withOpacity(0.3) : AppColors.maroon.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(isGood ? 'âœ“' : 'âœ—', style: TextStyle(fontSize: 24, color: isGood ? Colors.green : AppColors.maroon)),
              Text('DAY $today â€“ ${isGood ? "EXCELLENT FOR HAIRCUT" : "AVOID HAIRCUT TODAY"}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isGood ? Colors.green.shade700 : AppColors.maroon),
              ),
              Text('"${todayItem['meaning']}"', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('COMPLETE HAIR CUTTING CALENDAR', style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.navy,
        )),
        const SizedBox(height: 8),
        ...items.map<Widget>((d) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: d['day'] == today ? AppColors.maroon.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              SizedBox(width: 30, child: Text('${d['day']}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
              Expanded(child: Text(d['meaning'] ?? '', style: const TextStyle(fontSize: 12))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getRecColor(d['recommendation'] ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(d['recommendation'] ?? '', style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: _getRecColor(d['recommendation'] ?? ''),
                )),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildNagaDaysRiverpod(List<Map<String, dynamic>> items) {
    final currentMonth = DateTime.now().month;
    final monthData = items.length > currentMonth - 1 ? items[currentMonth - 1] : (items.isNotEmpty ? items.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.maroon.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.maroon.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Text('ðŸ', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              const Text('NAGA DAYS THIS MONTH', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.maroon,
              )),
              Text(
                'It is beneficial to perform Lu Tor (naga torma offerings) on these days.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (monthData != null) ...[
          _infoRow('MONTH', monthData['month_name'] ?? 'Month $currentMonth', AppColors.navy),
          const SizedBox(height: 12),
          _infoRow('MAJOR NAGA DAYS', monthData['major_days'] ?? '-', AppColors.maroon),
          const SizedBox(height: 8),
          _infoRow('MINOR NAGA DAYS', monthData['minor_days'] ?? '-', AppColors.lightTextSecondary),
        ],
        const SizedBox(height: 16),
        // Show all months table
        const Text('ALL MONTHS', style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.navy,
        )),
        const SizedBox(height: 8),
        ...items.map<Widget>((m) => Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: m == monthData ? AppColors.maroon.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(m['month_name'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Expanded(flex: 1, child: Text(m['major_days'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.maroon))),
              Expanded(flex: 1, child: Text(m['minor_days'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildFlagRiverpod(List<Map<String, dynamic>> items) {
    final currentMonth = DateTime.now().month;
    final monthData = items.firstWhere(
      (m) => m['month'] == currentMonth,
      orElse: () => items.isNotEmpty ? items.first : {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.maroon.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.maroon.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Text('ðŸš©', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              const Text('FLAG AVOIDANCE DAYS', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.maroon,
              )),
              Text(
                'Days to avoid hanging prayer flags due to Earth-Lord activity.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (monthData.isNotEmpty) ...[
          _infoRow('CURRENT MONTH', monthData['month_name'] ?? 'Month $currentMonth', AppColors.navy),
          const SizedBox(height: 8),
          _infoRow('AVOID DAYS', monthData['avoid_days'] ?? '-', AppColors.maroon),
        ],
        const SizedBox(height: 16),
        const Text('ALL MONTHS', style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.navy,
        )),
        const SizedBox(height: 8),
        ...items.map<Widget>((m) => Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: m['month'] == currentMonth ? AppColors.maroon.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(m['month_name'] ?? 'Month ${m['month']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Expanded(flex: 1, child: Text(m['avoid_days'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.maroon))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRestrictionsRiverpod(List<Map<String, dynamic>> items) {
    final today = DateTime.now().day;
    Map<String, dynamic>? todayRestriction;
    for (final r in items) {
      final days = r['days']?.toString() ?? '';
      final dayNums = days.split(',').map((s) => int.tryParse(s.trim())).whereType<int>();
      if (dayNums.contains(today)) {
        todayRestriction = r;
        break;
      }
    }
    todayRestriction ??= items.isNotEmpty ? items.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todayRestriction != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.maroon.withOpacity(0.05),

              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.maroon.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.warning_amber, size: 28, color: AppColors.maroon),
                const SizedBox(height: 4),
                const Text("TODAY'S RESTRICTION:", style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.maroon,
                )),
                Text(todayRestriction['name']?.toString().toUpperCase() ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy),
                ),
                const SizedBox(height: 4),
                Text('"${todayRestriction['restriction'] ?? ''}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.maroon),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const Text('LUNAR CYCLE RESTRICTIONS', style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.navy,
        )),
        const SizedBox(height: 8),
        ...items.map<Widget>((r) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(width: 80, child: Text('Days ${r['days'] ?? ''}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy))),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['name'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.maroon)),
                  if ((r['restriction'] ?? '').toString().isNotEmpty)
                    Text(r['restriction'], style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              )),
            ],
          ),
        )),
      ],
    );
  }

  // ─── Clean Generic Table ───────────
  Widget _buildGenericDataTable(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return _buildGenericContent();
    final keys = items.first.keys.where((k) {
      final v = items.first[k]?.toString() ?? '';
      return v.isNotEmpty && v != 'null';
    }).toList();
    final _prettyName = <String, String>{
      'day': 'Day', 'day_of_week': 'Day', 'meaning': 'Meaning',
      'recommendation': 'Status', 'month_name': 'Month', 'month': 'Month',
      'major_days': 'Major Days', 'minor_days': 'Minor Days', 'avoid_days': 'Avoid Days',
      'days': 'Days', 'name': 'Name', 'restriction': 'Restriction',
      'daytime': 'Daytime', 'nighttime': 'Nighttime', 'content_en': 'Content',
      'content_bo': 'བོད་སྐད།', 'notes': 'Notes', 'starting_day': 'Starting Day',
      'direction': 'Direction', 'location': 'Body Location', 'status': 'Status',
      'birth_year': 'Birth Year', 'combination': 'Combination', 'effect': 'Effect',
      'life_soul_day': 'Life-Soul Day', 'fatal_weekday': 'Fatal Weekday',
      'bearing': 'Bearing', 'name_en': 'Name', 'name_bo': 'Name (BO)',
      'description_en': 'Description', 'description_bo': 'འགྲེལ་བཤད།',
      'description': 'Description', 'type': 'Type',
      'notes_en': 'Notes', 'notes_bo': 'Notes (BO)', 'image': 'Image',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.maroon.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            Text('${items.length} entries', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.maroon)),
            const Text('Nyingma astrological tradition', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
          ]),
        ),
        const SizedBox(height: 12),
        ...items.take(30).map<Widget>((item) => Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: keys.map((k) {
              final v = item[k]?.toString() ?? '';
              if (v.isEmpty || v == 'null') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 90, child: Text(
                    _prettyName[k] ?? k.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.navy),
                  )),
                  Expanded(child: Text(v, style: const TextStyle(fontSize: 12), maxLines: 5, overflow: TextOverflow.ellipsis)),
                ]),
              );
            }).toList(),
          ),
        )),
      ],
    );
  }

  // ─── Auspicious Timing ───────────
  Widget _buildAuspiciousTimingView(List<Map<String, dynamic>> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...items.map<Widget>((item) {
        final day = item['day_of_week'] ?? '';
        final daytime = item['daytime'] ?? '';
        final nighttime = item['nighttime'] ?? '';
        return Container(
          padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(day, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.maroon)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.wb_sunny, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(child: Text(daytime, style: const TextStyle(fontSize: 12))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.nightlight_round, size: 14, color: AppColors.navy),
              const SizedBox(width: 6),
              Expanded(child: Text(nighttime, style: const TextStyle(fontSize: 12))),
            ]),
          ]),
        );
      }),
    ]);
  }

  // ─── Fire Deity ───────────
  Widget _buildFireDeityView(List<Map<String, dynamic>> items) {
    // First item may be a description
    String? description;
    final dataItems = <Map<String, dynamic>>[];
    for (final item in items) {
      if (item.containsKey('_description')) {
        description = item['_description'];
      } else {
        dataItems.add(item);
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (description != null && description.isNotEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.maroon.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(description, style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary, height: 1.4), maxLines: 6, overflow: TextOverflow.ellipsis),
        ),
      // Table header
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: AppColors.maroon.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: const Row(children: [
          SizedBox(width: 60, child: Text('Month', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy))),
          Expanded(child: Text('Auspicious Dates', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy))),
          SizedBox(width: 50, child: Text('Days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy))),
        ]),
      ),
      ...dataItems.map<Widget>((item) => Container(
        padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          SizedBox(width: 60, child: Text(item['month'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy))),
          Expanded(child: Text(item['auspicious_dates'] ?? '', style: const TextStyle(fontSize: 11))),
          SizedBox(width: 50, child: Text(item['total_days'] ?? '', style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary))),
        ]),
      )),
    ]);
  }

  // ─── Gu Mig ───────────
  Widget _buildGuMigView(List<Map<String, dynamic>> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Table header
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: AppColors.maroon.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: const Row(children: [
          Expanded(flex: 3, child: Text('Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy))),
          Expanded(flex: 3, child: Text('Ages Affected', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy))),
          Expanded(flex: 1, child: Text('Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy))),
        ]),
      ),
      ...items.map<Widget>((item) => Container(
        padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: Text(item['category'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text(item['ages_affected'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary))),
          Expanded(flex: 1, child: Text(item['total'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.maroon))),
        ]),
      )),
    ]);
  }

  // ─── Fatal Weekdays ───────────
  Widget _buildFatalWeekdaysView(List<Map<String, dynamic>> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Table header
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: AppColors.maroon.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: const Row(children: [
          Expanded(flex: 2, child: Text('Birth Sign', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy))),
          Expanded(flex: 3, child: Text('Soul & Life-Force (Auspicious)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4CAF50)))),
          Expanded(flex: 2, child: Text('Fatal Day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.maroon))),
        ]),
      ),
      ...items.map<Widget>((item) => Container(
        padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Expanded(flex: 2, child: Text(item['birth_sign'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy))),
          Expanded(flex: 3, child: Text(item['soul_day'] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF4CAF50)))),
          Expanded(flex: 2, child: Text(item['fatal_day'] ?? '', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.maroon))),
        ]),
      )),
    ]);
  }

  // ─── Empty Vase ───────────

  Widget _buildEmptyVaseView(List<Map<String, dynamic>> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...items.map<Widget>((item) {
        return Container(
          padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            SizedBox(width: 80, child: Text(item['month'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy))),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Day: ${item['starting_day'] ?? ''}', style: const TextStyle(fontSize: 12)),
              Text('Direction: ${item['direction'] ?? ''}', style: TextStyle(fontSize: 11, color: AppColors.maroon, fontWeight: FontWeight.w600)),
            ])),
          ]),
        );
      }),
    ]);
  }

  // ─── Horse Death ───────────
  Widget _buildHorseDeathView(List<Map<String, dynamic>> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...items.map<Widget>((item) {
        final status = item['status']?.toString() ?? '';
        final isGood = status.toLowerCase().contains('auspicious') && !status.toLowerCase().contains('inauspicious');
        final isBad = status.toLowerCase().contains('inauspicious');
        return Container(
          padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: isBad ? AppColors.maroon : isGood ? const Color(0xFF4CAF50) : AppColors.gold, width: 3)),
          ),
          child: Row(children: [
            SizedBox(width: 80, child: Text('Days ${item['lunar_days'] ?? ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.navy))),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item['meaning'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              if (status.isNotEmpty) Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isBad ? AppColors.maroon : const Color(0xFF4CAF50))),
            ])),
          ]),
        );
      }),
    ]);
  }

  // ─── Life Force (3-column layout) ───────────
  Widget _buildLifeForceView(List<Map<String, dynamic>> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Table header
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: AppColors.maroon.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: const Row(children: [
          Expanded(child: Text('Date 1-10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy), textAlign: TextAlign.center)),
          Expanded(child: Text('Date 11-20', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy), textAlign: TextAlign.center)),
          Expanded(child: Text('Date 21-30', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy), textAlign: TextAlign.center)),
        ]),
      ),
      ...items.map<Widget>((item) => Container(
        padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Expanded(child: Text(item['date_1_10'] ?? '', style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)),
          Expanded(child: Text(item['date_11_20'] ?? '', style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)),
          Expanded(child: Text(item['date_21_30'] ?? '', style: const TextStyle(fontSize: 11), textAlign: TextAlign.center)),
        ]),
      )),
    ]);
  }

  // ─── Torma View ───────────
  Widget _buildTormaView(List<Map<String, dynamic>> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...items.map<Widget>((item) => Container(
        padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          SizedBox(width: 60, child: Text('Month ${item['month'] ?? ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy))),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['direction'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(item['bearing'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
          ])),
          const Icon(Icons.explore, size: 16, color: AppColors.maroon),
        ]),
      )),
    ]);
  }

  // ─── Tibetan Astrology Overview ───────────
  Widget _buildTibAstrologyView(List<Map<String, dynamic>> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...items.map<Widget>((item) {
        final nameEn = item['name_en'] ?? '';
        final nameBo = item['name_bo'] ?? '';
        final descEn = item['description_en'] ?? '';
        final img = item['image'] ?? '';
        return Container(
          padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (img.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(width: 40, height: 40, child: Image.asset(
                    'assets/images/astrology/$img', fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.maroon.withOpacity(0.08), child: const Icon(Icons.auto_awesome, color: AppColors.maroon, size: 20)),
                  )),
                ),
              if (img.isNotEmpty) const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(nameEn, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy)),
                if (nameBo.isNotEmpty && nameBo != 'null') Text(nameBo, style: const TextStyle(fontSize: 12, color: AppColors.maroon)),
              ])),
            ]),
            if (descEn.isNotEmpty && descEn != 'null') ...[
              const SizedBox(height: 8),
              Text(descEn, style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary, height: 1.4), maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
          ]),
        );
      }),
    ]);
  }

  Widget _buildGenericContent() {
    final isBo = ref.read(languageProvider) == 'bo';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cream.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 40, color: AppColors.lightTextSecondary),
          const SizedBox(height: 12),
          Text(isBo ? 'འདིའི་གཞི་གྲངས་མེད།' : 'No data available for this category.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.navy)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: valueColor)),
      ],
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'hair_cutting': return Icons.content_cut;
      case 'naga_days': return Icons.water;
      case 'flag_avoidance': return Icons.flag;
      case 'earth_lords': return Icons.flag;
      case 'restrictions': return Icons.block;
      case 'horse_death': return Icons.pest_control;
      case 'torma': return Icons.card_giftcard;
      case 'auspicious_times': return Icons.access_time_filled;
      case 'fire_deity': return Icons.local_fire_department;
      case 'empty_vase': return Icons.format_color_fill;
      case 'life_force_male': return Icons.favorite;
      case 'life_force_female': return Icons.favorite_border;
      case 'gu_mig': return Icons.visibility;
      case 'fatal_weekdays': return Icons.warning_amber;
      case 'parkha': return Icons.explore;
      default: return Icons.auto_awesome;
    }
  }

  Color _getRecColor(String rec) {
    if (rec.contains('Best') || rec.contains('Excellent')) return const Color(0xFF2E7D32);
    if (rec.contains('Very Good') || rec.contains('Good')) return const Color(0xFF558B2F);
    if (rec.contains('Avoid!')) return AppColors.maroon;
    if (rec.contains('Avoid')) return const Color(0xFFE65100);
    return AppColors.neutral;
  }
}

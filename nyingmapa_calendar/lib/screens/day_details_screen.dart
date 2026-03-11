import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/local_data_service.dart';
import '../features/day_detail/screens/astrology_detail_screen.dart';
import '../core/astrology/astrology_engine.dart';

class DayDetailsScreen extends StatefulWidget {
  final DateTime date;
  final Map<String, dynamic>? dayInfo;
  const DayDetailsScreen({super.key, required this.date, this.dayInfo});
  @override State<DayDetailsScreen> createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  Map<String, dynamic>? _flat;
  Map<String, dynamic>? _raw;
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _flat = widget.dayInfo;
    _load();
  }

  Future<void> _load() async {
    final ds = DateFormat('yyyy-MM-dd').format(widget.date);
    final r = await Future.wait([
      LocalDataService.getCalendarDay(ds),
      LocalDataService.getRawCalendarDay(ds),
    ]);
    final flatInfo = r[0] as Map<String, dynamic>?;
    final rawInfo = r[1] as Map<String, dynamic>?;
    List<Map<String, dynamic>> evts = [];
    if (rawInfo != null) {
      final ids = (rawInfo['event_ids'] as List?)?.map((e) => e.toString()).toList() ?? [];
      if (ids.isNotEmpty) evts = await LocalDataService.getEventsByIds(ids);
    }
    if (mounted) setState(() { _flat = flatInfo ?? _flat; _raw = rawInfo; _events = evts; _loading = false; });
  }

  // ─── data helpers ──────────────────────────────────
  Map<String, dynamic> _a(String k) {
    final as_ = _raw?['astrology'] as Map<String, dynamic>? ?? {};
    return (as_[k] is Map) ? Map<String, dynamic>.from(as_[k]) : {};
  }

  String _yearAnimal(int gYear) {
    const el = ['Wood', 'Fire', 'Earth', 'Iron', 'Water'];
    const an = ['Mouse', 'Ox', 'Tiger', 'Rabbit', 'Dragon', 'Snake', 'Horse', 'Sheep', 'Monkey', 'Bird', 'Dog', 'Pig'];
    final off = (gYear - 1924) % 60;
    return '${el[(off ~/ 2) % 5]} ${an[off % 12]}'.toUpperCase();
  }

  String _tibMonthName(int m) {
    const n = {1:'Chu-Dawa',2:'Dbo-Dawa',3:'Nag-Dawa',4:'Sa-Ga Dawa',5:'Snron-Dawa',6:'Chu-Stod',7:'Gro-Bzhin',8:'Khrums',9:'Tha-Skar',10:'Smin-Drug',11:'mGo',12:'rGyal'};
    return n[m] ?? 'Month $m';
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}TH';
    switch (n % 10) { case 1: return '${n}ST'; case 2: return '${n}ND'; case 3: return '${n}RD'; default: return '${n}TH'; }
  }

  String _heroImgPath() {
    final key = _raw?['visual']?['hero_image_key'];
    if (key == null) return '';
    final k = key.toString().toLowerCase();
    if (k.contains('guru') || k.contains('tenth')) {
      const mn = ['jan','feb','mar','april','may','jun','july','aug','sep','oct','nov','dec'];
      return 'assets/images/Guru Rinpoche 12 manefistation/${mn[widget.date.month - 1]}guru.PNG';
    }
    if (k.contains('losar')) return 'assets/images/events 2/Losar.PNG';
    if (k.contains('chotrul')) return 'assets/images/events 2/chotrul duchen.png';
    if (k.contains('fullmoon')) return 'assets/images/Auspicious days/fullmoon.PNG';
    if (k.contains('newmoon')) return 'assets/images/Auspicious days/newmoon.PNG';
    if (k.contains('dakini')) return 'assets/images/Auspicious days/dakini.PNG';
    if (k.contains('medicine')) return 'assets/images/Auspicious days/medicinebuddha.PNG';
    if (k.contains('dharma') || k.contains('protector')) return 'assets/images/Auspicious days/dharmaprotector.PNG';
    if (k.contains('parinirvana')) return 'assets/images/parinirvana/KyabjePenor.PNG';
    if (k.contains('chokhor')) return 'assets/images/Events 3/Chokhor Duchen.PNG';
    if (k.contains('sawa') || k.contains('saga')) return 'assets/images/Auspicious days/fullmoon.PNG';
    if (k.contains('incense')) return 'assets/images/events 2/incense.PNG';
    return 'assets/images/others/guru.jpg';
  }

  Color _sColor(String? s) {
    switch (s) {
      case 'extremely_auspicious': return const Color(0xFF2E7D32);
      case 'auspicious': return const Color(0xFF43A047);
      case 'avoid': return AppColors.maroon;
      case 'caution': return const Color(0xFFE65100);
      case 'neutral': case 'not_applicable': case null: default: return AppColors.lightTextSecondary;
    }
  }

  Color _sBg(String? s) {
    switch (s) {
      case 'extremely_auspicious': case 'auspicious': return const Color(0xFFE8F5E9);
      case 'avoid': return const Color(0xFFFFEBEE);
      case 'caution': return const Color(0xFFFFF3E0);
      default: return const Color(0xFFF5F5F5);
    }
  }

  Widget _sIcon(String? s) {
    if (s == 'extremely_auspicious' || s == 'auspicious') {
      return const Icon(Icons.check, color: Color(0xFF2E7D32), size: 20);
    }
    if (s == 'avoid' || s == 'caution') {
      return const Icon(Icons.close, color: AppColors.maroon, size: 20);
    }
    return Text('—', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade400));
  }

  String _astroImg(String imageKey) {
    final k = imageKey.toLowerCase();
    if (k.contains('naga_sleep')) return 'assets/images/astrology/Naga-sleep.png';
    if (k.contains('naga_minor')) return 'assets/images/astrology/Naga-minor.png';
    if (k.contains('naga_major') || k.contains('naga-major') || k.contains('naga')) return 'assets/images/astrology/Naga-major.png';
    if (k.contains('earth_lordsflag') || k.contains('flag')) return 'assets/images/astrology/earth-lords(flag).PNG';
    if (k.contains('fire_deity') || k.contains('fire')) return 'assets/images/astrology/fire deity.PNG';
    if (k.contains('torma')) return 'assets/images/astrology/torma.PNG';
    if (k.contains('empty_vase') || k.contains('bumtong')) return 'assets/images/astrology/empty_vase.PNG';
    if (k.contains('hair')) return 'assets/images/astrology/Hair cut.PNG';
    if (k.contains('horse_death') || k.contains('horse')) return 'assets/images/astrology/horse death.png';
    if (k.contains('guest')) return 'assets/images/astrology/10 daily restriction activities/guest.PNG';
    if (k.contains('auspicious_time') || k.contains('time')) return 'assets/images/astrology/auspicious time.PNG';
    if (k.contains('inauspicious') || k.contains('img_1807')) return 'assets/images/astrology/IMG_1807.PNG';
    if (k.contains('life_soul') || k.contains('life')) return 'assets/images/astrology/life-soul.PNG';
    if (k.contains('parkha')) return 'assets/images/astrology/parkha.PNG';
    if (k.contains('gu_mik') || k.contains('gumik')) return 'assets/images/astrology/gu mik.PNG';
    // Fallback for generic astrology
    if (k.isNotEmpty && !k.contains('viewuspdrive')) return 'assets/images/astrology/Tibetan astrology.jpg';
    return '';
  }

  String _restrictImg(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('birth') || v.contains('child')) return 'assets/images/astrology/10 daily restriction activities/baby.png';
    if (v.contains('bride') || v.contains('marriage') || v.contains('wedding')) return 'assets/images/astrology/10 daily restriction activities/bride.png';
    if (v.contains('business') || v.contains('commerce') || v.contains('trading')) return 'assets/images/astrology/10 daily restriction activities/commerce.png';
    if (v.contains('construction') || v.contains('building') || v.contains('moving')) return 'assets/images/astrology/10 daily restriction activities/construction.png';
    if (v.contains('funeral')) return 'assets/images/astrology/10 daily restriction activities/funerals.png';
    if (v.contains('guest') || v.contains('hosting')) return 'assets/images/astrology/10 daily restriction activities/guest.PNG';
    if (v.contains('kinship') || v.contains('family') || v.contains('gathering')) return 'assets/images/astrology/10 daily restriction activities/kinship.png';
    if (v.contains('legal') || v.contains('military') || v.contains('warfare')) return 'assets/images/astrology/10 daily restriction activities/military.png';
    if (v.contains('tomb') || v.contains('burial')) return 'assets/images/astrology/10 daily restriction activities/tombs.png';
    return 'assets/images/astrology/10 daily restriction activities/general.png';
  }

  String _meaning(Map<String, dynamic> a) => (a['meaning'] is Map) ? (a['meaning']['en']?.toString() ?? '') : '';

  String _detailCardId(String astroKey) {
    switch (astroKey) {
      case 'flag_day':
      case 'earth_lords':
      case 'flag_avoidance':
        return 'earth_lords';
      case 'torma_offering_direction':
      case 'torma_offering':
      case 'torma_day':
      case 'torma':
        return 'torma';
      case 'empty_vase_direction_bumtong':
      case 'empty_vase_bumtong':
      case 'empty_vase':
        return 'empty_vase';
      case 'inauspicious_day':
      case 'horse_death':
        return 'horse_death';
      case 'daily_restriction':
      case 'restrictions':
        return 'restrictions';
      case 'auspicious_time_periods':
      case 'auspicious_times':
      case 'auspicious_time':
        return 'auspicious_times';
      case 'naga_day':
      case 'naga_days':
        return 'naga_days';
      case 'fire_rituals':
      case 'fire_deity':
        return 'fire_rituals';
      case 'hair_cutting':
        return 'hair_cutting';
      case 'life_force_male':
        return 'life_force_male';
      case 'life_force_female':
        return 'life_force_female';
      case 'gu_mig':
        return 'gu_mig';
      case 'fatal_weekdays':
        return 'fatal_weekdays';
      case 'parkha':
        return 'parkha';
      default:
        return astroKey;
    }
  }

  // ─── BUILD ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : const Color(0xFFFAF5EF);

    if (_loading) return Scaffold(backgroundColor: bg, body: const Center(child: CircularProgressIndicator(color: AppColors.maroon)));

    final weekDay = DateFormat('EEEE').format(widget.date).toUpperCase();
    final day = widget.date.day;
    final tibDay = _flat?['tibetan_day'] ?? day;
    final tibMonth = _flat?['tibetan_month'] ?? widget.date.month;
    final tibYear = _flat?['tibetan_year'] ?? 2153;
    final animal = _flat?['animal'] ?? 'Dragon';
    final auspInfo = _raw?['content']?['auspicious_day_info_en'] as String? ?? '';
    final significance = _raw?['content']?['significance_en'] as String? ?? '';
    final element = _raw?['visual']?['element_combo_en'] as String? ?? '';
    final elMeaning = _raw?['visual']?['coincidence_meaning_en'] as String? ?? '';
    final lunarStatus = _raw?['tibetan']?['lunar_status_en'] as String?;
    final heroImg = _heroImgPath();
    final isSpecialDay = auspInfo.isNotEmpty;
    final heroLabel = isSpecialDay
        ? (auspInfo.toUpperCase().contains('GURU') ? 'PADMASAMBHAVA' : auspInfo.toUpperCase())
        : (_meaning(_a('inauspicious_day')).isNotEmpty ? _meaning(_a('inauspicious_day')).toUpperCase() : 'VAJRASANA');

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Stack(
                  children: [
                    // removed decorative background painter
                    Column(children: [
                      const SizedBox(height: 20),
                      // WEEKDAY — serif, maroon, normal spacing
                      Text(weekDay, style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 3,
                        color: isDark ? Colors.white70 : AppColors.maroon,
                        fontFamily: 'Georgia',
                      )),
                      const SizedBox(height: 0),
                      // BIG DAY — elegant serif
                      Text('$day', style: TextStyle(
                        fontSize: 96, fontWeight: FontWeight.w700, height: 1.1,
                        color: isDark ? Colors.white : AppColors.navy,
                        fontFamily: 'Georgia',
                      )),
                      // AUSPICIOUS LABEL + divider BELOW
                      if (isSpecialDay) ...[
                        const SizedBox(height: 2),
                        Text(auspInfo.toUpperCase(), style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3,
                          color: AppColors.goldDark,
                          fontFamily: 'Georgia',
                        )),
                        // divider line BELOW the text
                        Container(margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 10), height: 1, color: AppColors.gold.withOpacity(0.4)),
                      ],
                      const SizedBox(height: 8),
                      // HERO IMAGE
                      _heroSection(heroImg, heroLabel, isSpecialDay, isDark),
                      const SizedBox(height: 16),
                      // DATE / MONTH / YEAR
                      _dateTabs(tibDay, tibMonth, tibYear, animal, isDark),
                      const SizedBox(height: 8),
                      // LUNAR STATUS NOTE
                      if (lunarStatus != null && lunarStatus.isNotEmpty)
                        _lunarNote(lunarStatus, isDark),
                      const SizedBox(height: 12),
                      // SIGNIFICANCE or WISDOM
                      _significanceSection(isSpecialDay, auspInfo, significance, isDark),
                      // ELEMENT COMBINATION
                      if (element.isNotEmpty) _elementSection(element, elMeaning, isDark),
                      // ASTROLOGY
                      _astrologySection(isDark),
                      // EVENTS
                      _eventsSection(isDark),
                      // ADD TO CALENDAR
                      _addToCalBtn(isDark),
                      const SizedBox(height: 24),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ TOP MAROON HEADER ═══════════════════════════════
  Widget _header(bool isDark) {
    final lbl = DateFormat('MMM yyyy').format(widget.date).toUpperCase();
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.maroon,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Text('‹', style: TextStyle(fontSize: 26, color: Colors.white70, fontWeight: FontWeight.w300, height: 1)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const Spacer(),
          Text(lbl, style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
            letterSpacing: 3, fontFamily: 'Georgia',
          )),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ═══ HERO IMAGE SECTION (Arch shape with gold border) ═══
  Widget _heroSection(String imgPath, String label, bool isSpecial, bool isDark) {
    // For normal days (not auspicious) we hide the hero image and label
    if (!isSpecial) {
      return const SizedBox.shrink();
    }
    const archBR = BorderRadius.only(
      topLeft: Radius.circular(90),
      topRight: Radius.circular(90),
      bottomLeft: Radius.circular(8),
      bottomRight: Radius.circular(8),
    );
    const clipBR = BorderRadius.only(
      topLeft: Radius.circular(87),
      topRight: Radius.circular(87),
      bottomLeft: Radius.circular(6),
      bottomRight: Radius.circular(6),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 380,
      decoration: BoxDecoration(
        borderRadius: archBR,
        border: Border.all(color: AppColors.gold, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: clipBR,
        child: Container(
          // Use transparent background to avoid black edges
          color: Colors.transparent,
          child: Stack(
            children: [
              // Image area — always fill entire arch frame
              Positioned.fill(
                child: imgPath.isNotEmpty
                    ? Image.asset(
                        imgPath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: double.infinity,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => _defaultImg(isSpecial),
                      )
                    : _defaultImg(isSpecial),
              ),
              // Bottom gradient shadow (behind the pill button)
              Positioned(
                left: 0, right: 0, bottom: 0, height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isSpecial
                          ? [Colors.transparent, Colors.black.withOpacity(0.7)]
                          : [Colors.transparent, Colors.grey.withOpacity(0.15)],
                    ),
                  ),
                ),
              ),
              // Pill-shaped label button floating at bottom
              Positioned(
                left: 20, right: 20, bottom: 12,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Text(label, style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2,
                      color: AppColors.maroon,
                      fontFamily: 'Georgia',
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Decorative flower/asterisk icon for normal days
  Widget _defaultImg(bool isSpecial) {
    if (!isSpecial) {
      // White background + decorative golden flower on cream circle
      return Center(
        child: Container(
          width: 90, height: 90,
          decoration: const BoxDecoration(
            color: Color(0xFFF5EDE3),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star, size: 36, color: AppColors.goldDark),
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.brightness_7, size: 50,
        color: Colors.white.withOpacity(0.12),
      ),
    );
  }


  // ═══ DATE / MONTH / YEAR TABS ════════════════════════
  Widget _dateTabs(int tibDay, int tibMonth, int tibYear, String animal, bool isDark) {
    final monthName = _tibMonthName(tibMonth);
    final yearAnimal = _yearAnimal(widget.date.year);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(children: [
        // HEADER ROW: maroon
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Row(children: [
            _tabHdr('DATE'),
            _tabHdr('MONTH'),
            _tabHdr('YEAR'),
          ]),
        ),
        // VALUES ROW
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // DATE
              Expanded(child: Column(children: [
                Text(_ordinal(tibDay), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navy)),
              ])),
              Container(width: 1, height: 44, color: Colors.grey.withOpacity(0.15)),
              // MONTH
              Expanded(child: Column(children: [
                Text(animal.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.navy)),
                Text(monthName, style: TextStyle(fontSize: 9, color: AppColors.lightTextSecondary)),
                Text('$tibMonth', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navy)),
              ])),
              Container(width: 1, height: 44, color: Colors.grey.withOpacity(0.15)),
              // YEAR
              Expanded(child: Column(children: [
                Text(yearAnimal, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.lightTextSecondary)),
                Text('$tibYear', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navy)),
              ])),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _tabHdr(String t) => Expanded(child: Center(child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white))));

  // ═══ LUNAR NOTE ══════════════════════════════════════
  Widget _lunarNote(String s, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF43A047))),
        const SizedBox(width: 8),
        Expanded(child: Text(s.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF43A047)))),
      ]),
    );
  }

  // ═══ SIGNIFICANCE / WISDOM SECTION ═══════════════════
  Widget _significanceSection(bool isSpecial, String auspInfo, String sig, bool isDark) {
    if (sig.isEmpty && !isSpecial) return const SizedBox.shrink();

    // Parse title/body
    String title = '';
    String body = sig;
    if (isSpecial && sig.contains('\n')) {
      final parts = sig.split('\n');
      title = parts[0].trim();
      body = parts.sublist(1).join('\n').trim();
    } else if (isSpecial) {
      title = auspInfo;
      body = sig;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // section badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.maroon, borderRadius: BorderRadius.circular(6)),
          child: Text(isSpecial ? 'DAY SIGNIFICANCE' : 'DAILY WISDOM',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white)),
        ),
        const SizedBox(height: 14),
        if (isSpecial && title.isNotEmpty) ...[
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.3, color: AppColors.maroon, fontFamily: 'Georgia', fontStyle: FontStyle.italic)),
          const SizedBox(height: 10),
        ],
        if (isSpecial && body.isNotEmpty)
          Text(body, style: TextStyle(fontSize: 13, height: 1.7, color: isDark ? Colors.white70 : AppColors.lightText.withOpacity(0.7))),
        if (!isSpecial && sig.isNotEmpty) ...[
          // Wisdom quote
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.cream.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: AppColors.gold, width: 3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('"$sig"', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.6, color: isDark ? Colors.white70 : AppColors.lightText.withOpacity(0.75))),
              const SizedBox(height: 8),
              // Attribution removed for normal days
            ]),
          ),
        ],
        // Quote for special days
        if (isSpecial && body.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cream.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: AppColors.gold, width: 3)),
            ),
            child: Text(
              'Grant your blessing so that all harm from\nmāras, asuras, vicious earth lords and nāgas\nis completely eliminated.',
              style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, height: 1.5, color: isDark ? AppColors.goldLight : AppColors.goldDark),
            ),
          ),
        ],
      ]),
    );
  }

  // ═══ ELEMENT COMBINATION ═════════════════════════════
  Widget _elementSection(String el, String meaning, bool isDark) {
    String shortMeaning = meaning;
    if (meaning.contains(':')) shortMeaning = meaning.split(':').last.trim();
    if (shortMeaning.endsWith('.')) shortMeaning = shortMeaning.substring(0, shortMeaning.length - 1);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ELEMENT COMBINATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.maroon)),
        const SizedBox(height: 10),
        Center(child: Text(el.replaceAll('-', ' + ').toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navy))),
        const SizedBox(height: 4),
        Center(child: Text(shortMeaning, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.lightTextSecondary))),
      ]),
    );
  }

  // ═══ ASTROLOGY SECTION ═══════════════════════════════
  Widget _astrologySection(bool isDark) {
    final items = <Widget>[];

    final astro = _raw?['astrology'];
    if (astro is Map<String, dynamic>) {
      astro.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          // Friendly title from key
          final title = key
              .replaceAll('_', ' ')
              .replaceAll('day', 'Day')
              .replaceAll('flag', 'Flags')
              .replaceAll('torma offering', 'Torma Offering')
              .replaceAll('empty vase bumtong', 'Empty Vase Direction (Bumtong)')
              .replaceAll('auspicious times', 'Auspicious Time Periods')
              .split(' ')
              .map((e) => e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : '')
              .join(' ');

          if (key == 'auspicious_times' || key == 'auspicious_time_periods' || key == 'auspicious_time') {
            items.add(_timeRow(value, isDark));
          } else {
            items.add(_astroRow(key, title, value, isDark));
          }
        }
      });
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  // Row background color based on status
  Color _rowBg(String? s) {
    switch (s) {
      case 'extremely_auspicious': case 'auspicious': return const Color(0xFFE8F5E9);
      case 'avoid': return const Color(0xFFFFF0EE);
      case 'caution': return const Color(0xFFFFF8E1);
      default: return Colors.white;
    }
  }

  // Icon background color (darker saturated)
  Color _iconBgDark(String? s) {
    switch (s) {
      case 'extremely_auspicious': case 'auspicious': return const Color(0xFF2E7D32);
      case 'avoid': return const Color(0xFFC62828);
      case 'caution': return const Color(0xFFE65100);
      default: return const Color(0xFF546E7A);
    }
  }

  // Status emoji prefix
  String _statusPrefix(String? s) {
    switch (s) {
      case 'extremely_auspicious': case 'auspicious': return '✅ ';
      case 'avoid': return '❌ ';
      case 'caution': return '⚠️ ';
      default: return '';
    }
  }

  // Right side status widget (check/cross/warning + chevron)
  Widget _rightStatus(String? s) {
    Widget icon;
    if (s == 'extremely_auspicious' || s == 'auspicious') {
      icon = const Icon(Icons.check, color: Color(0xFF2E7D32), size: 20);
    } else if (s == 'avoid') {
      icon = const Icon(Icons.close, color: Color(0xFFC62828), size: 20);
    } else if (s == 'caution') {
      icon = const Icon(Icons.warning_amber, color: Color(0xFFE65100), size: 20);
    } else {
      icon = Text('—', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade400));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      icon,
      const SizedBox(width: 4),
      Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
    ]);
  }

  Widget _astroRow(String astroKey, String title, Map<String, dynamic> data, bool isDark, {String? customImg}) {
    final status = data['status_key']?.toString();
    final raw = data['raw']?.toString() ?? '';
    final imgKey = data['image_key']?.toString() ?? '';
    String imgPath = customImg ?? _astroImg(imgKey);

    // Fallback image based on title when no image_key
    if (imgPath.isEmpty) {
      final t = title.toLowerCase();
      if (t.contains('naga')) imgPath = 'assets/images/astrology/Naga-major.png';
      else if (t.contains('flag') || t.contains('prayer')) imgPath = 'assets/images/astrology/earth-lords(flag).PNG';
      else if (t.contains('hair')) imgPath = 'assets/images/astrology/Hair cut.PNG';
      else if (t.contains('inauspicious')) imgPath = 'assets/images/astrology/IMG_1807.PNG';
      else if (t.contains('fire')) imgPath = 'assets/images/astrology/fire deity.PNG';
      else if (t.contains('torma')) imgPath = 'assets/images/astrology/torma.PNG';
      else if (t.contains('vase') || t.contains('bumtong')) imgPath = 'assets/images/astrology/empty_vase.PNG';
      else if (t.contains('time')) imgPath = 'assets/images/astrology/auspicious time.PNG';
    }

    final color = _sColor(status);
    final prefix = _statusPrefix(status);

    String statusLabel = raw.isNotEmpty ? raw.toUpperCase() : (status?.toUpperCase().replaceAll('_', ' ') ?? 'N/A');

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        final statusKey = (data['status_key']?.toString() ?? '').toLowerCase();

        AstrologyStatus status;
        switch (statusKey) {
          case 'extremely_auspicious':
          case 'auspicious':
            status = AstrologyStatus.auspicious;
            break;
          case 'avoid':
          case 'inauspicious':
          case 'extremely_inauspicious':
            status = AstrologyStatus.inauspicious;
            break;
          case 'caution':
            status = AstrologyStatus.caution;
            break;
          case 'direction':
            status = AstrologyStatus.direction;
            break;
          case 'neutral':
          case 'not_applicable':
          default:
            status = AstrologyStatus.neutral;
            break;
        }

        final popupRaw = (data['raw']?.toString() ?? '').replaceAll('#', '').trim();

        final card = AstrologyCard(
          id: _detailCardId(astroKey),
          titleEn: title,
          titleBo: title,
          iconKey: imgPath,
          popupRaw: popupRaw,
          status: status,
          isActive: statusKey != 'not_applicable',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AstrologyDetailScreen(card: card),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : _rowBg(status),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          // Rounded-square icon with actual image
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _iconBgDark(status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imgPath.isNotEmpty
                  ? Image.asset(imgPath, fit: BoxFit.cover, width: 48, height: 48,
                      errorBuilder: (_, __, ___) => Center(child: Icon(Icons.auto_awesome, size: 22, color: _iconBgDark(status))))
                  : Center(child: Icon(Icons.auto_awesome, size: 22, color: _iconBgDark(status))),
            ),
          ),
          const SizedBox(width: 12),
          // TITLE + STATUS
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.navy)),
            const SizedBox(height: 3),
            Text('$prefix$statusLabel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ])),
          const SizedBox(width: 4),
          // Status icon + chevron
          _rightStatus(status),
        ]),
      ),
    );
  }

  Widget _timeRow(Map<String, dynamic> data, bool isDark) {
    final raw = data['raw']?.toString() ?? '';
    final timeList = raw.split('·').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        final statusKey = (data['status_key']?.toString() ?? '').toLowerCase();

        AstrologyStatus status;
        switch (statusKey) {
          case 'extremely_auspicious':
          case 'auspicious':
            status = AstrologyStatus.auspicious;
            break;
          case 'avoid':
          case 'inauspicious':
          case 'extremely_inauspicious':
            status = AstrologyStatus.inauspicious;
            break;
          case 'caution':
            status = AstrologyStatus.caution;
            break;
          case 'direction':
            status = AstrologyStatus.direction;
            break;
          case 'neutral':
          case 'not_applicable':
          default:
            status = AstrologyStatus.neutral;
            break;
        }

        final card = AstrologyCard(
          id: 'auspicious_times',
          titleEn: 'Auspicious Time Periods',
          titleBo: 'Auspicious Time Periods',
          iconKey: 'assets/images/astrology/auspicious time.PNG',
          popupRaw: raw,
          status: status,
          isActive: statusKey != 'not_applicable',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AstrologyDetailScreen(card: card),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.goldDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.schedule, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auspicious Time Periods',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeList.join('  '),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  // ═══ TODAY'S EVENTS ══════════════════════════════════
  Widget _eventsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("TODAY'S EVENTS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.maroon)),
        const SizedBox(height: 8),
        if (_events.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text('No special events on this date.', style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary))),
          )
        else
          ..._events.map((ev) => _eventCard(ev, isDark)),
      ]),
    );
  }

  Widget _eventCard(Map<String, dynamic> ev, bool isDark) {
    final title = ev['title_en'] ?? '';
    final desc = ev['description_en'] ?? '';
    final imgPath = ev['image_path'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: Row(children: [
        if (imgPath.isNotEmpty)
          Container(
            width: 48, height: 48,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.cream.withOpacity(0.5)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/$imgPath', fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.event, size: 24, color: AppColors.maroon)),
            ),
          ),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.navy)),
          if (desc.isNotEmpty) Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
        ])),
      ]),
    );
  }

  // ═══ ADD TO CALENDAR BUTTON ══════════════════════════
  Widget _addToCalBtn(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event added to your personal calendar (coming soon).'),
              backgroundColor: AppColors.maroon,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.maroon,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.maroon.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'ADD TO CALENDAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
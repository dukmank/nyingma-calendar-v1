import 'package:flutter/material.dart';
import 'theme_provider.dart';

/// Localization helper — call `L.of(context)` to get the right strings.
/// Uses ThemeService.language ('en' | 'bo') to pick the correct map.
class L {
  final String _lang;
  L._(this._lang);

  /// Factory using explicit language parameter
  factory L.withLang(String lang) => L._(lang);

  /// Default factory for backward compat — uses 'en' if no Riverpod ref available
  static L of(BuildContext context) {
    // Uses 'en' as default; screens using Riverpod should use L.withLang(themeService.language)
    return L._('en');
  }

  /// Generic lookup
  String _t(String key) {
    final map = _lang == 'bo' ? _bo : _en;
    return map[key] ?? _en[key] ?? key;
  }

  // ─── Navigation ──────────────────────────────────
  String get calendar => _t('calendar');
  String get auspicious => _t('auspicious');
  String get practice => _t('practice');
  String get events => _t('events');
  String get settings => _t('settings');

  // ─── Calendar Home ───────────────────────────────
  String get nyingmapaCalendar => _t('nyingmapa_calendar');
  String get today => _t('today');
  String get guruRinpocheDay => _t('guru_rinpoche_day');
  String get auspiciousDay => _t('auspicious_day');
  String get viewDetails => _t('view_details');
  String get monthlyEvents => _t('monthly_events');
  String get noEventsThisMonth => _t('no_events_this_month');
  String get day => _t('day');
  String get element => _t('element');
  String get animal => _t('animal');
  String get year => _t('year');

  // ─── Weekdays (short) ────────────────────────────
  String get sun => _t('sun');
  String get mon => _t('mon');
  String get tue => _t('tue');
  String get wed => _t('wed');
  String get thu => _t('thu');
  String get fri => _t('fri');
  String get sat => _t('sat');

  // ─── Day Details ─────────────────────────────────
  String get calendarDetails => _t('calendar_details');
  String get solarCalendar => _t('solar_calendar');
  String get lunarCalendar => _t('lunar_calendar');
  String get tibetanMonth => _t('tibetan_month');
  String get tibetanDay => _t('tibetan_day');
  String get lunarPhase => _t('lunar_phase');
  String get activities => _t('activities');
  String get moreActivities => _t('more_activities');
  String get dailyWisdom => _t('daily_wisdom');
  String get nagaDay => _t('naga_day');
  String get flagDay => _t('flag_day');
  String get hairCutting => _t('hair_cutting');
  String get horseDeathDay => _t('horse_death_day');
  String get close => _t('close');

  // ─── Naga Modal ──────────────────────────────────
  String get todayIsMajorNagaDay => _t('today_is_major_naga_day');
  String get todayIsMinorNagaDay => _t('today_is_minor_naga_day');
  String get todayIsNotNagaDay => _t('today_is_not_naga_day');
  String get nagaDaysThisMonth => _t('naga_days_this_month');
  String get majorNagaDays => _t('major_naga_days');
  String get minorNagaDays => _t('minor_naga_days');
  String get nagaBenefit => _t('naga_benefit');

  // ─── Hair Cutting Modal ──────────────────────────
  String get excellentForHairCut => _t('excellent_for_hair_cut');
  String get avoidHairCuttingToday => _t('avoid_hair_cutting_today');
  String get neutralDay => _t('neutral_day');
  String get complete30DayChart => _t('complete_30_day_chart');

  // ─── Flag Modal ──────────────────────────────────
  String get avoidHangingFlags => _t('avoid_hanging_flags');
  String get goodDayForFlags => _t('good_day_for_flags');
  String get upperPosition => _t('upper_position');
  String get middlePosition => _t('middle_position');
  String get lowerPosition => _t('lower_position');

  // ─── Auspicious Days ─────────────────────────────
  String get auspiciousDays => _t('auspicious_days');
  String get nextMilestone => _t('next_milestone');
  String get viewDayDetails => _t('view_day_details');
  String get setReminder => _t('set_reminder');
  String get significantDates => _t('significant_dates');
  String get lunarMonth => _t('lunar_month');

  // ─── Events ──────────────────────────────────────
  String get yearlyEvents => _t('yearly_events');
  String get filterEventsBy => _t('filter_events_by');
  String get all => _t('all');
  String get solarDate => _t('solar_date');
  String get lunarDate => _t('lunar_date');

  // ─── Practice ────────────────────────────────────
  String get nyingmaDharma => _t('nyingma_dharma');
  String get myProgress => _t('my_progress');
  String get thisMonth => _t('this_month');
  String get monthlyGoalCompletion => _t('monthly_goal_completion');
  String get dailyTracker => _t('daily_tracker');
  String get dayStreak => _t('day_streak');
  String get personalEvents => _t('personal_events');
  String get quickAdd => _t('quick_add');
  String get totalEvents => _t('total_events');
  String get synced => _t('synced');
  String get practices => _t('practices');
  String get addEvent => _t('add_event');
  String get lunarCycle => _t('lunar_cycle');
  String get solar => _t('solar');
  String get lunar => _t('lunar');
  String get viewAll => _t('view_all');
  String get next => _t('next');
  String get detail => _t('detail');

  // ─── Settings ────────────────────────────────────
  String get appearance => _t('appearance');
  String get darkMode => _t('dark_mode');
  String get highContrast => _t('high_contrast');
  String get language => _t('language');
  String get notifications => _t('notifications');
  String get sacredDayAlerts => _t('sacred_day_alerts');
  String get practiceReminders => _t('practice_reminders');
  String get eventNotifications => _t('event_notifications');
  String get calendarSettings => _t('calendar_settings');
  String get about => _t('about');

  // ─── Onboarding ──────────────────────────────────
  String get getStarted => _t('get_started');
  String get welcomeTo => _t('welcome_to');
  String get skip => _t('skip');
  String get continueText => _t('continue');
  String get selectYourLanguage => _t('select_your_language');
  String get enableSacredAlerts => _t('enable_sacred_alerts');
  String get enableAccess => _t('enable_access');
  String get maybeLater => _t('maybe_later');

  // ─── Months ──────────────────────────────────────
  String get january => _t('january');
  String get february => _t('february');
  String get march => _t('march');
  String get april => _t('april');
  String get may => _t('may');
  String get june => _t('june');
  String get july => _t('july');
  String get august => _t('august');
  String get september => _t('september');
  String get october => _t('october');
  String get november => _t('november');
  String get december => _t('december');

  String monthName(int month) {
    const keys = ['', 'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'];
    return _t(keys[month]);
  }

  String weekdayShort(int weekday) {
    // 0=Sun, 1=Mon, ...
    const keys = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    return _t(keys[weekday]);
  }

  // ═══════════════════════════════════════════════════
  // ENGLISH STRINGS
  // ═══════════════════════════════════════════════════
  static const Map<String, String> _en = {
    // Navigation
    'calendar': 'Calendar',
    'auspicious': 'Auspicious',
    'practice': 'Practice',
    'events': 'Events',
    'settings': 'Settings',

    // Calendar Home
    'nyingmapa_calendar': 'Nyingmapa Calendar',
    'today': 'TODAY',
    'guru_rinpoche_day': 'Guru Rinpoche Day',
    'auspicious_day': 'Auspicious Day',
    'view_details': 'View Details',
    'monthly_events': 'MONTHLY EVENTS',
    'no_events_this_month': 'No events this month',
    'day': 'Day',
    'element': 'Element',
    'animal': 'Animal',
    'year': 'Year',

    // Weekdays
    'sun': 'Sun',
    'mon': 'Mon',
    'tue': 'Tue',
    'wed': 'Wed',
    'thu': 'Thu',
    'fri': 'Fri',
    'sat': 'Sat',

    // Day Details
    'calendar_details': 'CALENDAR DETAILS',
    'solar_calendar': 'SOLAR CALENDAR',
    'lunar_calendar': 'LUNAR CALENDAR',
    'tibetan_month': 'Tibetan Month',
    'tibetan_day': 'Tibetan Day',
    'lunar_phase': 'Lunar Phase',
    'activities': 'AUSPICIOUS / INAUSPICIOUS ACTIVITIES',
    'more_activities': 'MORE ACTIVITIES',
    'daily_wisdom': 'DAILY WISDOM',
    'naga_day': 'Naga Day',
    'flag_day': 'Flag Day',
    'hair_cutting': 'Hair Cutting',
    'horse_death_day': 'Horse Death',
    'close': 'CLOSE',

    // Naga
    'today_is_major_naga_day': 'TODAY IS A MAJOR NAGA DAY',
    'today_is_minor_naga_day': 'TODAY IS A MINOR NAGA DAY',
    'today_is_not_naga_day': 'TODAY IS NOT A NAGA DAY',
    'naga_days_this_month': 'NAGA DAYS THIS MONTH',
    'major_naga_days': 'MAJOR NAGA DAYS (Klu Theb Che-ba)',
    'minor_naga_days': 'MINOR NAGA DAYS (Klu Theb Chung-ba)',
    'naga_benefit': 'It is beneficial to perform Lu Tor (naga torma offerings) and Lu Sang (naga incense offering) today.',

    // Hair
    'excellent_for_hair_cut': 'EXCELLENT FOR HAIR CUT',
    'avoid_hair_cutting_today': 'AVOID HAIR CUTTING TODAY',
    'neutral_day': 'NEUTRAL DAY',
    'complete_30_day_chart': 'COMPLETE 30-DAY CHART',

    // Flag
    'avoid_hanging_flags': 'AVOID HANGING PRAYER FLAGS TODAY',
    'good_day_for_flags': 'GOOD DAY FOR PRAYER FLAGS',
    'upper_position': 'UPPER POSITION',
    'middle_position': 'MIDDLE POSITION',
    'lower_position': 'LOWER POSITION',

    // Auspicious Days
    'auspicious_days': 'Auspicious Days',
    'next_milestone': 'NEXT MILESTONE',
    'view_day_details': 'View Day Details',
    'set_reminder': 'Set Reminder',
    'significant_dates': 'SIGNIFICANT DATES',
    'lunar_month': 'Lunar Month',

    // Events
    'yearly_events': 'Yearly Events',
    'filter_events_by': 'Filter Events by',
    'all': 'All',
    'solar_date': 'SOLAR\nCALENDAR',
    'lunar_date': 'LUNAR\nCALENDAR',

    // Practice
    'nyingma_dharma': 'NYINGMA DHARMA',
    'my_progress': 'My Progress',
    'this_month': 'THIS MONTH',
    'monthly_goal_completion': 'MONTHLY GOAL COMPLETION',
    'daily_tracker': 'Daily Tracker',
    'day_streak': 'Day Streak',
    'personal_events': 'PERSONAL EVENTS',
    'quick_add': 'Quick Add',
    'total_events': 'TOTAL\nEVENTS',
    'synced': 'SYNCED',
    'practices': 'PRACTICES',
    'add_event': 'Add Event',
    'lunar_cycle': 'LUNAR CYCLE',
    'solar': 'Solar',
    'lunar': 'Lunar',
    'view_all': 'View All',
    'next': 'NEXT',
    'detail': 'DETAIL',

    // Settings
    'appearance': 'APPEARANCE',
    'dark_mode': 'Dark Mode',
    'high_contrast': 'High Contrast',
    'language': 'LANGUAGE',
    'notifications': 'NOTIFICATIONS',
    'sacred_day_alerts': 'Sacred Day Alerts',
    'practice_reminders': 'Practice Reminders',
    'event_notifications': 'Event Notifications',
    'calendar_settings': 'CALENDAR SETTINGS',
    'about': 'ABOUT',

    // Onboarding
    'get_started': 'Get Started',
    'welcome_to': 'Welcome to',
    'skip': 'Skip',
    'continue': 'Continue',
    'select_your_language': 'Select Your Language',
    'enable_sacred_alerts': 'Enable Sacred\nAlerts',
    'enable_access': 'Enable Access',
    'maybe_later': 'MAYBE LATER',

    // Months
    'january': 'January',
    'february': 'February',
    'march': 'March',
    'april': 'April',
    'may': 'May',
    'june': 'June',
    'july': 'July',
    'august': 'August',
    'september': 'September',
    'october': 'October',
    'november': 'November',
    'december': 'December',
  };

  // ═══════════════════════════════════════════════════
  // TIBETAN STRINGS (བོད་ཡིག)
  // ═══════════════════════════════════════════════════
  static const Map<String, String> _bo = {
    // Navigation
    'calendar': 'ཟླ་ཐོ།',
    'auspicious': 'བཀྲ་ཤིས།',
    'practice': 'ཉམས་ལེན།',
    'events': 'འཆར་གཞི།',
    'settings': 'སྒྲིག་འགོད།',

    // Calendar Home
    'nyingmapa_calendar': 'རྙིང་མའི་ཟླ་ཐོ།',
    'today': 'དེ་རིང།',
    'guru_rinpoche_day': 'གུ་རུའི་ཚེས་བཅུ།',
    'auspicious_day': 'བཀྲ་ཤིས་ཉིན།',
    'view_details': 'ཞིབ་ཕྲ་ལྟ།',
    'monthly_events': 'ཟླ་བའི་འཆར་གཞི།',
    'no_events_this_month': 'ཟླ་འདིར་འཆར་གཞི་མེད།',
    'day': 'ཉིན།',
    'element': 'འབྱུང་བ།',
    'animal': 'ལོ་རྟགས།',
    'year': 'ལོ།',

    // Weekdays
    'sun': 'ཉི།',
    'mon': 'ཟླ།',
    'tue': 'མིག།',
    'wed': 'ལྷག།',
    'thu': 'ཕུར།',
    'fri': 'སངས།',
    'sat': 'སྤེན།',

    // Day Details
    'calendar_details': 'ཟླ་ཐོའི་ཞིབ་གནས།',
    'solar_calendar': 'ཉི་མའི་ཟླ་ཐོ།',
    'lunar_calendar': 'ཟླ་བའི་ཟླ་ཐོ།',
    'tibetan_month': 'བོད་ཟླ།',
    'tibetan_day': 'བོད་ཚེས།',
    'lunar_phase': 'ཟླ་བའི་རྣམ་པ།',
    'activities': 'བཀྲ་ཤིས་/མ་བཀྲ་ཤིས་བྱ་བ།',
    'more_activities': 'བྱ་བ་ཁ་ཤས།',
    'daily_wisdom': 'ཉིན་རེའི་ཤེས་རབ།',
    'naga_day': 'ཀླུ་ཐེབས།',
    'flag_day': 'དར་ལྕོག།',
    'hair_cutting': 'སྐྲ་བཅད།',
    'horse_death_day': 'རྟ་ཤི།',
    'close': 'སྒོ་རྒྱག།',

    // Naga
    'today_is_major_naga_day': 'དེ་རིང་ཀླུ་ཐེབས་ཆེན་པོའི་ཉིན་ཡིན།',
    'today_is_minor_naga_day': 'དེ་རིང་ཀླུ་ཐེབས་ཆུང་བའི་ཉིན་ཡིན།',
    'today_is_not_naga_day': 'དེ་རིང་ཀླུ་ཐེབས་ཀྱི་ཉིན་མིན།',
    'naga_days_this_month': 'ཟླ་འདིའི་ཀླུ་ཐེབས་ཉིན།',
    'major_naga_days': 'ཀླུ་ཐེབས་ཆེན་པོ།',
    'minor_naga_days': 'ཀླུ་ཐེབས་ཆུང་བ།',
    'naga_benefit': 'དེ་རིང་ཀླུ་གཏོར་དང་ཀླུ་བསང་མཆོད་ན་ཕན་ཐོགས་ཡོད།',

    // Hair
    'excellent_for_hair_cut': 'སྐྲ་བཅད་ན་ཧ་ཅང་བཟང་།',
    'avoid_hair_cutting_today': 'དེ་རིང་སྐྲ་མ་བཅད་ན་བཟང་།',
    'neutral_day': 'བར་མའི་ཉིན།',
    'complete_30_day_chart': 'ཉིན་༣༠ གི་རེའུ་མིག',

    // Flag
    'avoid_hanging_flags': 'དེ་རིང་དར་ལྕོག་མ་བཏགས།',
    'good_day_for_flags': 'དར་ལྕོག་བཏགས་ན་བཟང་བའི་ཉིན།',
    'upper_position': 'སྟེང་གི་གནས།',
    'middle_position': 'བར་གྱི་གནས།',
    'lower_position': 'འོག་གི་གནས།',

    // Auspicious Days
    'auspicious_days': 'བཀྲ་ཤིས་ཉིན་གྲངས།',
    'next_milestone': 'རྗེས་མའི་གྲངས་འཛིན།',
    'view_day_details': 'ཉིན་གྱི་ཞིབ་ཕྲ།',
    'set_reminder': 'དྲན་གསོ་བཀོད།',
    'significant_dates': 'གལ་ཆེའི་ཚེས་གྲངས།',
    'lunar_month': 'ཟླ་བའི་ཟླ།',

    // Events
    'yearly_events': 'ལོ་འཁོར་འཆར་གཞི།',
    'filter_events_by': 'འཆར་གཞི་གདམ་ག',
    'all': 'ཚང་མ།',
    'solar_date': 'ཉི་མའི།\nཟླ་ཐོ།',
    'lunar_date': 'ཟླ་བའི།\nཟླ་ཐོ།',

    // Practice
    'nyingma_dharma': 'རྙིང་མའི་ཆོས།',
    'my_progress': 'ངའི་ཡར་རྒྱས།',
    'this_month': 'ཟླ་འདི།',
    'monthly_goal_completion': 'ཟླ་བའི་དམིགས་འབེན་གྲུབ་ཚད།',
    'daily_tracker': 'ཉིན་རེའི་ཉམས་ལེན།',
    'day_streak': 'ཉིན་མཐུད།',
    'personal_events': 'སྒེར་གྱི་འཆར་གཞི།',
    'quick_add': 'མགྱོགས་སྣོན།',
    'total_events': 'འཆར་གཞི།\nཚང་མ།',
    'synced': 'མཐུན་འབྲེལ།',
    'practices': 'ཉམས་ལེན།',
    'add_event': 'འཆར་གཞི་སྣོན།',
    'lunar_cycle': 'ཟླ་བའི་འཁོར།',
    'solar': 'ཉི་མའི།',
    'lunar': 'ཟླ་བའི།',
    'view_all': 'ཚང་མ་ལྟ།',
    'next': 'རྗེས་མ།',
    'detail': 'ཞིབ་ཕྲ།',

    // Settings
    'appearance': 'མཐོང་སྣང་།',
    'dark_mode': 'མུན་པའི་བཟོ་དབྱིབས།',
    'high_contrast': 'མཐོ་གསལ།',
    'language': 'སྐད་ཡིག',
    'notifications': 'བརྡ་ཐོ།',
    'sacred_day_alerts': 'དམ་པའི་ཉིན་བརྡ་ཐོ།',
    'practice_reminders': 'ཉམས་ལེན་དྲན་གསོ།',
    'event_notifications': 'འཆར་གཞིའི་བརྡ་ཐོ།',
    'calendar_settings': 'ཟླ་ཐོའི་སྒྲིག་འགོད།',
    'about': 'སྐོར།',

    // Onboarding
    'get_started': 'འགོ་འཛུགས།',
    'welcome_to': 'བསུ་བ་ཞུ།',
    'skip': 'མཆོང་།',
    'continue': 'མུ་མཐུད།',
    'select_your_language': 'སྐད་ཡིག་གདམ་ག',
    'enable_sacred_alerts': 'དམ་པའི་བརྡ་ཐོ།\nཕྱེ་བ།',
    'enable_access': 'སྤྱོད་ཆོག་ཕྱེ།',
    'maybe_later': 'ཕྱིས་རྗེས།',

    // Months (Tibetan)
    'january': 'ཟླ་དང་པོ།',
    'february': 'ཟླ་གཉིས་པ།',
    'march': 'ཟླ་གསུམ་པ།',
    'april': 'ཟླ་བཞི་པ།',
    'may': 'ཟླ་ལྔ་པ།',
    'june': 'ཟླ་དྲུག་པ།',
    'july': 'ཟླ་བདུན་པ།',
    'august': 'ཟླ་བརྒྱད་པ།',
    'september': 'ཟླ་དགུ་པ།',
    'october': 'ཟླ་བཅུ་པ།',
    'november': 'ཟླ་བཅུ་གཅིག་པ།',
    'december': 'ཟླ་བཅུ་གཉིས་པ།',
  };
}

import '../../../domain/entities/day_entity.dart';

class CalendarDayVM {
  final String dateKey;
  final int dayNumber;
  final bool isHighlight;

  final String gregorianMonthLabelEn;
  final String gregorianMonthLabelBo;
  final String gregorianDayNameEn;
  final String gregorianDayNameBo;

  final String lunarDate;
  final String lunarMonthLabelEn;
  final String lunarMonthLabelBo;
  final String lunarYearLabelEn;
  final String lunarYearLabelBo;

  final String dayElement;
  final String monthAnimal;
  final String yearElement;

  final List<String> eventIds;

  CalendarDayVM({
    required this.dateKey,
    required this.dayNumber,
    required this.isHighlight,
    required this.gregorianMonthLabelEn,
    required this.gregorianMonthLabelBo,
    required this.gregorianDayNameEn,
    required this.gregorianDayNameBo,
    required this.lunarDate,
    required this.lunarMonthLabelEn,
    required this.lunarMonthLabelBo,
    required this.lunarYearLabelEn,
    required this.lunarYearLabelBo,
    required this.dayElement,
    required this.monthAnimal,
    required this.yearElement,
    required this.eventIds,
  });

  factory CalendarDayVM.fromEntity(DayEntity day) {
    return CalendarDayVM(
      dateKey: day.dateKey,
      dayNumber: day.gregorian.day,
      isHighlight: day.flags.isExtremelyAuspicious,

      gregorianMonthLabelEn: day.gregorian.monthLabelEn ?? '',
      gregorianMonthLabelBo: day.gregorian.monthLabelBo ?? '',
      gregorianDayNameEn: day.gregorian.dayNameEn ?? '',
      gregorianDayNameBo: day.gregorian.dayNameBo ?? '',

      lunarDate: day.tibetan.dayLabelBo ?? '',
      lunarMonthLabelEn: day.tibetan.month?.toString() ?? '',
      lunarMonthLabelBo: day.tibetan.monthLabelBo ?? '',
      lunarYearLabelEn: day.tibetan.year?.toString() ?? '',
      lunarYearLabelBo: day.tibetan.yearLabelBo ?? '',

      dayElement: day.visual.elementComboEn ?? '',
      monthAnimal: day.tibetan.animalMonthEn ?? '',
      yearElement: day.visual.elementComboEn ?? '',

      eventIds: day.eventIds,
    );
  }
}
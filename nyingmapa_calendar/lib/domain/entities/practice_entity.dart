class PracticeEntity {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String calendarType;
  final String repeat;
  final String reminder;
  final int color;

  const PracticeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.calendarType,
    required this.repeat,
    required this.reminder,
    required this.color,
  });
}

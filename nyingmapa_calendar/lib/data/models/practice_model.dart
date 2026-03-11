class PracticeModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String calendarType;
  final String repeat;
  final String reminder;
  final int color;

  PracticeModel({
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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "date": date,
      "time": time,
      "calendarType": calendarType,
      "repeat": repeat,
      "reminder": reminder,
      "color": color,
    };
  }

  factory PracticeModel.fromJson(Map<String, dynamic> json) {
    return PracticeModel(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      date: json["date"],
      time: json["time"],
      calendarType: json["calendarType"],
      repeat: json["repeat"],
      reminder: json["reminder"],
      color: json["color"],
    );
  }
}
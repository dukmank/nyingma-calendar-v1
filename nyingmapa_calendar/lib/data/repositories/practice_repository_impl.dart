import '../../domain/entities/practice_entity.dart';
import '../../services/local_data_service.dart';

class PracticeRepositoryImpl {

  Future<List<PracticeEntity>> getAllPractices() async {
    final data = await LocalDataService.getUserPractices();

    return data.map<PracticeEntity>((p) {
      return PracticeEntity(
        id: (p["id"] ?? "").toString(),
        title: p["title"] ?? "",
        description: p["description"] ?? "",
        date: p["date"] ?? "",
        time: p["time"] ?? "",
        calendarType: p["calendar_type"] ?? "",
        repeat: p["repeat"] ?? "",
        reminder: p["reminder"] ?? "",
        color: p["color"] ?? 0,
      );
    }).toList();
  }

  Future<void> createPractice(PracticeEntity practice) async {
    final data = {
      "id": practice.id,
      "title": practice.title,
      "description": practice.description,
      "date": practice.date,
      "time": practice.time,
      "calendar_type": practice.calendarType,
      "repeat": practice.repeat,
      "reminder": practice.reminder,
      "color": practice.color,
    };

    await LocalDataService.createUserPractice(data);
  }

  Future<void> deletePractice(String id) async {
    await LocalDataService.deleteUserPractice(int.parse(id));
  }
}

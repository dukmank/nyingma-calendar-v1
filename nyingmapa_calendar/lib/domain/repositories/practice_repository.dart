import '../entities/practice_entity.dart';

abstract class PracticeRepository {

  Future<List<PracticeEntity>> getAll();

  Future<void> createPractice(PracticeEntity practice);

  Future<void> updatePractice(PracticeEntity practice);

  Future<void> deletePractice(String id);
}
import '../../domain/entities/event_entity.dart';

class EventModel {
  final String id;
  final String dateKey;

  final String titleEn;
  final String? titleBo;

  final String? detailsEn;
  final String? detailsBo;

  final String? imageKey; // hero/thumbnail key (optional)

  EventModel({
    required this.id,
    required this.titleEn,
    required this.dateKey,
    this.titleBo,
    this.detailsEn,
    this.detailsBo,
    this.imageKey,
  });

  static String? _asString(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    return v.toString();
    }

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return <String, dynamic>{};
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // schema v2: title/details are nested objects
    final title = _asMap(json['title']);
    final details = _asMap(json['details']);
    final assets = _asMap(json['assets']);

    final id = _asString(json['id'] ?? json['event_id']) ?? '';

    final titleEn = (_asString(title['en'] ?? json['title_en'] ?? json['titleEn']) ?? '').trim();
    if (titleEn.isEmpty) {
      // DEBUG: inspect raw json structure when title is empty
      // ignore: avoid_print
      print('⚠️ EventModel.fromJson -> EMPTY TITLE for json: $json');
    }
    final titleBo = _asString(title['bo'] ?? json['title_bo'] ?? json['titleBo']);

    final detailsEn = _asString(details['en'] ?? json['details_en'] ?? json['detailsEn']);
    final detailsBo = _asString(details['bo'] ?? json['details_bo'] ?? json['detailsBo']);

    // assets.hero_key / assets.thumbnail_key (schema v2)
    final imageKey = _asString(assets['hero_key'] ?? assets['thumbnail_key'] ?? json['image_key']);

    return EventModel(
      id: id,
      dateKey: _asString(json['date_key'] ?? json['dateKey']) ?? '',
      titleEn: titleEn,
      titleBo: titleBo,
      detailsEn: detailsEn,
      detailsBo: detailsBo,
      imageKey: imageKey,
    );
  }

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      dateKey: dateKey,
      titleEn: titleEn,
      titleBo: titleBo,
      detailsEn: detailsEn,
      detailsBo: detailsBo,
      imageKey: imageKey,
    );
  }
}
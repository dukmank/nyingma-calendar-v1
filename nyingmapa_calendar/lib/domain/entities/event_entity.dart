class EventEntity {
  final String id;
  final String dateKey;

  final String titleEn;
  final String? titleBo;

  final String? detailsEn;
  final String? detailsBo;

  final String? imageKey;

  const EventEntity({
    required this.id,
    required this.dateKey,
    required this.titleEn,
    this.titleBo,
    this.detailsEn,
    this.detailsBo,
    this.imageKey,
  });

  /// Convenience empty factory (useful for safe fallbacks)
  factory EventEntity.empty() {
    return const EventEntity(
      id: '',
      dateKey: '',
      titleEn: '',
    );
  }

  EventEntity copyWith({
    String? id,
    String? dateKey,
    String? titleEn,
    String? titleBo,
    String? detailsEn,
    String? detailsBo,
    String? imageKey,
  }) {
    return EventEntity(
      id: id ?? this.id,
      dateKey: dateKey ?? this.dateKey,
      titleEn: titleEn ?? this.titleEn,
      titleBo: titleBo ?? this.titleBo,
      detailsEn: detailsEn ?? this.detailsEn,
      detailsBo: detailsBo ?? this.detailsBo,
      imageKey: imageKey ?? this.imageKey,
    );
  }
}
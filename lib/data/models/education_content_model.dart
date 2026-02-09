import '../../domain/entities/education_content.dart';

class EducationContentModel extends EducationContent {
  const EducationContentModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.body,
    required super.category,
    required super.orderIndex,
    super.imageUrl,
    super.isRead,
  });

  factory EducationContentModel.fromJson(Map<String, dynamic> json) {
    final content = json['content'] ?? '';
    return EducationContentModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      summary: content.length > 100
          ? '${content.substring(0, 100)}...'
          : content,
      body: content,
      category: json['topic'] ?? '',
      orderIndex: json['order'] ?? 0,
      isRead: false,
    );
  }
}

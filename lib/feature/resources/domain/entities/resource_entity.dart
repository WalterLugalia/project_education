enum ResourceSource { openLibrary, devTo, manual }

enum ResourceType { book, article, website, documentation, tutorial }
enum ContentFormat { markdown, html, pdf, epub, unavailable }

class ResourceEntity {
  final String id;
  final ResourceSource source;
  final String? externalId;

  final ResourceType type;
  final String title;
  final String? author;
  final String? description;
  final String? categoryId;
  final String? categoryName;

  final String? contentText;
final String? contentUrl;
final ContentFormat contentFormat;

  final String? coverImageUrl;
  final String resourceUrl;

  final double? rating;
  final int? readingTimeMinutes;

  final DateTime createdAt;

  const ResourceEntity({
    required this.id,
    required this.source,
    this.externalId,
    required this.type,
    required this.title,
    this.author,
    this.description,
    this.categoryId,
    this.categoryName,
    this.coverImageUrl,
    required this.resourceUrl,
    this.rating,
    this.readingTimeMinutes,
    required this.createdAt,
    this.contentText,
    this.contentUrl,
    required this.contentFormat,
  });
}
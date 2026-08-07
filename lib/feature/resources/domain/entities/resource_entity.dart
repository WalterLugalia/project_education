enum ResourceSource { openLibrary, devTo, manual }

enum ResourceType { book, article, website, documentation, tutorial }

class ResourceEntity {
  final String id;
  final ResourceSource source;
  final String? externalId;

  final ResourceType type;
  final String title;
  final String? author;
  final String? description;
  final String? categoryId;

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
    this.coverImageUrl,
    required this.resourceUrl,
    this.rating,
    this.readingTimeMinutes,
    required this.createdAt,
  });
}
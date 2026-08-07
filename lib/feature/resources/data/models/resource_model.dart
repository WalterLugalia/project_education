import '../../domain/entities/resource_entity.dart';

class ResourceModel extends ResourceEntity {
  const ResourceModel({
    required super.id,
    required super.source,
    super.externalId,
    required super.type,
    required super.title,
    super.author,
    super.description,
    super.categoryId,
    super.coverImageUrl,
    required super.resourceUrl,
    super.rating,
    super.readingTimeMinutes,
    required super.createdAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as String,
      source: _sourceFromString(json['source'] as String),
      externalId: json['external_id'] as String?,
      type: _typeFromString(json['type'] as String),
      title: json['title'] as String,
      author: json['author'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      resourceUrl: json['resource_url'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      readingTimeMinutes: json['reading_time_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': _sourceToString(source),
        'external_id': externalId,
        'type': _typeToString(type),
        'title': title,
        'author': author,
        'description': description,
        'category_id': categoryId,
        'cover_image_url': coverImageUrl,
        'resource_url': resourceUrl,
        'rating': rating,
        'reading_time_minutes': readingTimeMinutes,
        'created_at': createdAt.toIso8601String(),
      };

  static ResourceSource _sourceFromString(String value) {
    switch (value) {
      case 'open_library':
        return ResourceSource.openLibrary;
      case 'dev_to':
        return ResourceSource.devTo;
      default:
        return ResourceSource.manual;
    }
  }

  static String _sourceToString(ResourceSource source) {
    switch (source) {
      case ResourceSource.openLibrary:
        return 'open_library';
      case ResourceSource.devTo:
        return 'dev_to';
      case ResourceSource.manual:
        return 'manual';
    }
  }

  static ResourceType _typeFromString(String value) {
    switch (value) {
      case 'book':
        return ResourceType.book;
      case 'article':
        return ResourceType.article;
      case 'website':
        return ResourceType.website;
      case 'documentation':
        return ResourceType.documentation;
      case 'tutorial':
        return ResourceType.tutorial;
      default:
        return ResourceType.website;
    }
  }

  static String _typeToString(ResourceType type) {
    switch (type) {
      case ResourceType.book:
        return 'book';
      case ResourceType.article:
        return 'article';
      case ResourceType.website:
        return 'website';
      case ResourceType.documentation:
        return 'documentation';
      case ResourceType.tutorial:
        return 'tutorial';
    }
  }
}
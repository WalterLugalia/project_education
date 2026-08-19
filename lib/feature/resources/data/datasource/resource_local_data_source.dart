import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/resource_model.dart';

abstract class ResourceLocalDataSource {
  Future<void> cacheHomeFeed(List<ResourceModel> resources);
  List<ResourceModel> getCachedHomeFeed();

  Future<void> cacheCategoryResources(String categoryId, List<ResourceModel> resources);
  List<ResourceModel> getCachedCategoryResources(String categoryId);

  Future<void> cacheSearchResults(String query, List<ResourceModel> resources);
  List<ResourceModel>? getCachedSearchResults(String query);

  Future<void> cacheResourceDetails(ResourceModel resource);
  ResourceModel? getCachedResourceDetails(String resourceId);
}

class ResourceLocalDataSourceImpl implements ResourceLocalDataSource {
  final Box<String> cacheBox;

  ResourceLocalDataSourceImpl({required this.cacheBox});

  static const String _homeFeedKey = 'home_feed';
  static String _categoryKey(String categoryId) => 'category_$categoryId';
  static String _searchKey(String query) => 'search_${query.toLowerCase().trim()}';
  static String _resourceKey(String resourceId) => 'resource_$resourceId';

  @override
  Future<void> cacheHomeFeed(List<ResourceModel> resources) async {
    await cacheBox.put(_homeFeedKey, jsonEncode(resources.map((r) => r.toJson()).toList()));
  }

  @override
  List<ResourceModel> getCachedHomeFeed() => _decodeList(cacheBox.get(_homeFeedKey));

  @override
  Future<void> cacheCategoryResources(String categoryId, List<ResourceModel> resources) async {
    await cacheBox.put(
      _categoryKey(categoryId),
      jsonEncode(resources.map((r) => r.toJson()).toList()),
    );
  }

  @override
  List<ResourceModel> getCachedCategoryResources(String categoryId) =>
      _decodeList(cacheBox.get(_categoryKey(categoryId)));

  @override
  Future<void> cacheSearchResults(String query, List<ResourceModel> resources) async {
    await cacheBox.put(_searchKey(query), jsonEncode(resources.map((r) => r.toJson()).toList()));
  }

  @override
  List<ResourceModel>? getCachedSearchResults(String query) {
    final raw = cacheBox.get(_searchKey(query));
    if (raw == null) return null;
    return _decodeList(raw);
  }

  @override
  Future<void> cacheResourceDetails(ResourceModel resource) async {
    await cacheBox.put(_resourceKey(resource.id), jsonEncode(resource.toJson()));
  }

  @override
  ResourceModel? getCachedResourceDetails(String resourceId) {
    final raw = cacheBox.get(_resourceKey(resourceId));
    if (raw == null) return null;
    return ResourceModel.fromCachedJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<ResourceModel> _decodeList(String? raw) {
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((json) => ResourceModel.fromCachedJson(json as Map<String, dynamic>))
        .toList();
  }
}
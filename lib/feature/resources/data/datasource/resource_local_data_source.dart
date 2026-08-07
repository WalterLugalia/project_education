import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/resource_model.dart';

abstract class ResourceLocalDataSource {
  Future<void> cacheHomeFeed(List<ResourceModel> resources);
  List<ResourceModel> getCachedHomeFeed();

  Future<void> cacheCategoryResources(String categoryId, List<ResourceModel> resources);
  List<ResourceModel> getCachedCategoryResources(String categoryId);
}

class ResourceLocalDataSourceImpl implements ResourceLocalDataSource {
  final Box<String> cacheBox;

  ResourceLocalDataSourceImpl({required this.cacheBox});

  static const String _homeFeedKey = 'home_feed';
  static String _categoryKey(String categoryId) => 'category_$categoryId';

  @override
  Future<void> cacheHomeFeed(List<ResourceModel> resources) async {
    final jsonList = resources.map((r) => r.toJson()).toList();
    await cacheBox.put(_homeFeedKey, jsonEncode(jsonList));
  }

  @override
  List<ResourceModel> getCachedHomeFeed() {
    final raw = cacheBox.get(_homeFeedKey);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((json) => ResourceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheCategoryResources(String categoryId, List<ResourceModel> resources) async {
    final jsonList = resources.map((r) => r.toJson()).toList();
    await cacheBox.put(_categoryKey(categoryId), jsonEncode(jsonList));
  }

  @override
  List<ResourceModel> getCachedCategoryResources(String categoryId) {
    final raw = cacheBox.get(_categoryKey(categoryId));
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((json) => ResourceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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

  Future<void> cacheArticleContent(String resourceId, String markdown);
  String? getCachedArticleContent(String resourceId);

  Future<String> downloadAndCacheFile(String resourceId, String url);
  Map<String, dynamic>? getCachedFileInfo(String resourceId);
}

class ResourceLocalDataSourceImpl implements ResourceLocalDataSource {
  final Box<String> cacheBox;

  ResourceLocalDataSourceImpl({required this.cacheBox});

  static const String _homeFeedKey = 'home_feed';
  static String _categoryKey(String categoryId) => 'category_$categoryId';
  static String _searchKey(String query) => 'search_${query.toLowerCase().trim()}';
  static String _resourceKey(String resourceId) => 'resource_$resourceId';
  static String _articleContentKey(String resourceId) => 'article_content_$resourceId';
  static String _fileInfoKey(String resourceId) => 'file_path_$resourceId';

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

  @override
  Future<void> cacheArticleContent(String resourceId, String markdown) async {
    await cacheBox.put(_articleContentKey(resourceId), markdown);
  }

  @override
  String? getCachedArticleContent(String resourceId) =>
      cacheBox.get(_articleContentKey(resourceId));

  @override
  Future<String> downloadAndCacheFile(String resourceId, String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/resource_$resourceId${_extensionFromUrl(url)}');

    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);

    await cacheBox.put(
      _fileInfoKey(resourceId),
      jsonEncode({
        'path': file.path,
        'sizeBytes': response.bodyBytes.length,
        'downloadedAt': DateTime.now().toIso8601String(),
      }),
    );

    return file.path;
  }

  @override
  Map<String, dynamic>? getCachedFileInfo(String resourceId) {
    final raw = cacheBox.get(_fileInfoKey(resourceId));
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  String _extensionFromUrl(String url) {
    final match = RegExp(r'\.\w+$').firstMatch(Uri.parse(url).path);
    return match?.group(0) ?? '.bin';
  }

  List<ResourceModel> _decodeList(String? raw) {
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((json) => ResourceModel.fromCachedJson(json as Map<String, dynamic>))
        .toList();
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resource_model.dart';
import '../models/category_model.dart';

abstract class ResourceRemoteDataSource {
  Future<List<ResourceModel>> getTrendingBooks({int limit = 10});
  Future<List<Map<String, dynamic>>> getContinueReading();
  Future<List<CategoryModel>> getCategories();
  Future<List<ResourceModel>> getResourcesByCategory(String categoryId);
  Future<List<ResourceModel>> searchResources(String query);
  Future<List<ResourceModel>> searchExternalAndSave(String query);
  Future<List<ResourceModel>> getBookmarkedResources();
  Future<void> addBookmark(String resourceId);
  Future<void> removeBookmark(String resourceId);
  Future<bool> isBookmarked(String resourceId);
  Future<List<ResourceModel>> getNewReleases({String? type, int limit = 10});
  Future<CategoryModel?> getMostPopulatedCategory();
  Future<List<ResourceModel>> getResourcesInCategory(String categoryId, {int limit = 10});
  Future<ResourceModel?> getResourceById(String resourceId);
  Future<List<ResourceModel>> getRelatedResources(String resourceId, String? categoryId);
  Future<void> markDownloaded(String resourceId);
  Future<bool> isDownloaded(String resourceId);
}

const String _resourceSelect = '*, categories(name)';

class ResourceRemoteDataSourceImpl implements ResourceRemoteDataSource {
  final SupabaseClient supabaseClient;

  ResourceRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ResourceModel>> getTrendingBooks({int limit = 10}) async {
    final response = await supabaseClient
        .from('resources')
        .select(_resourceSelect)
        .eq('type', 'book')
        .order('created_at', ascending: false)
        .limit(limit);

    return _mapList(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getContinueReading() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('reading_progress')
        .select('progress_percent, resources($_resourceSelect)')
        .eq('user_id', userId)
        .gt('progress_percent', 0)
        .lt('progress_percent', 100)
        .order('updated_at', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await supabaseClient.from('categories').select().order('name');
    return (response as List)
        .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ResourceModel>> getResourcesByCategory(String categoryId) async {
    final response = await supabaseClient
        .from('resources')
        .select(_resourceSelect)
        .eq('category_id', categoryId)
        .order('created_at', ascending: false);

    return _mapList(response);
  }

  @override
  Future<List<ResourceModel>> searchResources(String query) async {
    final response = await supabaseClient
        .from('resources')
        .select(_resourceSelect)
        .textSearch('title', query)
        .limit(50);

    return _mapList(response);
  }

  @override
  Future<List<ResourceModel>> searchExternalAndSave(String query) async {
    final response = await supabaseClient.functions.invoke(
      'search-resource',
      body: {'query': query},
    );

    if (response.status != 200) {
      throw Exception('External search failed: ${response.status}');
    }

    final data = response.data as Map<String, dynamic>;
    final resources = data['resources'] as List? ?? [];

    return resources
        .map((json) => ResourceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ResourceModel>> getBookmarkedResources() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('bookmarks')
        .select('resources($_resourceSelect)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => ResourceModel.fromJson(row['resources'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addBookmark(String resourceId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw const AuthException('Must be signed in to bookmark.');

    await supabaseClient.from('bookmarks').insert({
      'user_id': userId,
      'resource_id': resourceId,
    });
  }

  @override
  Future<void> removeBookmark(String resourceId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    await supabaseClient
        .from('bookmarks')
        .delete()
        .eq('user_id', userId)
        .eq('resource_id', resourceId);
  }

  @override
  Future<bool> isBookmarked(String resourceId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await supabaseClient
        .from('bookmarks')
        .select('id')
        .eq('user_id', userId)
        .eq('resource_id', resourceId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<List<ResourceModel>> getNewReleases({String? type, int limit = 10}) async {
    var query = supabaseClient.from('resources').select(_resourceSelect);

    if (type != null) {
      query = query.eq('type', type);
    }

    final response = await query.order('created_at', ascending: false).limit(limit);
    return _mapList(response);
  }

  @override
  Future<CategoryModel?> getMostPopulatedCategory() async {
    // No direct "group by count" via the query builder without an RPC;
    // this pulls category_id counts via a raw count-per-category approach.
    final categories = await getCategories();
    if (categories.isEmpty) return null;

    CategoryModel? best;
    int bestCount = 0;

    for (final category in categories) {
      final countResponse = await supabaseClient
          .from('resources')
          .select('id')
          .eq('category_id', category.id)
          .count(CountOption.exact);

      if (countResponse.count > bestCount) {
        bestCount = countResponse.count;
        best = category;
      }
    }

    return best;
  }

  @override
  Future<List<ResourceModel>> getResourcesInCategory(String categoryId, {int limit = 10}) async {
    final response = await supabaseClient
        .from('resources')
        .select(_resourceSelect)
        .eq('category_id', categoryId)
        .order('created_at', ascending: false)
        .limit(limit);

    return _mapList(response);
  }

  @override
  Future<ResourceModel?> getResourceById(String resourceId) async {
    final response = await supabaseClient
        .from('resources')
        .select(_resourceSelect)
        .eq('id', resourceId)
        .maybeSingle();

    if (response == null) return null;
    return ResourceModel.fromJson(response);
  }

  @override
  Future<List<ResourceModel>> getRelatedResources(String resourceId, String? categoryId) async {
    if (categoryId == null) return [];

    final response = await supabaseClient
        .from('resources')
        .select(_resourceSelect)
        .eq('category_id', categoryId)
        .neq('id', resourceId)
        .limit(6);

    return _mapList(response);
  }

  @override
  Future<void> markDownloaded(String resourceId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) throw const AuthException('Must be signed in to download.');

    await supabaseClient.from('downloads').upsert({
      'user_id': userId,
      'resource_id': resourceId,
      'file_path': 'metadata_only', // see note below
    }, onConflict: 'user_id,resource_id');
  }

  @override
  Future<bool> isDownloaded(String resourceId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await supabaseClient
        .from('downloads')
        .select('id')
        .eq('user_id', userId)
        .eq('resource_id', resourceId)
        .maybeSingle();

    return response != null;
  }

  List<ResourceModel> _mapList(dynamic response) {
    return (response as List)
        .map((json) => ResourceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/resource_model.dart';
import '../models/category_model.dart';

abstract class ResourceRemoteDataSource {
  Future<List<ResourceModel>> getHomeFeed();
  Future<List<CategoryModel>> getCategories();
  Future<List<ResourceModel>> getResourcesByCategory(String categoryId);
  Future<List<ResourceModel>> searchResources(String query);
  Future<List<ResourceModel>> getBookmarkedResources();
  Future<void> addBookmark(String resourceId);
  Future<void> removeBookmark(String resourceId);
  Future<bool> isBookmarked(String resourceId);
  Future<List<ResourceModel>> getTrendingBooks({int limit = 10});
Future<List<Map<String, dynamic>>> getContinueReading();
}

class ResourceRemoteDataSourceImpl implements ResourceRemoteDataSource {
  final SupabaseClient supabaseClient;

  ResourceRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ResourceModel>> getHomeFeed() async {
    final response = await supabaseClient
        .from('resources')
        .select()
        .order('created_at', ascending: false)
        .limit(30);

    return (response as List)
        .map((json) => ResourceModel.fromJson(json as Map<String, dynamic>))
        .toList();
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
        .select()
        .eq('category_id', categoryId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ResourceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ResourceModel>> searchResources(String query) async {
    final response = await supabaseClient
        .from('resources')
        .select()
        .textSearch('title', query)
        .limit(50);

    return (response as List)
        .map((json) => ResourceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ResourceModel>> getBookmarkedResources() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('bookmarks')
        .select('resources(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => ResourceModel.fromJson(row['resources'] as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addBookmark(String resourceId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Must be signed in to bookmark.');
    }

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
Future<List<ResourceModel>> getTrendingBooks({int limit = 10}) async {
  final response = await supabaseClient
      .from('resources')
      .select()
      .eq('type', 'book')
      .order('created_at', ascending: false)
      .limit(limit);

  return (response as List)
      .map((json) => ResourceModel.fromJson(json as Map<String, dynamic>))
      .toList();
}

@override
Future<List<Map<String, dynamic>>> getContinueReading() async {
  final userId = supabaseClient.auth.currentUser?.id;
  if (userId == null) return [];

  final response = await supabaseClient
      .from('reading_progress')
      .select('progress_percent, resources(*)')
      .eq('user_id', userId)
      .gt('progress_percent', 0)
      .lt('progress_percent', 100)
      .order('updated_at', ascending: false)
      .limit(10);

  return List<Map<String, dynamic>>.from(response as List);
}
}
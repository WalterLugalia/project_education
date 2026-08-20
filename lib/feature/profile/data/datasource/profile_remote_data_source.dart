import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_education/feature/resources/data/models/resource_model.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel?> getProfile();
  Future<void> updateProfile({String? fullName, String? username, String? bio, String? website, String? location});
  Future<String> uploadAvatar(String filePath);
  Future<bool> isUsernameAvailable(String username);
  Future<int> getResourcesEngagedCount();
  Future<double> getReadingHours();
  Future<int> getBookmarksCount();
  Future<int> getReadThisMonthPercentDelta();
  Future<int> getReadingStreakDays();
  Future<List<Map<String, dynamic>>> getCategoryBreakdownRaw();
  Future<List<ResourceModel>> getMostVisited();
  Future<void> logResourceView(String resourceId);
  Future<void> logReadingSession(String resourceId, int seconds);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;
  ProfileRemoteDataSourceImpl({required this.supabaseClient});

  String? get _userId => supabaseClient.auth.currentUser?.id;

  @override
  Future<ProfileModel?> getProfile() async {
    final userId = _userId;
    if (userId == null) return null;

    var response = await supabaseClient.from('profiles').select().eq('user_id', userId).maybeSingle();

    // Guest's first visit to Profile — create the row lazily so edits have
    // somewhere to write to.
    if (response == null) {
      await supabaseClient.from('profiles').insert({'user_id': userId});
      response = await supabaseClient.from('profiles').select().eq('user_id', userId).single();
    }

    return ProfileModel.fromJson(response);
  }

  @override
  Future<void> updateProfile({String? fullName, String? username, String? bio, String? website, String? location}) async {
    final userId = _userId;
    if (userId == null) throw const AuthException('Must be signed in.');

    final updates = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
    if (fullName != null) updates['full_name'] = fullName;
    if (username != null) updates['username'] = username;
    if (bio != null) updates['bio'] = bio;
    if (website != null) updates['website'] = website;
    if (location != null) updates['location'] = location;

    await supabaseClient.from('profiles').update(updates).eq('user_id', userId);
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    final userId = _userId;
    if (userId == null) throw const AuthException('Must be signed in.');

    final file = File(filePath);
    final ext = filePath.split('.').last;
    final storagePath = '$userId/avatar.$ext';

    await supabaseClient.storage.from('avatars').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = supabaseClient.storage.from('avatars').getPublicUrl(storagePath);
    await supabaseClient.from('profiles').update({'avatar_url': url}).eq('user_id', userId);
    return url;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final userId = _userId;
    final response = await supabaseClient
        .from('profiles')
        .select('user_id')
        .eq('username', username)
        .maybeSingle();

    if (response == null) return true;
    return response['user_id'] == userId; // your own current username counts as available
  }

  @override
  Future<int> getResourcesEngagedCount() async {
    final userId = _userId;
    if (userId == null) return 0;
    final response = await supabaseClient
        .from('resource_views')
        .select('resource_id')
        .eq('user_id', userId);
    final ids = (response as List).map((r) => r['resource_id']).toSet();
    return ids.length;
  }

  @override
  Future<double> getReadingHours() async {
    final userId = _userId;
    if (userId == null) return 0;
    final response = await supabaseClient
        .from('reading_sessions')
        .select('seconds_read')
        .eq('user_id', userId);
    final totalSeconds = (response as List).fold<int>(0, (sum, r) => sum + (r['seconds_read'] as int));
    return totalSeconds / 3600;
  }

  @override
  Future<int> getBookmarksCount() async {
    final userId = _userId;
    if (userId == null) return 0;
    final response = await supabaseClient
        .from('bookmarks')
        .select('id')
        .eq('user_id', userId)
        .count(CountOption.exact);
    return response.count;
  }

  @override
  Future<int> getReadThisMonthPercentDelta() async {
    final userId = _userId;
    if (userId == null) return 0;

    final now = DateTime.now();
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

    final thisMonth = await supabaseClient
        .from('resource_views')
        .select('id')
        .eq('user_id', userId)
        .gte('viewed_at', startOfThisMonth.toIso8601String())
        .count(CountOption.exact);

    final lastMonth = await supabaseClient
        .from('resource_views')
        .select('id')
        .eq('user_id', userId)
        .gte('viewed_at', startOfLastMonth.toIso8601String())
        .lt('viewed_at', startOfThisMonth.toIso8601String())
        .count(CountOption.exact);

    if (lastMonth.count == 0) return thisMonth.count > 0 ? 100 : 0;
    return (((thisMonth.count - lastMonth.count) / lastMonth.count) * 100).round();
  }

  @override
  Future<int> getReadingStreakDays() async {
    final userId = _userId;
    if (userId == null) return 0;

    final response = await supabaseClient
        .from('reading_sessions')
        .select('created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final days = (response as List)
        .map((r) => DateTime.parse(r['created_at'] as String))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (days.isEmpty) return 0;

    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    for (final day in days) {
      if (day == cursor || day == cursor.subtract(const Duration(days: 1))) {
        streak++;
        cursor = day;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoryBreakdownRaw() async {
    final userId = _userId;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('resource_views')
        .select('resources(categories(name))')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<List<ResourceModel>> getMostVisited() async {
    final userId = _userId;
    if (userId == null) return [];

    final response = await supabaseClient
        .from('resource_views')
        .select('resource_id, resources(*, categories(name))')
        .eq('user_id', userId);

    final counts = <String, int>{};
    final resourceById = <String, Map<String, dynamic>>{};

    for (final row in response as List) {
      final id = row['resource_id'] as String;
      counts[id] = (counts[id] ?? 0) + 1;
      resourceById[id] = row['resources'] as Map<String, dynamic>;
    }

    final sortedIds = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    return sortedIds.take(5).map((id) => ResourceModel.fromJson(resourceById[id]!)).toList();
  }

  @override
  Future<void> logResourceView(String resourceId) async {
    final userId = _userId;
    if (userId == null) return;
    await supabaseClient.from('resource_views').insert({'user_id': userId, 'resource_id': resourceId});
  }

  @override
  Future<void> logReadingSession(String resourceId, int seconds) async {
    final userId = _userId;
    if (userId == null || seconds <= 0) return;
    await supabaseClient.from('reading_sessions').insert({
      'user_id': userId,
      'resource_id': resourceId,
      'seconds_read': seconds,
    });
  }
}
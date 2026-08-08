import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sync_config.dart';

const List<String> tagsToSync = [
  'programming',
  'ai',
  'cybersecurity',
  'career',
  'design',
  'javascript',
];

const int articlesPerTag = 20;

Future<void> main() async {
  print('Fetching categories from Supabase...');
  final categoryMap = await _fetchCategoryMap();

  for (final tag in tagsToSync) {
    print('Syncing tag: $tag');
    final articles = await _fetchDevToArticles(tag);

    if (articles.isEmpty) {
      print('  No articles found for "$tag", skipping.');
      continue;
    }

    final categoryId = categoryMap[_tagToCategorySlug(tag)];
    final rows = articles.map((a) => _articleToResourceRow(a, categoryId)).toList();

    await _upsertResources(rows);
    print('  Synced ${rows.length} articles.');
  }

  print('Done.');
}

Future<Map<String, String>> _fetchCategoryMap() async {
  final response = await http.get(
    Uri.parse('$supabaseUrl/rest/v1/categories?select=id,slug'),
    headers: _supabaseHeaders(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch categories: ${response.body}');
  }

  final List data = jsonDecode(response.body);
  return {for (final row in data) row['slug'] as String: row['id'] as String};
}

Future<List<Map<String, dynamic>>> _fetchDevToArticles(String tag) async {
  final response = await http.get(
    Uri.parse(
      'https://dev.to/api/articles?tag=$tag&per_page=$articlesPerTag&top=30',
    ),
  );

  if (response.statusCode != 200) {
    print('  Dev.to request failed for "$tag": ${response.statusCode}');
    return [];
  }

  return List<Map<String, dynamic>>.from(jsonDecode(response.body));
}

Map<String, dynamic> _articleToResourceRow(Map<String, dynamic> article, String? categoryId) {
  final readingTime = article['reading_time_minutes'];

  return {
    'source': 'dev_to',
    'external_id': article['id'].toString(),
    'type': 'article',
    'title': article['title'] ?? 'Untitled',
    'author': article['user']?['name'],
    'description': article['description'],
    'category_id': categoryId,
    'cover_image_url': article['cover_image'] ?? article['social_image'],
    'resource_url': article['url'],
    'reading_time_minutes': readingTime,
  };
}

String _tagToCategorySlug(String tag) {
  const overrides = {
    'ai': 'artificial-intelligence',
    'javascript': 'programming',
    'career': 'business',
  };
  return overrides[tag] ?? tag;
}

Future<void> _upsertResources(List<Map<String, dynamic>> rows) async {
  final response = await http.post(
    Uri.parse('$supabaseUrl/rest/v1/resources?on_conflict=source,external_id'),
    headers: {
      ..._supabaseHeaders(),
      'Content-Type': 'application/json',
      'Prefer': 'resolution=merge-duplicates',
    },
    body: jsonEncode(rows),
  );

  if (response.statusCode >= 300) {
    throw Exception('Upsert failed: ${response.statusCode} ${response.body}');
  }
}

Map<String, String> _supabaseHeaders() => {
      'apikey': supabaseServiceRoleKey,
      'Authorization': 'Bearer $supabaseServiceRoleKey',
    };
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sync_config.dart';

const List<String> subjectsToSync = [
  'programming',
  'artificial_intelligence',
  'business',
  'mathematics',
  'design',
  'science',
];

const int limitPerSubject = 15;

Future<void> main() async {
  print('Fetching categories from Supabase...');
  final categoryMap = await _fetchCategoryMap();

  for (final subject in subjectsToSync) {
    print('Syncing subject: $subject');
    final books = await _fetchOpenLibrarySubject(subject);

    if (books.isEmpty) {
      print('  No books found for "$subject", skipping.');
      continue;
    }

    final categoryId = categoryMap[_subjectToCategorySlug(subject)];
    final rows = books.map((book) => _bookToResourceRow(book, categoryId)).toList();

    await _upsertResources(rows);
    print('  Synced ${rows.length} books.');
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

Future<List<Map<String, dynamic>>> _fetchOpenLibrarySubject(String subject) async {
  final response = await http.get(
    Uri.parse('https://openlibrary.org/subjects/$subject.json?limit=$limitPerSubject'),
  );

  if (response.statusCode != 200) {
    print('  Open Library request failed for "$subject": ${response.statusCode}');
    return [];
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return List<Map<String, dynamic>>.from(data['works'] ?? []);
}

Map<String, dynamic> _bookToResourceRow(Map<String, dynamic> book, String? categoryId) {
  final key = book['key'] as String;
  final coverId = book['cover_id'];
  final authors = book['authors'] as List?;

  return {
    'source': 'open_library',
    'external_id': key,
    'type': 'book',
    'title': book['title'] ?? 'Untitled',
    'author': (authors != null && authors.isNotEmpty) ? authors[0]['name'] : null,
    'category_id': categoryId,
    'cover_image_url':
        coverId != null ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg' : null,
    'resource_url': 'https://openlibrary.org$key',
  };
}

String _subjectToCategorySlug(String subject) {
  const overrides = {
    'artificial_intelligence': 'artificial-intelligence',
  };
  return overrides[subject] ?? subject;
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
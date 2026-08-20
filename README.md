# LearnShelf

LearnShelf is a learning discovery application that helps users discover free books, articles, websites, documentation, and other educational resources from across the internet.

The application is designed to make learning accessible even when the user is offline. Resources can be discovered, bookmarked, downloaded, and read later, while reading progress and user data can be synchronized through Supabase.

## Features

- Discover free learning resources
- Search for books and educational content
- Browse dynamically generated resource categories
- View new releases and trending resources
- View resource details
- Bookmark resources
- Download resources for offline access
- Continue reading from where you stopped
- Offline-first experience using Hive
- Cloud synchronization using Supabase
- User authentication
- Personalized home screen
- Reading progress tracking

## Main Navigation

LearnShelf uses five main sections:

- **Home** — Personalized learning dashboard and recommended resources
- **Discover** — Explore books, articles, websites, documentation, and tutorials
- **Bookmarks** — Access saved resources
- **Downloads** — Access downloaded resources offline
- **Profile** — Manage account and application settings

## Resource Discovery

When a user searches for a resource, LearnShelf first checks whether the resource already exists in the Supabase database.

If the resource exists, it is returned directly to the user.

If it does not exist, LearnShelf requests the resource from an external API such as Open Library. The discovered resource is then synchronized into Supabase and returned to the user.

This allows the resource catalog to grow dynamically without requiring every resource to be manually added beforehand.

## Offline Support

LearnShelf is designed with offline usage in mind.

Previously accessed and downloaded resources can remain available when there is no internet connection. Hive is used for local caching and offline data access, while Supabase is used to synchronize cloud data when connectivity is restored.

## Technology Stack

- Flutter
- Dart
- Supabase
- Hive
- Riverpod / BLoC
- Clean Architecture
- Open Library API
- GoRouter

## Architecture

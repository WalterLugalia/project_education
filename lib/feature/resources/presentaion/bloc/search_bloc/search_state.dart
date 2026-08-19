import 'package:equatable/equatable.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';


abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchIdle extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final String query;
  final String selectedType;
  final List<ResourceEntity> allResults;

  const SearchLoaded({
    required this.query,
    required this.selectedType,
    required this.allResults,
  });

  List<ResourceEntity> get filteredResults =>
      allResults.where((r) => _typeKey(r.type) == selectedType).toList();

  static String _typeKey(ResourceType type) {
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

  @override
  List<Object?> get props => [query, selectedType, allResults];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}
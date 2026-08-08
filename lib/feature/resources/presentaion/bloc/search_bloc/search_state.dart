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
  final List<ResourceEntity> results;
  final String query;
  const SearchLoaded({required this.results, required this.query});
  @override
  List<Object?> get props => [results, query];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}
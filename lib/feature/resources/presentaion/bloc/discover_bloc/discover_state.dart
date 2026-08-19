import 'package:equatable/equatable.dart';
import 'package:project_education/feature/resources/domain/entities/category_entity.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';


abstract class DiscoverState extends Equatable {
  const DiscoverState();
  @override
  List<Object?> get props => [];
}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final String? selectedType;
  final List<ResourceEntity> newReleases;
  final CategoryEntity? featuredCategory;
  final List<ResourceEntity> featuredCategoryResources;

  const DiscoverLoaded({
    required this.selectedType,
    required this.newReleases,
    required this.featuredCategory,
    required this.featuredCategoryResources,
  });

  @override
  List<Object?> get props => [selectedType, newReleases, featuredCategory, featuredCategoryResources];
}

class DiscoverError extends DiscoverState {
  final String message;
  const DiscoverError(this.message);
  @override
  List<Object?> get props => [message];
}
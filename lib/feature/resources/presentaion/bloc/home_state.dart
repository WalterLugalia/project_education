import 'package:equatable/equatable.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/entities/category_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ResourceEntity> continueReading;
  final List<ResourceEntity> trending;
  final List<ResourceEntity> recommended;
  final List<CategoryEntity> categories;
  final bool isOffline;

  const HomeLoaded({
    required this.continueReading,
    required this.trending,
    required this.recommended,
    required this.categories,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [continueReading, trending, recommended, categories, isOffline];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
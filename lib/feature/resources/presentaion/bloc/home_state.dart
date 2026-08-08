import 'package:equatable/equatable.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/entities/continue_reading_item.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ContinueReadingItem> continueReading;
  final List<ResourceEntity> trending;
  final bool isOffline;

  const HomeLoaded({
    required this.continueReading,
    required this.trending,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [continueReading, trending, isOffline];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
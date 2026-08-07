import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

class HomeBookmarkToggled extends HomeEvent {
  final String resourceId;

  const HomeBookmarkToggled({required this.resourceId});

  @override
  List<Object?> get props => [resourceId];
}
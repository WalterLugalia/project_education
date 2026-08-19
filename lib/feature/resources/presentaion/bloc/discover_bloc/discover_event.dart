import 'package:equatable/equatable.dart';

abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  @override
  List<Object?> get props => [];
}

class DiscoverStarted extends DiscoverEvent {
  const DiscoverStarted();
}

class DiscoverTypeFilterChanged extends DiscoverEvent {
  final String? type; // null = "All"
  const DiscoverTypeFilterChanged(this.type);
  @override
  List<Object?> get props => [type];
}

class DiscoverBookmarkToggled extends DiscoverEvent {
  final String resourceId;
  const DiscoverBookmarkToggled(this.resourceId);
  @override
  List<Object?> get props => [resourceId];
}
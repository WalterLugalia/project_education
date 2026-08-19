import 'package:equatable/equatable.dart';

abstract class ResourceDetailsEvent extends Equatable {
  const ResourceDetailsEvent();
  @override
  List<Object?> get props => [];
}

class ResourceDetailsStarted extends ResourceDetailsEvent {
  final String resourceId;
  const ResourceDetailsStarted(this.resourceId);
  @override
  List<Object?> get props => [resourceId];
}

class ResourceDetailsBookmarkToggled extends ResourceDetailsEvent {
  const ResourceDetailsBookmarkToggled();
}

class ResourceDetailsDownloadRequested extends ResourceDetailsEvent {
  const ResourceDetailsDownloadRequested();
}
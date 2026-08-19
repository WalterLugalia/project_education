import 'package:equatable/equatable.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';


abstract class ResourceDetailsState extends Equatable {
  const ResourceDetailsState();
  @override
  List<Object?> get props => [];
}

class ResourceDetailsLoading extends ResourceDetailsState {}

class ResourceDetailsLoaded extends ResourceDetailsState {
  final ResourceEntity resource;
  final List<ResourceEntity> related;
  final bool isBookmarked;
  final bool isDownloaded;

  const ResourceDetailsLoaded({
    required this.resource,
    required this.related,
    required this.isBookmarked,
    required this.isDownloaded,
  });

  ResourceDetailsLoaded copyWith({bool? isBookmarked, bool? isDownloaded}) {
    return ResourceDetailsLoaded(
      resource: resource,
      related: related,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  @override
  List<Object?> get props => [resource, related, isBookmarked, isDownloaded];
}

class ResourceDetailsError extends ResourceDetailsState {
  final String message;
  const ResourceDetailsError(this.message);
  @override
  List<Object?> get props => [message];
}
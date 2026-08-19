import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/resources/domain/repositories/resource_repository.dart';
import 'package:project_education/feature/resources/domain/usecase/download_resource_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_related_resources_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_resource_details_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/is_resource_downloaded_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/toggle_bookmark_usecase.dart';

import 'resource_details_event.dart';
import 'resource_details_state.dart';

class ResourceDetailsBloc extends Bloc<ResourceDetailsEvent, ResourceDetailsState> {
  final GetResourceDetailsUseCase getResourceDetailsUseCase;
  final GetRelatedResourcesUseCase getRelatedResourcesUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;
  final DownloadResourceUseCase downloadResourceUseCase;
  final IsResourceDownloadedUseCase isResourceDownloadedUseCase;
  final ResourceRepository repository;

  ResourceDetailsBloc({
    required this.getResourceDetailsUseCase,
    required this.getRelatedResourcesUseCase,
    required this.toggleBookmarkUseCase,
    required this.downloadResourceUseCase,
    required this.isResourceDownloadedUseCase,
    required this.repository,
  }) : super(ResourceDetailsLoading()) {
    on<ResourceDetailsStarted>(_onStarted);
    on<ResourceDetailsBookmarkToggled>(_onBookmarkToggled);
    on<ResourceDetailsDownloadRequested>(_onDownloadRequested);
  }

  Future<void> _onStarted(
    ResourceDetailsStarted event,
    Emitter<ResourceDetailsState> emit,
  ) async {
    emit(ResourceDetailsLoading());
    try {
      final resource = await getResourceDetailsUseCase(event.resourceId);
      if (resource == null) {
        emit(const ResourceDetailsError('Resource not found.'));
        return;
      }

      final related = await getRelatedResourcesUseCase(resource.id, resource.categoryId);
      final isBookmarked = await repository.isBookmarked(resource.id);
      final isDownloaded = await isResourceDownloadedUseCase(resource.id);

      emit(ResourceDetailsLoaded(
        resource: resource,
        related: related,
        isBookmarked: isBookmarked,
        isDownloaded: isDownloaded,
      ));
    } catch (e) {
      emit(ResourceDetailsError(e.toString()));
    }
  }

  Future<void> _onBookmarkToggled(
    ResourceDetailsBookmarkToggled event,
    Emitter<ResourceDetailsState> emit,
  ) async {
    final current = state;
    if (current is! ResourceDetailsLoaded) return;

    try {
      await toggleBookmarkUseCase(current.resource.id);
      emit(current.copyWith(isBookmarked: !current.isBookmarked));
    } catch (_) {}
  }

  Future<void> _onDownloadRequested(
    ResourceDetailsDownloadRequested event,
    Emitter<ResourceDetailsState> emit,
  ) async {
    final current = state;
    if (current is! ResourceDetailsLoaded) return;

    try {
      await downloadResourceUseCase(current.resource.id);
      emit(current.copyWith(isDownloaded: true));
    } catch (_) {}
  }
}
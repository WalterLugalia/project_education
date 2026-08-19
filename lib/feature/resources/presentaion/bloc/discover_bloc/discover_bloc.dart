import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/resources/domain/usecase/get_featured_category_trending_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/get_new_releases_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/toggle_bookmark_usecase.dart';

import 'discover_event.dart';
import 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final GetNewReleasesUseCase getNewReleasesUseCase;
  final GetFeaturedCategoryTrendingUseCase getFeaturedCategoryTrendingUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;

  String? _currentType;

  DiscoverBloc({
    required this.getNewReleasesUseCase,
    required this.getFeaturedCategoryTrendingUseCase,
    required this.toggleBookmarkUseCase,
  }) : super(DiscoverInitial()) {
    on<DiscoverStarted>(_onStarted);
    on<DiscoverTypeFilterChanged>(_onTypeFilterChanged);
    on<DiscoverBookmarkToggled>(_onBookmarkToggled);
  }

  Future<void> _onStarted(DiscoverStarted event, Emitter<DiscoverState> emit) async {
    emit(DiscoverLoading());
    await _load(emit);
  }

  Future<void> _onTypeFilterChanged(
    DiscoverTypeFilterChanged event,
    Emitter<DiscoverState> emit,
  ) async {
    _currentType = event.type;
    emit(DiscoverLoading());
    await _load(emit);
  }

  Future<void> _load(Emitter<DiscoverState> emit) async {
    try {
      final newReleases = await getNewReleasesUseCase(type: _currentType);
      final featured = await getFeaturedCategoryTrendingUseCase();

      emit(DiscoverLoaded(
        selectedType: _currentType,
        newReleases: newReleases,
        featuredCategory: featured?.$1,
        featuredCategoryResources: featured?.$2 ?? [],
      ));
    } catch (e) {
      emit(DiscoverError(e.toString()));
    }
  }

  Future<void> _onBookmarkToggled(
    DiscoverBookmarkToggled event,
    Emitter<DiscoverState> emit,
  ) async {
    try {
      await toggleBookmarkUseCase(event.resourceId);
      add(DiscoverTypeFilterChanged(_currentType));
    } catch (_) {}
  }
}
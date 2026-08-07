import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/get_home_feed_usecase.dart';
import '../../domain/usecase/get_categories_usecase.dart';
import '../../domain/usecase/toggle_bookmark_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeFeedUseCase getHomeFeedUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;

  HomeBloc({
    required this.getHomeFeedUseCase,
    required this.getCategoriesUseCase,
    required this.toggleBookmarkUseCase,
  }) : super(HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshRequested>(_onHomeStarted);
    on<HomeBookmarkToggled>(_onHomeBookmarkToggled);
  }

  Future<void> _onHomeStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final resources = await getHomeFeedUseCase();
      final categories = await getCategoriesUseCase();

      emit(HomeLoaded(
        continueReading: const [],
        trending: resources,
        recommended: const [],
        categories: categories,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onHomeBookmarkToggled(
    HomeBookmarkToggled event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await toggleBookmarkUseCase(event.resourceId);
      // Re-fetch to reflect the change; simple and correct for now —
      // an optimistic update can replace this later if it feels laggy.
      add(const HomeRefreshRequested());
    } catch (_) {
      // Bookmark toggle failing silently is acceptable here; the button
      // just won't visually change. Revisit if this needs a snackbar.
    }
  }
}
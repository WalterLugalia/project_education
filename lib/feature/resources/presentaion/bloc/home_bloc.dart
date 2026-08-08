import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/entities/continue_reading_item.dart';
import '../../domain/usecase/get_trending_books_usecase.dart';
import '../../domain/usecase/get_continue_reading_usecase.dart';
import '../../domain/usecase/toggle_bookmark_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTrendingBooksUseCase getTrendingBooksUseCase;
  final GetContinueReadingUseCase getContinueReadingUseCase;
  final ToggleBookmarkUseCase toggleBookmarkUseCase;

  HomeBloc({
    required this.getTrendingBooksUseCase,
    required this.getContinueReadingUseCase,
    required this.toggleBookmarkUseCase,
  }) : super(HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshRequested>(_onHomeStarted);
    on<HomeBookmarkToggled>(_onHomeBookmarkToggled);
  }

  Future<void> _onHomeStarted(HomeEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);

      final results = await Future.wait([
        getTrendingBooksUseCase(),
        getContinueReadingUseCase(),
      ]);

      emit(HomeLoaded(
        trending: results[0] as List<ResourceEntity>,
        continueReading: results[1] as List<ContinueReadingItem>,
        isOffline: isOffline,
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
      add(const HomeRefreshRequested());
    } catch (_) {}
  }
}
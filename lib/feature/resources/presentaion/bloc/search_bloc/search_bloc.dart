import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/resources/domain/usecase/search_resources_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchResourcesUseCase searchResourcesUseCase;

  String _currentType = 'book';

  SearchBloc({required this.searchResourcesUseCase}) : super(SearchIdle()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchTypeTabChanged>(_onTypeTabChanged);
  }

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(SearchIdle());
      return;
    }

    emit(SearchLoading());
    try {
      final results = await searchResourcesUseCase(query);
      emit(SearchLoaded(query: query, selectedType: _currentType, allResults: results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onTypeTabChanged(SearchTypeTabChanged event, Emitter<SearchState> emit) {
    final current = state;
    if (current is! SearchLoaded || event.type == null) return;

    _currentType = event.type!;
    emit(SearchLoaded(
      query: current.query,
      selectedType: _currentType,
      allResults: current.allResults,
    ));
  }
}
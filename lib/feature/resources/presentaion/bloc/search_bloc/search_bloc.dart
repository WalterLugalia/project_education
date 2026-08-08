import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/resources/domain/usecase/search_resources_usecase.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchResourcesUseCase searchResourcesUseCase;
  Timer? _debounce;

  SearchBloc({required this.searchResourcesUseCase}) : super(SearchIdle()) {
    on<SearchQueryChanged>(_onQueryChanged);
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
      emit(SearchLoaded(results: results, query: query));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
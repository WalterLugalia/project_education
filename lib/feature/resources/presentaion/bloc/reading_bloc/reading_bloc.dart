import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';
import 'package:project_education/feature/resources/domain/usecase/get_readable_content_usecase.dart';
import 'package:project_education/feature/resources/domain/usecase/save_reading_progress_usecase.dart';
import 'package:project_education/feature/profile/domain/usecase/log_reading_session_usecase.dart';
import 'package:project_education/feature/resources/presentaion/bloc/reading_bloc/reading_event.dart';
import 'package:project_education/feature/resources/presentaion/bloc/reading_bloc/reading_state.dart';

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final GetReadableContentUseCase getReadableContentUseCase;
  final SaveReadingProgressUseCase saveReadingProgressUseCase;
  final LogReadingSessionUseCase logReadingSessionUseCase;
  final ResourceEntity resource;

  final Stopwatch _stopwatch = Stopwatch();

  ReadingBloc({
    required this.getReadableContentUseCase,
    required this.saveReadingProgressUseCase,
    required this.logReadingSessionUseCase,
    required this.resource,
  }) : super(ReadingLoading()) {
    on<ReadingStarted>(_onStarted);
    on<ReadingProgressChanged>(_onProgressChanged);
  }

  Future<void> _onStarted(ReadingStarted event, Emitter<ReadingState> emit) async {
    if (resource.contentFormat == ContentFormat.unavailable &&
        resource.type != ResourceType.article) {
      emit(const ReadingUnavailable(
        "Full text isn't available for this book yet. Try Visit to view it on Open Library.",
      ));
      return;
    }

    final content = await getReadableContentUseCase(resource);
    if (content == null) {
      emit(const ReadingUnavailable('Content unavailable — check your connection.'));
      return;
    }

    _stopwatch.start();

    final format = resource.type == ResourceType.article
        ? ContentFormat.markdown
        : resource.contentFormat;
    emit(ReadingLoaded(content, format));
  }

  Future<void> _onProgressChanged(
    ReadingProgressChanged event,
    Emitter<ReadingState> emit,
  ) async {
    await saveReadingProgressUseCase(resource.id, event.percent);
  }

  @override
  Future<void> close() {
    _stopwatch.stop();
    if (_stopwatch.elapsed.inSeconds > 0) {
      logReadingSessionUseCase(resource.id, _stopwatch.elapsed.inSeconds);
    }
    return super.close();
  }
}
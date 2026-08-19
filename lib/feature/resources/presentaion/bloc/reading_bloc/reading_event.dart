import 'package:equatable/equatable.dart';

abstract class ReadingEvent extends Equatable {
  const ReadingEvent();

  @override
  List<Object?> get props => [];
}

class ReadingStarted extends ReadingEvent {
  const ReadingStarted();
}

class ReadingProgressChanged extends ReadingEvent {
  final double percent;

  const ReadingProgressChanged(this.percent);

  @override
  List<Object?> get props => [percent];
}
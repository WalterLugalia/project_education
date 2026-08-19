import 'package:equatable/equatable.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';

abstract class ReadingState extends Equatable {
  const ReadingState();
  @override
  List<Object?> get props => [];
}
class ReadingLoading extends ReadingState {}
class ReadingLoaded extends ReadingState {
  final String content;
  final ContentFormat format;
  const ReadingLoaded(this.content, this.format);
  @override
  List<Object?> get props => [content, format];
}
class ReadingUnavailable extends ReadingState {
  final String message;
  const ReadingUnavailable(this.message);
  @override
  List<Object?> get props => [message];
}
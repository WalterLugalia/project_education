import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchTypeTabChanged extends SearchEvent {
  final String? type; // null = show all types together isn't in this UI; used per-tab
  const SearchTypeTabChanged(this.type);
  @override
  List<Object?> get props => [type];
}
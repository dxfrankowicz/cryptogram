part of 'quotes_bloc.dart';

abstract class QuotesState extends Equatable {
  const QuotesState();

  @override
  List<Object> get props => [];
}

class QuotesInitial extends QuotesState {}

class QuotesLoading extends QuotesState {}

class QuotesLoaded extends QuotesState {
  final List<Quote> quotes;
  final List<String> categories;
  final List<String> authors;

  const QuotesLoaded(this.quotes, this.categories, this.authors);

  @override
  List<Object> get props => [quotes, categories, authors];
}

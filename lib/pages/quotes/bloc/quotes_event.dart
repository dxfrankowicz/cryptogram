part of 'quotes_bloc.dart';

abstract class QuotesEvent extends Equatable {
  const QuotesEvent();

  @override
  List<Object> get props => [];
}

class GetQuotes extends QuotesEvent {
  final bool forceGetFromFirestore;

  const GetQuotes({this.forceGetFromFirestore = false});
}

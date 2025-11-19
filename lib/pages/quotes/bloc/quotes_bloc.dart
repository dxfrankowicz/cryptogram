import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cryptogram_game/data.dart';
import 'package:cryptogram_game/models/quote.dart';
import 'package:cryptogram_game/services/firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'quotes_event.dart';

part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  QuotesBloc(this._statsRepository) : super(QuotesInitial()) {
    on<GetQuotes>(_getQuotes);
  }

  /// Interacts with storage for updating game stats.
  final GameStatsRepository _statsRepository;

  Future<void> _getQuotes(GetQuotes event, Emitter<QuotesState> emit) async {
    emit(QuotesLoading());

    List<Quote> quotes = await _statsRepository.provider.getQuotesList();
    Set<String> categories = {};
    Set<String> authors = {};

    if (quotes.isNotEmpty && !event.forceGetFromFirestore) {
      log("Found saved quotes");
      for (Quote q in quotes) {
        authors.add(q.author!);
        quotes.add(q);
      }
    } else {
      log("Getting quotes from JSON");
      final List<Quote> data = await FirestoreService.getData();

      for (Quote q in data) {
        categories.addAll(q.categories ?? []);
        authors.add(q.author!);
        quotes.add(q);
      }
    }

    log("Number of quotes: ${quotes.length}");
    log("Number of categories ${categories.length}: $categories");
    log("Number of authors ${quotes.map((e) => e.author).toSet().length}");

    await Future.delayed(const Duration(seconds: 1));
    await _statsRepository.saveQuotesList(quotes);

    emit(QuotesLoaded(
        quotes, List.of(categories)..sort((a, b) => a.compareTo(b)), List.of(authors)..sort((a, b) => a.compareTo(b))));
  }
}

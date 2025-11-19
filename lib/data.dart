import 'dart:convert';
import 'dart:developer';

import 'package:cryptogram_game/pages/quotes/bloc/quotes_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/domain.dart';
import 'models/quote.dart';

/// Interacts with shared preferences to store and retrieve data
/// about statistics of the game.
class GameStatsSharedPrefProvider {
  /// Key for retrieving data that indicates the amount of games played.
  static const quotes = 'GET_QUOTES';

  /// Key for retrieving data that indicates the amount of games played.
  static const kGamesPlayed = 'GAMES_PLAYED';

  /// Key for retrieving data that indicates the longest streak of games won.
  static const kLongestStreak = 'GAMES_LONGEST_STREAK';

  /// Key for retrieving data that indicates the current streak of games won.
  static const kCurrentStreak = 'GAMES_CURRENT_STREAK';

  List<Quote> _quotesList = [];

  /// Updates the value of a given stat.
  Future<bool> updateStat(String key, int value) async {
    final _prefs = await SharedPreferences.getInstance();

    return _prefs.setInt(key, value);
  }

  Future<bool> setQuotesList(List<Quote> value) async {
    final _prefs = await SharedPreferences.getInstance();

    _quotesList = List.of(value);
    return _prefs.setStringList(
        quotes, value.map((e) => jsonEncode(e)).toList());
  }

  /// Updates the value of a given stat.
  Future<int> fetchStat(String key) async {
    final _prefs = await SharedPreferences.getInstance();

    return _prefs.getInt(key) ?? 0;
  }

  Future<List<Quote>> getQuotesList({String? author, String? category}) async {
    if (quotes.isNotEmpty) {
      log("GETTING QUOTES FROM SAVED LIST");
      if (author?.isNotEmpty ?? false) {
        return _quotesList.where((q) => q.author == author).toList();
      } else if (category?.isNotEmpty ?? false) {
        return _quotesList
            .where((q) => q.categories?.contains(category) ?? false)
            .toList();
      }
      return _quotesList;
    }
    log("GETTING QUOTES FROM SHARED PREFS");
    final _prefs = await SharedPreferences.getInstance();
    List<String> list = _prefs.getStringList(quotes) ?? [];
    final decodedList = list.map((e) => Quote.fromJson(jsonDecode(e))).toList();
    if (author?.isNotEmpty ?? false) {
      return decodedList.where((q) => q.author == author).toList();
    } else if (category?.isNotEmpty ?? false) {
      return decodedList
          .where((q) => q.categories?.contains(category) ?? false)
          .toList();
    }
    return _quotesList;
  }
}

/// Provides information about statistics of the games played.
class GameStatsRepository {
  /// Constructor
  GameStatsRepository(this.provider);

  /// Interacts with shared preferences to store and retrieve data.
  final GameStatsSharedPrefProvider provider;

  /// Fetches the game stats.
  Future<GameStats> fetchStats() async {
    return GameStats(
      gamesPlayed:
          await provider.fetchStat(GameStatsSharedPrefProvider.kGamesPlayed),
      longestStreak:
          await provider.fetchStat(GameStatsSharedPrefProvider.kLongestStreak),
      currentStreak:
          await provider.fetchStat(GameStatsSharedPrefProvider.kCurrentStreak),
    );
  }

  /// Adds a new game to the count of games played, and if won it also adds it
  /// to the games won stat. It also updates the current streak and longest
  /// streak as needed.
  Future<void> addGameFinished({
    bool hasWon = false, required int quoteId,
  }) async {
    final current = await fetchStats();

    await provider.updateStat(
      GameStatsSharedPrefProvider.kGamesPlayed,
      current.gamesPlayed + 1,
    );

    if (hasWon) {
      await provider.updateStat(
        GameStatsSharedPrefProvider.kCurrentStreak,
        current.currentStreak + 1,
      );

      if (current.currentStreak == current.longestStreak) {
        await provider.updateStat(
          GameStatsSharedPrefProvider.kLongestStreak,
          current.longestStreak + 1,
        );
      }
    } else {
      await provider.updateStat(
        GameStatsSharedPrefProvider.kCurrentStreak,
        0,
      );
    }
  }

  /// Resets the stats stored locally.
  Future<void> resetStats() async {
    await provider.updateStat(
      GameStatsSharedPrefProvider.kGamesPlayed,
      0,
    );
    await provider.updateStat(
      GameStatsSharedPrefProvider.kCurrentStreak,
      0,
    );
    await provider.updateStat(
      GameStatsSharedPrefProvider.kLongestStreak,
      0,
    );
  }

  /// Saves quotes list.
  Future<void> saveQuotesList(List<Quote> quotes) async {
    await provider.setQuotesList(quotes);
  }
}

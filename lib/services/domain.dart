import 'package:cryptogram_game/models/quote.dart';
import 'package:equatable/equatable.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

List<String> getWordListOfSentence(String s) => s.toLowerCase().split(' ');

List<String> getLetterListOfSentence(String s) => s.toLowerCase().split('');

int getLongestWordLength(Quote quote) => getWordListOfSentence(quote.text)
    .map((e) => e.length)
    .reduce((value, element) => math.max(value, element));

bool isLetterHidden(
        {required String letter, required List<String> hiddenLetters}) =>
    hiddenLetters.contains(letter);

bool isPunctuationMark(String e) =>
    e == '"' || e == ',' || e == '.' || e == '-' || e == ';' || e == ":" || e == '(' || e == ')' || e == '[' || e == ']' || e == '...' || e == ',,,';


List<String> polishAlphabet = [
  'a',
  'ą',
  'b',
  'c',
  'ć',
  'd',
  'e',
  'ę',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'ł',
  'm',
  'n',
  'ń',
  'o',
  'ó',
  'p',
  'q',
  'r',
  's',
  'ś',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  'ź',
  'ż'
];

enum Level { easy, medium, hard, expert }

extension LevelExtension on Level {
  int get difficulty {
    switch (this) {
      case Level.easy:
        return 45;
      case Level.medium:
        return 60;
      case Level.hard:
        return 75;
      case Level.expert:
        return 100;
      default:
        return 45;
    }
  }

  double get scoreMultiplier {
    switch (this) {
      case Level.easy: return 1.0;
      case Level.medium: return 1.5;
      case Level.hard: return 2.2;
      case Level.expert: return 3.3;
    }
  }

  int get defaultTimeToSolve {
    switch (this) {
      case Level.easy:
        return 90;
      case Level.medium:
        return 120;
      case Level.hard:
        return 180;
      case Level.expert:
        return 300;
      default:
        return 90;
    }
  }

  Color get color {
    switch (this) {
      case Level.easy:
        return Colors.green;
      case Level.medium:
        return Colors.orangeAccent;
      case Level.hard:
        return Colors.red;
      case Level.expert:
        return Colors.pinkAccent;
    }
  }
}

class LetterCode {
  String? letter;
  String? code;

  LetterCode({this.letter, this.code});

  @override
  String toString() {
    return '{letter: $letter, code: $code}';
  }
}

/// Defines the statistics that the game gathers for the player.
class GameStats extends Equatable {
  /// Constructor
  const GameStats({
    this.gamesPlayed = -1,
    this.longestStreak = -1,
    this.currentStreak = -1,
  });

  /// Amount of games played.
  final int gamesPlayed;

  /// Longest streak of games won.
  final int longestStreak;

  /// Current streak of games won.
  final int currentStreak;

  /// Provides empty instance of statistics.
  static const empty = GameStats();

  @override
  List<Object?> get props => [
        gamesPlayed,
        longestStreak,
        currentStreak,
      ];

  /// Provides a copied instance.
  GameStats copyWith({
    int? gamesPlayed,
    int? longestStreak,
    int? currentStreak,
  }) =>
      GameStats(
        gamesPlayed: gamesPlayed ?? this.gamesPlayed,
        longestStreak: longestStreak ?? this.longestStreak,
        currentStreak: currentStreak ?? this.currentStreak,
      );
}

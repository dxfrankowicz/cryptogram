part of 'game_bloc.dart';

enum GameStatus { initial, inProgress, success, failure }

class GameTimeCubit extends Cubit<int> {
  GameTimeCubit() : super(0);

  void increment() => emit(state + 1);

  void reset() => emit(0);
}

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object> get props => [];
}

class GameEmpty extends GameState {}

class GameInitial extends GameState {
  final Quote quote;
  final GameStatus gameStatus;
  final List<LetterCode> playerGuesses;
  final List<LetterCode> lettersCode;
  final Level level;
  final String activeLetter;
  final int activeIndex;
  final List<String> hiddenLetters;
  final List<String> hintedLetters;
  final List<String> lettersOfQuoteInOrder;
  final Duration gameDuration;
  final String chosenAuthor;
  final String chosenCategory;
  final ScoreBreakdown score;

  const GameInitial(
      {this.quote = const Quote(text: ''),
      this.level = Level.easy,
      this.lettersCode = const <LetterCode>[],
      this.gameStatus = GameStatus.initial,
      this.activeLetter = '',
      this.activeIndex = -1,
      this.chosenAuthor = '',
      this.chosenCategory = '',
      this.score = const ScoreBreakdown.empty(),
      this.hiddenLetters = const <String>[],
      this.hintedLetters = const <String>[],
      this.lettersOfQuoteInOrder = const <String>[],
      this.playerGuesses = const <LetterCode>[],
      this.gameDuration = Duration.zero})
      : super();

  @override
  List<Object> get props => [
        gameStatus,
        quote,
        playerGuesses,
        lettersCode,
        level,
        activeLetter,
        lettersOfQuoteInOrder,
        hiddenLetters,
        hintedLetters,
        activeIndex,
        gameDuration,
        chosenAuthor,
        chosenCategory,
        score
      ];

  /// Provides a copied instance.
  GameInitial copyWith(
          {GameStatus? gameStatus,
          Quote? quote,
          String? activeLetter,
          int? activeIndex,
          Level? level,
          List<String>? hiddenLetters,
          List<LetterCode>? lettersCode,
          List<String>? hintedLetters,
          List<String>? lettersOfQuoteInOrder,
          Duration? gameDuration,
          List<LetterCode>? playerGuesses,
          String? chosenAuthor,
          String? chosenCategory,
            ScoreBreakdown? score}) =>
      GameInitial(
          gameStatus: gameStatus ?? this.gameStatus,
          quote: quote ?? this.quote,
          activeIndex: activeIndex ?? this.activeIndex,
          activeLetter: activeLetter ?? this.activeLetter,
          playerGuesses: playerGuesses ?? this.playerGuesses,
          hintedLetters: hintedLetters ?? this.hintedLetters,
          hiddenLetters: hiddenLetters ?? this.hiddenLetters,
          gameDuration: gameDuration ?? this.gameDuration,
          chosenAuthor: chosenAuthor ?? this.chosenAuthor,
          chosenCategory: chosenCategory ?? this.chosenCategory,
          level: level ?? this.level,
          score: score ?? this.score,
          lettersOfQuoteInOrder: lettersOfQuoteInOrder ?? this.lettersOfQuoteInOrder,
          lettersCode: lettersCode ?? this.lettersCode);
}

class ScoreBreakdown {
  final int basePoints;
  final int basePointsMultipliedByLevel;
  final int timeBonus;
  final double flawlessMultiplier;
  final int finalScore;

  ScoreBreakdown({
    required this.basePoints,
    required this.timeBonus,
    required this.basePointsMultipliedByLevel,
    required this.flawlessMultiplier,
    required this.finalScore,
  });

  const ScoreBreakdown.empty()
      : basePoints = 0,
        timeBonus = 0,
        basePointsMultipliedByLevel = 0,
        flawlessMultiplier = 1.0,
        finalScore = 0;
}
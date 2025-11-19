import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:cryptogram_game/data.dart';
import 'package:cryptogram_game/services/domain.dart';
import 'package:cryptogram_game/models/quote.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

part 'game_state.dart';
part 'game_event.dart';

class GameBloc extends Bloc<GameEvent, GameInitial> {
  GameBloc(this._statsRepository) : super(const GameInitial(playerGuesses: <LetterCode>[])) {
    on<GameStarted>(_onGameStarted);
    on<UpdateGameTime>(_updateGameTime);
    on<LetterPressed>(_onLetterPressed);
    on<BoardLetterPressed>(_onBoardLetterPressed);
    on<GameFinished>(_onGameFinished);
    on<NextLetter>(_nextLetter);
    on<PreviousLetter>(_previousLetter);
    on<UndoLetterPressed>(_undoLetterSet);
    on<ClearLetter>(_clearLetter);
    on<ResetCurrentGame>(_resetCurrentGame);
    on<HintLetter>(_onHintLetterPressed);
  }

  /// Interacts with storage for updating game stats.
  final GameStatsRepository _statsRepository;
  late Timer timer;
  List<GameInitial> letterPressedHistory = [];

  String? getLetterByCode({required String code}) => state.lettersCode.firstWhereOrNull((x) => x.code == code)?.letter;

  String? getCodeByLetter({required String letter}) =>
      state.lettersCode.firstWhereOrNull((x) => x.letter == letter)?.code;

  String? getPlayerGuessLetterByCode({required String code}) =>
      state.playerGuesses.firstWhereOrNull((x) => x.code == code)?.letter;

  String? getPlayerGuessCodeByLetter({required String letter}) =>
      state.playerGuesses.firstWhereOrNull((x) => x.letter == letter)?.code;

  int _calculateScore({required Level level, required int seconds}){
    return level.difficulty * seconds;
  }

  List<LetterCode> get _getLettersCodeInOrder {
    final hiddenLettersInOrder =
        state.lettersCode.where((x) => state.hiddenLetters.contains(x.letter)).map((e) => e.letter!).toList();
    final list = List.generate(
        state.hiddenLetters.length,
        (i) => LetterCode(
            letter: hiddenLettersInOrder.elementAt(i),
            code: getCodeByLetter(letter: hiddenLettersInOrder.elementAt(i))));
    return list;
  }

  List<LetterCode> setLetter({required String code, required String letter, required List<LetterCode> originalList}) {
    final list = List.of(originalList);
    list[originalList.indexWhere((x) => x.code == code)] = LetterCode(letter: letter, code: code);
    return list;
  }

  Future<void> _onGameStarted(GameStarted event, Emitter<GameInitial> emit) async {
    letterPressedHistory = [];
    var quote =
        (await _statsRepository.provider.getQuotesList(author: event.chosenAuthor, category: event.chosenCategory)
              ..shuffle())
            .first;
    log("QUOTE FROM: Author: ${event.chosenAuthor} || Category: ${event.chosenCategory}");

    final playerGuesses = <LetterCode>[];
    List<LetterCode> lettersCode = [];

    final lettersInSentence = getLetterListOfSentence(quote.text).where((x) => polishAlphabet.contains(x)).toSet();
    List<String> hiddenLetters = [];
    List<String> hiddenLettersInOrder = [];

    void generateCodes(Quote quote) {
      void generateHiddenLetters() {
        int numberOfLettersToHide = (lettersInSentence.length * (event.level.difficulty / 100)).toInt();
        List<String> availableLetters = List.of(lettersInSentence);

        for (int i = 0; i < numberOfLettersToHide; i++) {
          String s = (availableLetters..shuffle()).first;
          hiddenLetters.add(s);
          playerGuesses.add(LetterCode(letter: '', code: lettersCode.firstWhere((x) => x.letter == s).code));
          availableLetters.remove(s);
        }

        hiddenLettersInOrder =
            lettersCode.where((x) => hiddenLetters.contains(x.letter)).map((e) => e.letter!).toList();

        log("PLAYER CODES: $playerGuesses");
      }

      List<String> availableLetters = List.of(polishAlphabet);
      for (String letter in lettersInSentence) {
        String s = (availableLetters.where((x) => x != letter).toList()..shuffle()).first;
        lettersCode.add(LetterCode(letter: letter, code: s));
        availableLetters.remove(s);
      }
      log("LONGEST WORD: ${getLongestWordLength(quote)}");
      log("CODES $lettersCode");

      generateHiddenLetters();
    }

    generateCodes(quote);

    log("GAME HAS STARTED: '${quote.text}'");
    emit(GameInitial(
        quote: quote,
        level: event.level,
        gameDuration: Duration.zero,
        playerGuesses: playerGuesses,
        chosenAuthor: event.chosenAuthor,
        chosenCategory: event.chosenCategory,
        lettersCode: lettersCode,
        lettersOfQuoteInOrder: quote.text.toLowerCase().split('').where((x) => x.isNotEmpty && x != ' ').toList(),
        hiddenLetters: hiddenLettersInOrder));

    log("HIDDEN LETTERS IN ORDER $_getLettersCodeInOrder");

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!super.isClosed) {
        add(UpdateGameTime(Duration(seconds: timer.tick)));
      }
    });
  }

  @override
  Future<void> close() {
    log("CLOSING");
    timer.cancel();
    return super.close();
  }

  FutureOr<void> _updateGameTime(UpdateGameTime event, Emitter<GameInitial> emit) {
    emit(state.copyWith(gameDuration: event.duration));
  }

  void _onLetterPressed(LetterPressed event, Emitter<GameInitial> emit, {String? hintLetter}) {
    log("SETTING LETTER: ${event.letter} FOR CODE: ${getCodeByLetter(letter: hintLetter ?? state.activeLetter)}");

    if(getCodeByLetter(letter: hintLetter ?? state.activeLetter) != null) {
      final playerGuesses = setLetter(
          code: getCodeByLetter(letter: hintLetter ?? state.activeLetter)!,
          letter: event.letter,
          originalList: state.playerGuesses);
      letterPressedHistory.add(state);
      emit(state.copyWith(playerGuesses: playerGuesses));

      final hasWon = playerGuesses.every((guess) => getLetterByCode(code: guess.code!) == guess.letter);
      log("CHECKING IF GAME WON: $hasWon\nPLAYER GUESSES: $playerGuesses");
      if (hasWon) {
        _onGameFinished(const GameFinished(hasWon: true), emit);
      } else if (hintLetter != null) {
        emit(state.copyWith(activeLetter: hintLetter, activeIndex: state.lettersOfQuoteInOrder.indexOf(hintLetter)));
      } else {
        _nextLetter(NextLetter(), emit, nextNotFilled: true);
      }
    }
  }

  void _onBoardLetterPressed(BoardLetterPressed event, Emitter<GameInitial> emit) {
    log("ACTIVE LETTER REAL FOR INDEX ${event.index}: ${state.lettersOfQuoteInOrder[event.index]} CODE: ${getCodeByLetter(letter: state.lettersOfQuoteInOrder[event.index])}");
    emit(state.copyWith(activeLetter: state.lettersOfQuoteInOrder[event.index], activeIndex: event.index));
  }

  void _undoLetterSet(UndoLetterPressed event, Emitter<GameInitial> emit) {
    if (letterPressedHistory.isNotEmpty) {
      emit(letterPressedHistory.removeLast());
    }
  }

  void _nextLetter(NextLetter event, Emitter<GameInitial> emit, {bool nextNotFilled = false, int checkFromStart = 0}) {
    int nextLetterIndex;

    if (checkFromStart > 0) {
      final emptyGuesses = state.playerGuesses.where((x) => x.letter?.isEmpty ?? true);
      final firstEmptyGuess =
          _getLettersCodeInOrder.firstWhereOrNull((x) => emptyGuesses.map((e) => e.code).contains(x.code));
      if (firstEmptyGuess != null) {
        nextLetterIndex = state.lettersOfQuoteInOrder.indexOf(firstEmptyGuess!.letter!);
      } else {
        return;
      }
    } else {
      nextLetterIndex = state.activeIndex + 1;
    }

    bool nextLetterIsHidden() {
      try {
        return state.hiddenLetters.contains(state.lettersOfQuoteInOrder[nextLetterIndex]);
      } catch (e) {
        return false;
      }
    }

    bool checkNextLetter() => (nextNotFilled
        ? getPlayerGuessLetterByCode(code: getCodeByLetter(letter: state.lettersOfQuoteInOrder[nextLetterIndex])!) == ''
        : true);

    if (nextLetterIsHidden() || !checkNextLetter()) {
      while (true) {
        if (nextLetterIsHidden()) {
          if (state.lettersOfQuoteInOrder[nextLetterIndex] == state.activeLetter) {
            nextLetterIndex += 1;
          } else {
            if (checkNextLetter()) {
              break;
            } else {
              nextLetterIndex += 1;
              if (nextLetterIndex >= state.lettersOfQuoteInOrder.length) {
                return;
              }
            }
          }
        } else {
          nextLetterIndex += 1;
          if (nextLetterIndex >= state.lettersOfQuoteInOrder.length) {
            _nextLetter(event, emit, checkFromStart: checkFromStart + 1);
          }
        }
      }
    }

    emit(state.copyWith(activeLetter: state.lettersOfQuoteInOrder[nextLetterIndex], activeIndex: nextLetterIndex));
  }

  void _previousLetter(PreviousLetter event, Emitter<GameInitial> emit) {
    int previousLetterIndex = state.activeIndex - 1;
    bool nextLetterIsNotHidden() => !state.hiddenLetters.contains(state.lettersOfQuoteInOrder[previousLetterIndex]);

    if (nextLetterIsNotHidden()) {
      while ((nextLetterIsNotHidden() || state.lettersOfQuoteInOrder[previousLetterIndex] == state.activeLetter)) {
        if (previousLetterIndex <= 0) {
          return;
        } else {
          previousLetterIndex -= 1;
          if (previousLetterIndex <= 0) {
            return;
          }
        }
      }
    }

    emit(state.copyWith(
        activeLetter: state.lettersOfQuoteInOrder[previousLetterIndex], activeIndex: previousLetterIndex));
  }

  void _clearLetter(ClearLetter event, Emitter<GameInitial> emit) {
    final playerGuesses = setLetter(
        letter: '', code: getCodeByLetter(letter: state.activeLetter)!, originalList: List.from(state.playerGuesses));
    letterPressedHistory.add(state);
    emit(state.copyWith(playerGuesses: playerGuesses));
  }

  void _onGameFinished(GameFinished event, Emitter<GameInitial> emit) {
    log("GAME WON");
    timer.cancel();
    emit(state.copyWith(gameStatus: event.hasWon ? GameStatus.success : GameStatus.failure));
  }

  FutureOr<void> _resetCurrentGame(ResetCurrentGame event, Emitter<GameInitial> emit) {
    List<LetterCode> list = [];

    for (LetterCode x in state.playerGuesses) {
      list.add(LetterCode(letter: state.hintedLetters.contains(x.letter) ? x.letter : '', code: x.code));
    }
    letterPressedHistory.clear();
    emit(state.copyWith(playerGuesses: list));
  }

  FutureOr<void> _onHintLetterPressed(HintLetter event, Emitter<GameInitial> emit) {
    final wrongOrNotFilledGuesses = state.playerGuesses.where((x) => getLetterByCode(code: x.code!) != x.letter);

    final randomLetter = wrongOrNotFilledGuesses
        .elementAt(wrongOrNotFilledGuesses.length == 1 ? 0 : math.Random().nextInt(wrongOrNotFilledGuesses.length - 1));

    final hintLetter = getLetterByCode(code: randomLetter.code!);

    final list = [...state.hintedLetters, hintLetter!];

    log("HINT LETTER GIVEN: $hintLetter CODE: ${randomLetter.code}");
    log("HINTED LETTERS LIST: $list");

    emit(state.copyWith(hintedLetters: list));
    _onLetterPressed(LetterPressed(hintLetter), emit, hintLetter: hintLetter);
  }
}

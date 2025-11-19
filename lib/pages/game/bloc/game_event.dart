part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class GameStarted extends GameEvent {
  final Level level;
  final String chosenAuthor;
  final String chosenCategory;

  @override
  List<Object> get props => [level, chosenAuthor, chosenCategory];

  const GameStarted(this.level, {this.chosenAuthor = '', this.chosenCategory = ''}) : super();
}

class GameFinished extends GameEvent {
  final bool hasWon;

  const GameFinished({this.hasWon = false}) : super();
}

class LetterPressed extends GameEvent {
  final String letter;
  const LetterPressed(this.letter);

  @override
  List<Object> get props => [letter];
}

class BoardLetterPressed extends GameEvent {
  final int index;
  const BoardLetterPressed(this.index);

  @override
  List<Object> get props => [index];
}

class NextLetter extends GameEvent {}

class PreviousLetter extends GameEvent {}

class UndoLetterPressed extends GameEvent {}

class ClearLetter extends GameEvent {}

class ResetCurrentGame extends GameEvent {}

class HintLetter extends GameEvent {}

class UpdateGameTime extends GameEvent {
  final Duration duration;

  const UpdateGameTime(this.duration);
}

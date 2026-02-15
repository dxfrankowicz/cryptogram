import 'package:cryptogram_game/app/colors.dart';
import 'package:cryptogram_game/services/domain.dart';
import 'package:cryptogram_game/pages/game/bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:google_fonts/google_fonts.dart';

class GameBoard extends StatelessWidget {
  GameBoard({Key? key}) : super(key: key);
  final List<UniqueKey> list = [];

  void _setActiveLetter(BuildContext context, int index) {
    BlocProvider.of<GameBloc>(context).add(BoardLetterPressed(index));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameBloc>().state;
    final playerGuesses = state.playerGuesses;
    final quote = state.quote;
    final activeLetter = state.activeLetter;
    final primaryColor = Theme.of(context).primaryColor;

    List<String> words = getWordListOfSentence(quote.text);
    double screenWidth = MediaQuery.of(context).size.width - 40;
    list.clear(); // Czyścimy listę przy każdym przebudowaniu

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 12, // Odstęp między linijkami
          children: words.map((word) {
            if (word.isEmpty) return const SizedBox(width: 20);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getLetterListOfSentence(word).map((letter) {
                  final code = state.lettersCode.firstWhereOrNull((x) => x.letter == letter)?.code;
                  UniqueKey key = UniqueKey();
                  list.add(key);
                  int currentIndex = list.indexOf(key);

                  bool isHidden = isLetterHidden(letter: letter, hiddenLetters: state.hiddenLetters);
                  bool isPunctuation = isPunctuationMark(letter);
                  bool isActive = activeLetter == letter;

                  double boxSize = (screenWidth / getLongestWordLength(quote)).clamp(20.0, 28.0);

                  return SizedBox(
                    width: boxSize,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: (isPunctuation || !isHidden) ? null : () => _setActiveLetter(context, currentIndex),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            height: boxSize * 1.2,
                            decoration: BoxDecoration(
                              color: isPunctuation
                                  ? Colors.transparent
                                  : (isActive ? primaryColor.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isActive ? primaryColor.withOpacity(0.5) : (Colors.white10),
                                width: isActive ? 1.5 : 1,
                              ),
                              boxShadow:
                                  isActive ? [BoxShadow(color: primaryColor.withOpacity(0.01), blurRadius: 12)] : [],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isPunctuation
                                  ? letter
                                  : isHidden
                                      ? playerGuesses.firstWhereOrNull((x) => x.code == code)?.letter?.toUpperCase() ??
                                          ''
                                      : letter.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: boxSize * 0.6,
                                fontWeight: FontWeight.bold,
                                color: state.hintedLetters.contains(letter) ? Colors.orangeAccent : (isActive ? primaryColor : Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // DOLNY SYMBOL (Kod szyfru)
                        if (!isPunctuation && isHidden)
                          SizedBox(
                            child: Text(
                              code?.toUpperCase() ?? '',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: boxSize * 0.4,
                                fontWeight: FontWeight.w500,
                                color: isActive ? primaryColor : Colors.grey.withOpacity(0.6),
                              ),
                            ),
                          )
                        else
                          SizedBox(height: boxSize * 0.4),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

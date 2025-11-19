import 'package:cryptogram_game/app/colors.dart';
import 'package:cryptogram_game/services/domain.dart';
import 'package:cryptogram_game/presentation/components/button_icon.dart';
import 'package:cryptogram_game/pages/game/bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Keyboard extends StatelessWidget {
  const Keyboard({Key? key}) : super(key: key);

  void _setPlayerLetter(BuildContext context, String e) {
    context.read<GameBloc>().add(LetterPressed(e));
  }

  void _undoSetPlayerLetter(BuildContext context) {
    context.read<GameBloc>().add(UndoLetterPressed());
  }

  void _nextLetter(BuildContext context) {
    context.read<GameBloc>().add(NextLetter());
  }

  void _previousLetter(BuildContext context) {
    context.read<GameBloc>().add(PreviousLetter());
  }

  void _clearLetter(BuildContext context) {
    context.read<GameBloc>().add(ClearLetter());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameBloc>().state;
    final textTheme = Theme.of(context).textTheme;

    return Container(
        decoration: const BoxDecoration(
            color: AppColors.shade2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: polishAlphabet
                    .map((e) => InkWell(
                          onTap: !isLetterHidden(
                                  letter: e, hiddenLetters: state.hiddenLetters)
                              ? null
                              : () => _setPlayerLetter(context, e),
                          child: SizedBox(
                            width: 35,
                            child: Card(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(6))),
                              margin:
                                  const EdgeInsets.only(bottom: 6, right: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(e.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: textTheme.titleLarge!.copyWith(
                                        color: state.playerGuesses
                                                .any((x) => x.letter == e)
                                            ? (state.hintedLetters.contains(e)
                                                ? AppColors.highlightSecond
                                                : AppColors.highlight)
                                            : !isLetterHidden(
                                                    letter: e,
                                                    hiddenLetters:
                                                        state.hiddenLetters)
                                                ? Colors.black.withOpacity(0.25)
                                                : Colors.grey.shade300)),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(6))),
                    margin: const EdgeInsets.only(bottom: 6, right: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: IconInteractive(
                        onTap: () {
                          _previousLetter(context);
                        },
                        icon: Icons.fast_rewind_rounded,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(6))),
                      margin: const EdgeInsets.only(bottom: 6, right: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: IconInteractive(
                          onTap: () {
                            _undoSetPlayerLetter(context);
                          },
                          icon: Icons.settings_backup_restore_rounded,
                        ),
                      )),
                ),
                Expanded(
                  child: Card(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(6))),
                      margin: const EdgeInsets.only(bottom: 6, right: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: IconInteractive(
                          onTap: () {
                            _clearLetter(context);
                          },
                          icon: Icons.clear,
                        ),
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Card(
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(6))),
                    margin: const EdgeInsets.only(bottom: 6, right: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: IconInteractive(
                        onTap: () {
                          _nextLetter(context);
                        },
                        icon: Icons.fast_forward_rounded,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}

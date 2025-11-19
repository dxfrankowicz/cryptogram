import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:cryptogram_game/presentation/components/button_icon.dart';
import 'package:cryptogram_game/pages/game/bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'board.dart';
import 'dart:math' as math;

import 'keyboard.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final _controllerCenter = ConfettiController(duration: const Duration(milliseconds: 1500));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameBloc>().state;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: state.gameStatus == GameStatus.success
            ? []
            : [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconInteractive(
                        icon: Icons.lightbulb_outline_rounded,
                        onTap: () {
                          context.read<GameBloc>().add(HintLetter());
                        },
                      ),
                      const SizedBox(width: 1.0),
                      const Text("", textAlign: TextAlign.left)
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconInteractive(
                      icon: Icons.refresh_rounded,
                      onTap: () {
                        context.read<GameBloc>().add(ResetCurrentGame());
                      },
                    ))
              ],
        title: Column(
          children: [
            const Text("KRYPTOGRAM", style: TextStyle(fontFamily: 'ProcrastinatingPixie', fontSize: 20)),
            Text(
              getGameDuration(state.gameDuration),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.white, fontSize: Theme.of(context).textTheme.bodySmall!.fontSize! + 1),
            )
          ],
        ),
      ),
      body: buildBlocConsumer(textTheme),
    );
  }

  String getGameDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget gameBoard(GameInitial state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(12.0),
              child: GameBoard(),
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: state.gameStatus == GameStatus.success ? 0 : 1,
          duration: const Duration(milliseconds: 1000),
          child: const Keyboard(),
        )
      ],
    );
  }

  Widget buildWinBoard(TextTheme textTheme, GameInitial state, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Lottie.asset(
                'assets/congratulations.json',
                fit: BoxFit.contain,
              ),
            ),
            Text(
              'Gratulacje!',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              state.quote.text,
              textAlign: TextAlign.justify,
              style: textTheme.bodySmall!
                  .copyWith(fontStyle: FontStyle.italic, fontSize: textTheme.bodySmall!.fontSize! + 5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    "${state.quote.author ?? "Autor nieznany"}${(state.quote.source?.isNotEmpty ?? false) ? ", ${state.quote.source!}" : ""}",
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.caveat(textStyle: textTheme.titleLarge!.copyWith())),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    height: 60.0,
                    onPressed: () {},
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                    color: Colors.redAccent,
                    padding: const EdgeInsets.all(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.exit_to_app_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: AutoSizeText(
                              'Powrót do menu głownego',
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              style: textTheme.labelLarge!.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MaterialButton(
                    height: 60.0,
                    onPressed: () {
                      context.read<GameBloc>().add(GameStarted(state.level,
                          chosenAuthor: state.chosenAuthor, chosenCategory: state.chosenCategory));
                    },
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                    color: Colors.blue,
                    padding: const EdgeInsets.all(6),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: AutoSizeText(
                              'Następny poziom',
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              style: textTheme.labelLarge!.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  BlocConsumer<GameBloc, GameInitial> buildBlocConsumer(TextTheme textTheme) {
    return BlocConsumer<GameBloc, GameInitial>(builder: (context, state) {
      return SafeArea(
          child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: state.gameStatus != GameStatus.success ? gameBoard(state) : buildWinBoard(textTheme, state, context),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
          Align(
            alignment: const Alignment(-1.0, 0.75),
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirection: math.pi * 1.75,
              // radial value - LEFT
              particleDrag: 0.05,
              // apply drag to the confetti
              emissionFrequency: 0.05,
              // how often it should emit
              numberOfParticles: 10,
              // number of particles to emit
              gravity: 0.05,
              // gravity - or fall speed
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.redAccent], // manually specify the colors to be used
            ),
          ),
          Align(
            alignment: const Alignment(1.0, 0.75),
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirection: math.pi * 1.25,
              // radial value - LEFT
              particleDrag: 0.05,
              // apply drag to the confetti
              emissionFrequency: 0.05,
              // how often it should emit
              numberOfParticles: 10,
              // number of particles to emit
              gravity: 0.05,
              // gravity - or fall speed
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.redAccent], // manually specify the colors to be used
            ),
          ),
        ],
      ));
    }, listener: (context, state) async {
      if (state.gameStatus == GameStatus.success) {
        print("dsfsdfd ${state.gameStatus}");
        _controllerCenter.play();
      }
    });
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:cryptogram_game/pages/game/bloc/game_bloc.dart';
import 'package:cryptogram_game/presentation/components/score_animated.dart';
import 'package:cryptogram_game/presentation/components/system_action_button.dart';
import 'package:cryptogram_game/services/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../app/colors.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  String getGameDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameBloc>().state;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // Kluczowe: transparent tła Scaffolda, bo gradient jest w Containerze body
      backgroundColor: AppColors.shade1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 75,
        surfaceTintColor: Colors.transparent, // Dodane, aby uniknąć zmiany koloru przy skrolowaniu
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              "KRYPTOGRAM",
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                getGameDuration(state.gameDuration),
                style: GoogleFonts.jetBrainsMono(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // POZIOM TRUDNOŚCI
            Text(
              state.level.name.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                color: state.level.color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: state.gameStatus == GameStatus.success
            ? []
            : [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SystemActionButton(
                      icon: Icons.lightbulb_outline_rounded,
                      label: "Tip",
                      underIconWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(state.maxHints, (index) {
                          bool isUsed = index >= (state.maxHints - state.hintedLetters.length);
                          return AnimatedContainer(
                            margin: EdgeInsets.only(right: index == state.maxHints - 1 ? 0 : 2),
                            width: 2.5,
                            height: 2.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUsed ? Colors.grey : Colors.cyanAccent,
                            ),
                            duration: const Duration(milliseconds: 500),
                          );
                        }),
                      ),
                      activeColor: Colors.orangeAccent,
                      disabled: state.hintedLetters.length == state.maxHints,
                      onTap: () {
                        _audioPlayer.stop();
                        _audioPlayer.play(AssetSource('sounds/hint.mp3'), volume: 1);
                        context.read<GameBloc>().add(HintLetter());
                      },
                    ),
                    Positioned(
                      top: 3,
                      right: -2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutQuint,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppColors.shade2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '45',
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 8),
                SystemActionButton(
                  icon: Icons.refresh_rounded,
                  label: "Reset",
                  activeColor: Colors.purpleAccent,
                  onTap: () => context.read<GameBloc>().add(ResetCurrentGame()),
                ),
                const SizedBox(width: 8),
              ],
      ),
      // Tutaj wstawiamy identyczny gradient jak na HomeScreen
      body: buildBlocConsumer(),
    );
  }

  Widget _buildAppBarAction({required IconData icon, required String label, required VoidCallback onTap}) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ramka z ikoną - styl identyczny jak ramka czasu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Dopasowane proporcje
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(height: 4),
          // Opis pod przyciskiem - styl identyczny jak poziom trudności
          Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              color: primaryColor.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBlocConsumer() {
    return BlocConsumer<GameBloc, GameInitial>(
      listener: (context, state) {
        if (state.gameStatus == GameStatus.success) {
          _controllerCenter.play();
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: state.gameStatus != GameStatus.success ? _buildGameBoard(state) : _buildWinBoard(state),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              ),
              _buildConfetti(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameBoard(GameInitial state) {
    return Column(
      key: const ValueKey("game_board"),
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: GameBoard(),
            ),
          ),
        ),
        const Keyboard(),
      ],
    );
  }

  Widget _buildWinBoard(GameInitial state) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Lottie.asset('assets/congratulations.json', height: 50),
              Expanded(
                child: AutoSizeText(
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  'Gratulacje!'.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primary,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Lottie.asset('assets/congratulations.json', height: 50),
            ],
          ),
          const SizedBox(height: 10),
          ScoreSummaryWidget(
            accentColor: primary,
            breakdown: state.score,
            level: state.level,
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        state.quote.text,
                        textAlign: TextAlign.center,
                        //overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "- ${state.quote.author ?? "Anonim"}",
                    style: GoogleFonts.orbitron(
                      color: primary.withOpacity(0.7),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildWinButton(
            label: "NASTĘPNY POZIOM",
            icon: Icons.navigate_next_rounded,
            isPrimary: true,
            onPressed: () {
              context.read<GameBloc>().add(
                  GameStarted(state.level, chosenAuthor: state.chosenAuthor, chosenCategory: state.chosenCategory));
            },
          ),
          const SizedBox(height: 12),
          _buildWinButton(
            label: "MENU GŁÓWNE",
            icon: Icons.exit_to_app_rounded,
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWinButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isPrimary ? LinearGradient(colors: [primary, primary.withBlue(255)]) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.05),
        border: isPrimary ? null : Border.all(color: Colors.white10),
        boxShadow:
            isPrimary ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.black : Colors.white70),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.black : Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(-1.0, 0.5),
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirection: -math.pi / 4,
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.1,
            colors: [Theme.of(context).primaryColor, Colors.white, Colors.blue],
          ),
        ),
        Align(
          alignment: const Alignment(1.0, 0.5),
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirection: -3 * math.pi / 4,
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.1,
            colors: [Theme.of(context).primaryColor, Colors.white, Colors.blue],
          ),
        ),
      ],
    );
  }
}

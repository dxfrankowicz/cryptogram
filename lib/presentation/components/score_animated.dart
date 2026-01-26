import 'package:cryptogram_game/services/domain.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import '../../pages/game/bloc/game_bloc.dart';

class ScoreSummaryWidget extends StatefulWidget {
  final ScoreBreakdown breakdown;
  final Level level;
  final Color accentColor;

  const ScoreSummaryWidget({
    super.key,
    required this.breakdown,
    required this.level,
    required this.accentColor,
  });

  @override
  State<ScoreSummaryWidget> createState() => _ScoreSummaryWidgetState();
}

class _ScoreSummaryWidgetState extends State<ScoreSummaryWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _tileAnimations;
  late List<Animation<int>> _scoreStepAnimations;

  final AudioPlayer _audioPlayer = AudioPlayer();
  int _lastPlayedValue = 0;

  static const int startDelayMs = 600;
  static const int stepDurationMs = 1300;

  @override
  void initState() {
    super.initState();

    final bool hasFlawless = widget.breakdown.flawlessMultiplier > 1.0;
    final int stepsCount = hasFlawless ? 4 : 3;
    final int totalDurationMs = (stepsCount * stepDurationMs) + startDelayMs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDurationMs),
    );

    final int s1 = widget.breakdown.basePoints;
    final int s2 = widget.breakdown.basePointsMultipliedByLevel;
    final int s3 = s2 + widget.breakdown.timeBonus;
    final int s4 = (s3 * widget.breakdown.flawlessMultiplier).round();

    double delayFactor = startDelayMs / totalDurationMs;
    double stepFactor = stepDurationMs / totalDurationMs;

    _tileAnimations = [];
    _scoreStepAnimations = [];

    for (int i = 0; i < stepsCount; i++) {
      double stepStart = delayFactor + (i * stepFactor);

      _tileAnimations.add(CurvedAnimation(
        parent: _controller,
        curve: Interval(stepStart, min(stepStart + (stepFactor * 0.4), 1.0), curve: Curves.elasticOut),
      ));

      int beginVal = i == 0 ? 0 : (i == 1 ? s1 : (i == 2 ? s2 : s3));
      int endVal = i == 0 ? s1 : (i == 1 ? s2 : (i == 2 ? s3 : s4));

      _scoreStepAnimations.add(IntTween(begin: beginVal, end: endVal).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
              stepStart + 0.02, // Mały offset, żeby dźwięk nie wyprzedził obrazu
              min(stepStart + (stepFactor * 0.75), 1.0),
              curve: Curves.easeOutCubic
          ),
        ),
      ));
    }

    _controller.addListener(() {
      final double t = _controller.value;
      if (t <= delayFactor) return;

      double normT = (t - delayFactor) / (1.0 - delayFactor);
      int currentIdx = (normT * stepsCount).floor().clamp(0, stepsCount - 1);

      // KLUCZ: Sprawdzamy czy kafelek już "wyskoczył"
      if (_tileAnimations[currentIdx].value > 0.2) {
        int currentScore = _getCurrentScore();
        if (currentScore > _lastPlayedValue) {
          _playTick();
          _lastPlayedValue = currentScore;
        }
      }
    });

    _controller.forward();
  }

  void _playTick() async {
    // Używamy lowLatency mode jeśli dostępny dla szybszych reakcji
    await _audioPlayer.play(AssetSource('sounds/tick.mp3'), volume: 0.9);
  }

  int _getCurrentScore() {
    final double t = _controller.value;
    final bool hasFlawless = widget.breakdown.flawlessMultiplier > 1.0;
    final int stepsCount = hasFlawless ? 4 : 3;
    double delayFactor = startDelayMs / _controller.duration!.inMilliseconds;

    if (t < delayFactor) return 0;

    double normalizedT = (t - delayFactor) / (1.0 - delayFactor);
    int currentIdx = (normalizedT * stepsCount).floor().clamp(0, stepsCount - 1);
    return _scoreStepAnimations[currentIdx].value;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFlawless = widget.breakdown.flawlessMultiplier > 1.0;
    List<Widget> tiles = [
      _buildAnimatedTile(0, Icons.text_fields, "Baza", "${widget.breakdown.basePoints}", widget.accentColor),
      _buildAnimatedTile(1, Icons.star_rounded, "Poziom", "x${widget.level.scoreMultiplier}", widget.level.color),
      _buildAnimatedTile(2, Icons.speed, "Czas", "+${widget.breakdown.timeBonus}", Colors.cyanAccent, true),
    ];
    if (hasFlawless) {
      tiles.add(_buildAnimatedTile(3, Icons.auto_awesome, "Bonus", "x1.2", Colors.amberAccent, true));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: tiles.map((tile) => Expanded(
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: tile),
            )).toList(),
          ),
        ),
        const SizedBox(height: 25),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double t = _controller.value;
            final int stepsCount = hasFlawless ? 4 : 3;
            double delayFactor = startDelayMs / _controller.duration!.inMilliseconds;
            double stepFactor = (1.0 - delayFactor) / stepsCount;
            bool isCounting = false;
            if (t > delayFactor) {
              double relativeT = (t - delayFactor) % stepFactor;
              isCounting = relativeT > 0.01 && relativeT < 0.75 && t < 0.98;
            }
            bool isFinished = t >= 0.98;

            return Column(
              children: [
                Text(
                  isFinished ? "WYNIK KOŃCOWY" : "NALICZANIE PUNKTÓW...",
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: isFinished ? widget.accentColor : (isCounting ? Colors.white : Colors.white24),
                    letterSpacing: 2,
                    fontWeight: isFinished ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Transform.scale(
                  scale: isCounting ? 1.08 : 1.0,
                  child: Text(
                    _getCurrentScore().toString(),
                    style: GoogleFonts.orbitron(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: widget.accentColor,
                      shadows: [
                        if (isCounting || isFinished)
                          Shadow(blurRadius: 25, color: widget.accentColor.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedTile(int idx, IconData icon, String label, String val, Color col, [bool bonus = false]) {
    return ScaleTransition(
      scale: _tileAnimations[idx],
      child: FadeTransition(
        opacity: _tileAnimations[idx],
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: col.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: col.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 12, color: col),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(fontSize: 8, color: Colors.white54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                val,
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: col, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }
}
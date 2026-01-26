import 'package:cryptogram_game/app/colors.dart';
import 'package:cryptogram_game/services/domain.dart';
import 'package:cryptogram_game/presentation/components/button_icon.dart';
import 'package:cryptogram_game/pages/game/bloc/game_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class Keyboard extends StatelessWidget {
  const Keyboard({Key? key}) : super(key: key);

  void _setPlayerLetter(BuildContext context, String e) => context.read<GameBloc>().add(LetterPressed(e));
  void _undoSetPlayerLetter(BuildContext context) => context.read<GameBloc>().add(UndoLetterPressed());
  void _nextLetter(BuildContext context) => context.read<GameBloc>().add(NextLetter());
  void _previousLetter(BuildContext context) => context.read<GameBloc>().add(PreviousLetter());
  void _clearLetter(BuildContext context) => context.read<GameBloc>().add(ClearLetter());

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameBloc>().state;
    final primaryColor = Theme.of(context).primaryColor;
    final quote = state.quote;

    return Container(
      decoration: BoxDecoration(
        // Ciemny, półprzezroczysty panel dolny
        color: const Color(0xFF12121A).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStaticAuthorSection(quote, primaryColor),

          const SizedBox(height: 8),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: polishAlphabet.map((e) {
              final bool isUsed = state.playerGuesses.any((x) => x.letter == e);
              final bool isHinted = state.hintedLetters.contains(e);
              final bool isHidden = isLetterHidden(letter: e, hiddenLetters: state.hiddenLetters);

              return _buildKey(
                label: e.toUpperCase(),
                onTap: !isHidden ? null : () => _setPlayerLetter(context, e),
                primaryColor: primaryColor,
                isActive: isUsed,
                isHinted: isHinted,
                isDisabled: !isHidden,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // --- PRZYCISKI FUNKCYJNE ---
          Row(
            children: [
              _buildActionKey(Icons.fast_rewind_rounded, () => _previousLetter(context), flex: 2),
              _buildActionKey(Icons.settings_backup_restore_rounded, () => _undoSetPlayerLetter(context)),
              _buildActionKey(Icons.clear, () => _clearLetter(context)),
              _buildActionKey(Icons.fast_forward_rounded, () => _nextLetter(context), flex: 2),
            ],
          ),
        ],
      ),
    );
  }

  // Pomocniczy widget dla sekcji autora
  Widget _buildStaticAuthorSection(dynamic quote, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: primaryColor.withOpacity(0.5), width: 2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 8),
                    const SizedBox(width: 4),
                    Text(
                      quote.author?.toUpperCase() ?? "AUTOR NIEZNANY",
                      style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                    ),
                  ],
                ),
                if (quote?.source?.toString().isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.text_snippet_outlined, color: Colors.white38, size: 8),
                        const SizedBox(width: 4),
                        Text(
                          quote.source!,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontStyle: FontStyle.italic,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 2),
                if (quote.categories?.isNotEmpty ?? false)
                  Row(
                    children: [
                      Icon(Icons.tag, color: primaryColor.withOpacity(0.7), size: 8),
                      const SizedBox(width: 4),
                      Text(
                        quote.categories!.join(', ').toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(fontSize: 8, color: primaryColor.withOpacity(0.7), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Mała ikona terminala dla klimatu
          Icon(Icons.terminal_rounded, size: 14, color: primaryColor.withOpacity(0.3)),
        ],
      ),
    );
  }

  // Stylizowany klawisz litery
  Widget _buildKey({
    required String label,
    required VoidCallback? onTap,
    required Color primaryColor,
    bool isActive = false,
    bool isHinted = false,
    bool isDisabled = false,
  }) {
    Color textColor = Colors.white;
    if (isDisabled) textColor = Colors.white24;
    else if (isHinted) textColor = Colors.orangeAccent;
    else if (isActive) textColor = primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? primaryColor.withOpacity(0.1) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  // Stylizowany klawisz funkcyjny
  Widget _buildActionKey(IconData icon, VoidCallback onTap, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 45,
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
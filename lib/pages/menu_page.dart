import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cryptogram_game/app/colors.dart';
import 'package:cryptogram_game/data.dart';
import 'package:cryptogram_game/services/domain.dart';
import 'package:cryptogram_game/pages/game/bloc/game_bloc.dart';
import 'package:cryptogram_game/pages/quotes/bloc/quotes_bloc.dart';
import 'package:cryptogram_game/pages/game/ui/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../presentation/components/cyber_loading.dart';

class SecretCodeWidget extends StatefulWidget {
  final TextStyle? style;

  const SecretCodeWidget({super.key, this.style});

  @override
  State<SecretCodeWidget> createState() => _SecretCodeWidgetState();
}

class _SecretCodeWidgetState extends State<SecretCodeWidget> {
  final String _chars = 'QWERTYUIOPASDFGHJKLZXCVBNM0123456789';
  final List<String> _subTitle = [
    "ODKRYWAJ SŁOWA",
    "ODKRYJ SZYFR",
    "UKRYTE ZNACZENIE",
    "POTĘGA UMYSŁU",
    "DESZYFRACJA...",
    "ZŁAM KOD"
  ];
  int _textIndex = 0;

  late List<String> _currentChars;
  late List<bool> _isRevealed;
  Timer? _animationTimer;
  Timer? _revealTimer;
  final Random _rnd = Random();
  int _revealIndex = 0;

  @override
  void initState() {
    super.initState();
    _subTitle.shuffle();
    _startFullCycle();
  }

  void _startFullCycle() {
    if (!mounted) return;
    String currentTarget = _subTitle[_textIndex];

    setState(() {
      _revealIndex = 0;
      _currentChars = List.generate(currentTarget.length, (_) => _getRandomChar());
      _isRevealed = List.generate(currentTarget.length, (_) => false);
    });

    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < currentTarget.length; i++) {
          if (!_isRevealed[i]) _currentChars[i] = _getRandomChar();
        }
      });
    });

    _textIndex = (_textIndex + 1) % _subTitle.length;
    _startRevealing(currentTarget);
  }

  void _startRevealing(String target) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    _revealTimer?.cancel();
    _revealTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) async {
      if (!mounted) return;
      if (_revealIndex < target.length) {
        setState(() {
          _isRevealed[_revealIndex] = true;
          _currentChars[_revealIndex] = target[_revealIndex].toUpperCase();
          _revealIndex++;
        });
      } else {
        timer.cancel();
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) _startFullCycle();
      }
    });
  }

  String _getRandomChar() => String.fromCharCode(_chars.codeUnitAt(_rnd.nextInt(_chars.length)));

  @override
  void dispose() {
    _animationTimer?.cancel();
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentChars.join(""), style: widget.style);
  }
}

// --- EKRAN STARTOWY ---
class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  Level _selectedDifficulty = Level.medium;
  String chosenCategory = '';
  String chosenAuthor = '';

  Widget getCategoryButton({required BuildContext context, required QuotesBloc quotesBloc}) {
    return BlocBuilder(
        bloc: quotesBloc,
        builder: (context, state) {
          final primaryColor = Theme.of(context).primaryColor;

          return SizedBox(
            height: 65,
            child: _buildMenuButton(context,
                label: "KATEGORIA / AUTOR",
                onTap: state is QuotesLoaded
                    ? () {
                  bool isCategoryTab = true;
                  AwesomeDialog(
                    context: context,
                    animType: AnimType.scale,
                    dialogType: DialogType.noHeader,
                    padding: EdgeInsets.zero,
                    dialogBackgroundColor: AppColors.shade1,
                    // Kluczowe dla stylu: usunięcie zaokrągleń systemowych na rzecz Twoich 15px
                    borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1),
                    body: StatefulBuilder(
                      builder: (context, _setState) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // TYTUŁ OKNA
                              Text("Baza Danych".toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                      color: primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2)),
                              const SizedBox(height: 20),

                              // PRZEŁĄCZNIK (TABS)
                              GestureDetector(
                                onTap: () {
                                  _setState(() {
                                    chosenCategory = '';
                                    chosenAuthor = '';
                                  });
                                  setState(() {}); // Odśwież menu główne
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    // Jeśli nic nie wybrano, ten przycisk jest aktywny
                                    color: (chosenCategory.isEmpty && chosenAuthor.isEmpty)
                                        ? primaryColor.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: (chosenCategory.isEmpty && chosenAuthor.isEmpty)
                                            ? primaryColor
                                            : Colors.white10,
                                        width: 1.5
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome,
                                          size: 16,
                                          color: (chosenCategory.isEmpty && chosenAuthor.isEmpty) ? primaryColor : Colors.white38),
                                      const SizedBox(width: 8),
                                      Text(
                                        "WSZYSTKIE / POPULARNE",
                                        style: GoogleFonts.jetBrainsMono(
                                            color: (chosenCategory.isEmpty && chosenAuthor.isEmpty) ? primaryColor : Colors.white38,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Divider(color: primaryColor.withOpacity(0.1), thickness: 1),
                              const SizedBox(height: 5),

                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    _buildTabItem(
                                        label: "KATEGORIE",
                                        isActive: isCategoryTab,
                                        onTap: () => _setState(() => isCategoryTab = true)),
                                    _buildTabItem(
                                        label: "AUTORZY",
                                        isActive: !isCategoryTab,
                                        onTap: () => _setState(() => isCategoryTab = false)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),


                              // LISTA ELEMENTÓW
                              Expanded(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: (isCategoryTab ? state.categories.length : state.authors.length),
                                  itemBuilder: (_, i) {
                                    final item = isCategoryTab ? state.categories[i] : state.authors[i];
                                    bool isSelected = (isCategoryTab && chosenCategory == item) ||
                                        (!isCategoryTab && chosenAuthor == item);

                                    return GestureDetector(
                                      onTap: () {
                                        _setState(() {
                                          if (isCategoryTab) {
                                            chosenCategory = item;
                                            chosenAuthor = '';
                                          } else {
                                            chosenAuthor = item;
                                            chosenCategory = '';
                                          }
                                        });
                                        setState(() {}); // Odśwież menu główne
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? primaryColor.withOpacity(0.15) : Colors.white.withOpacity(0.02),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                              color: isSelected ? primaryColor : Colors.white10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            item.toUpperCase(),
                                            style: GoogleFonts.jetBrainsMono(
                                                color: isSelected ? primaryColor : Colors.white60,
                                                fontSize: 12,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),

                              // PRZYCISK ZATWIERDŹ (W Twoim stylu)
                              _buildDialogCloseButton(context, primaryColor),
                            ],
                          ),
                        );
                      },
                    ),
                  ).show();
                }
                    : null,
                subLabelWidget: Flexible(
                  child: state is QuotesLoaded
                      ? Text(
                      chosenCategory.isNotEmpty
                          ? chosenCategory.toUpperCase()
                          : chosenAuthor.isNotEmpty
                          ? chosenAuthor.toUpperCase()
                          : "POPULARNE",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: true ? Colors.black87 : Colors.white54,
                          fontWeight: FontWeight.bold))
                      : const CyberLoadingAnim(isPrimary: true),
                ),
                icon: Icons.folder_open_rounded,
                isPrimary: true),
          );
        });
  }

// Pomocniczy widget dla zakładek wewnątrz dialogu
  Widget _buildTabItem({required String label, required bool isActive, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.blueGrey.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive ? Border.all(color: Colors.white24) : null,
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.white38)),
          ),
        ),
      ),
    );
  }

// Przycisk zamknięcia dialogu pasujący do reszty UI
  Widget _buildDialogCloseButton(BuildContext context, Color color) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text("POTWIERDŹ",
            style: GoogleFonts.jetBrainsMono(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final quotesBloc = context.watch<QuotesBloc>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.65,
            colors: [const Color(0xFF1A237E).withOpacity(0.25), AppColors.primary.withOpacity(0.01)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // LOGO
                Icon(Icons.enhanced_encryption_rounded, size: 70, color: Theme.of(context).primaryColor),
                const SizedBox(height: 15),
                AutoSizeText(
                  'KRYPTOGRAM',
                  maxFontSize: 36,
                  maxLines: 1,
                  style: GoogleFonts.orbitron(
                      fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 6, color: Colors.white),
                ),
                const SizedBox(height: 10),
                SecretCodeWidget(
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Theme.of(context).primaryColor)],
                  ),
                ),
                const Spacer(flex: 1),

                // WYBÓR TRUDNOŚCI
                Text("POZIOM TRUDNOŚCI",
                    style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white38, letterSpacing: 2)),
                const SizedBox(height: 15),
                _buildDifficultySelector(),

                const SizedBox(height: 40),

                getCategoryButton(context: context, quotesBloc: quotesBloc),
                const SizedBox(height: 15),
                _buildMenuButton(context, label: "NOWA GRA", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return BlocProvider(
                        create: (ctx) {
                          final gameBloc = GameBloc(ctx.read<GameStatsRepository>());
                          return gameBloc
                            ..add(GameStarted(_selectedDifficulty,
                                chosenCategory: chosenCategory, chosenAuthor: chosenAuthor));
                        },
                        child: const GamePage(),
                      );
                    }),
                  );
                }, icon: Icons.add_rounded, isPrimary: false),
                const SizedBox(height: 15),
                _buildMenuButton(context, label: "Wyzwanie dnia", icon: Icons.star_border_rounded, isPrimary: false),
                const Spacer(flex: 3),

                // FOOTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomIcon(Icons.leaderboard_rounded, "RANKING"),
                    _buildBottomIcon(Icons.settings_suggest_rounded, "OPCJE"),
                    _buildBottomIcon(Icons.help_outline_rounded, "POMOC"),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Level.values.map((d) {
        bool isSel = _selectedDifficulty == d;
        Color levelColor = d.color;
        Color primaryBlue = AppColors.primary;

        // Expanded sprawia, że każdy przycisk zajmuje dokładnie tyle samo miejsca
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              // Zmniejszamy margines poziomy, by przyciski niemal się stykały lub miały równe przerwy
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? Colors.white.withOpacity(0.05) : Colors.transparent,
                // Obramowanie teraz jest spójne dla wszystkich, by tworzyło linię
                border: Border.all(
                  color: isSel ? primaryBlue : Colors.white10,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.name.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10, // Nieco mniejszy font, by zmieścił się na mniejszych ekranach
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? Colors.white : Colors.white38,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Linia akcentowa
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    // Szerokość paska: gdy wybrany, zajmuje 60% przycisku, gdy nie - małą kropkę
                    width: isSel ? 35 : 4,
                    height: 2,
                    decoration: BoxDecoration(
                      color: isSel ? levelColor : levelColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSel ? [
                        BoxShadow(
                            color: levelColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1
                        )
                      ] : [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String label,
        String? subLabel,
        Widget? subLabelWidget,
        required IconData icon,
        Function()? onTap,
        required bool isPrimary}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: isPrimary ? LinearGradient(colors: [Theme.of(context).primaryColor, const Color(0xFF00E5FF)]) : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.05),
        border: isPrimary ? null : Border.all(color: Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: isPrimary ? Colors.black : Colors.white),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: isPrimary ? Colors.black : Colors.white)),
                    if (subLabelWidget != null) subLabelWidget,
                    if (subLabel != null)
                      Text(subLabel,
                          style: TextStyle(fontSize: 10, color: isPrimary ? Colors.black54 : Colors.white38)),
                  ],
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, size: 18, color: isPrimary ? Colors.black38 : Colors.white24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

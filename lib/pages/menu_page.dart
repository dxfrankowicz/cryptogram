import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cryptogram_game/app/colors.dart';
import 'package:cryptogram_game/data.dart';
import 'package:cryptogram_game/services/domain.dart';
import 'package:cryptogram_game/pages/game/bloc/game_bloc.dart';
import 'package:cryptogram_game/pages/quotes/bloc/quotes_bloc.dart';
import 'package:cryptogram_game/pages/game/ui/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String chosenCategory = '';
  String chosenAuthor = '';

  @override
  Widget build(BuildContext context) {
    final quotesBloc = context.watch<QuotesBloc>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("KRYPTOGRAM", style: TextStyle(fontFamily: 'ProcrastinatingPixie', fontSize: 40)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                getCategoryButton(context: context, quotesBloc: quotesBloc),
                const SizedBox(height: 12),
                ...Level.values.map((level) => geLevelButton(context: context, level: level)).toList()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getCategoryButton({required BuildContext context, required QuotesBloc quotesBloc}) {
    return BlocBuilder(
        bloc: quotesBloc,
        builder: (context, state) {
          return SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: InkWell(
                onTap: state is QuotesLoaded
                    ? () {
                        bool categories = true;
                        AwesomeDialog(
                          context: context,
                          animType: AnimType.scale,
                          dialogType: DialogType.noHeader,
                          dialogBackgroundColor: AppColors.shade1,
                          body: StatefulBuilder(
                            builder: (_, _setState) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Card(
                                                shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(8))),
                                                color: AppColors.shade2,
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            _setState(() {
                                                              categories = true;
                                                            });
                                                          },
                                                          child: Container(
                                                              color: categories ? Colors.blueGrey : null,
                                                              padding: const EdgeInsets.all(8),
                                                              child: const Center(child: Text("Kategorie"))),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            _setState(() {
                                                              categories = false;
                                                            });
                                                          },
                                                          child: Container(
                                                              color: !categories ? Colors.blueGrey : null,
                                                              padding: const EdgeInsets.all(8),
                                                              child: const Center(child: Text("Autorzy"))),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Expanded(
                                          child: ListView.builder(
                                              itemCount: (categories ? state.categories.length : state.authors.length),
                                              itemBuilder: (_, i) {
                                                final item = categories ? state.categories[i] : state.authors[i];
                                                return InkWell(
                                                  onTap: () {
                                                    _setState(() {
                                                      if (categories) {
                                                        chosenCategory = state.categories[i];
                                                        chosenAuthor = '';
                                                      } else {
                                                        chosenAuthor = state.authors[i];
                                                        chosenCategory = '';
                                                      }
                                                    });
                                                    setState(() {});
                                                  },
                                                  child: Card(
                                                    shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: (categories &&
                                                                        chosenCategory == state.categories[i]) ||
                                                                    (!categories && chosenAuthor == state.authors[i])
                                                                ? Colors.blueGrey
                                                                : Colors.transparent,
                                                            width: 2),
                                                        borderRadius: BorderRadius.all(Radius.circular(8))),
                                                    color: AppColors.shade2,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Center(child: Text(item)),
                                                    ),
                                                  ),
                                                );
                                              },
                                              padding: const EdgeInsets.only(bottom: 8)),
                                        )
                                      ],
                                    )),
                              );
                            },
                          ),
                          title: 'Choose category or author',
                          btnOkOnPress: () {},
                        ).show();
                      }
                    : null,
                highlightColor: Colors.blue,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: Card(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  shadowColor: Colors.blue,
                  elevation: 3.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                      child: Column(
                        children: [
                          Text("KATEGORIA/AUTOR",
                              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                          state is QuotesLoaded
                              ? Text(
                                  chosenCategory.isNotEmpty
                                      ? chosenCategory
                                      : chosenAuthor.isNotEmpty
                                          ? chosenAuthor
                                          : "POPULARNE",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white))
                              : const CircularProgressIndicator()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget geLevelButton({required BuildContext context, required Level level}) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return BlocProvider(
                  create: (ctx) {
                    final gameBloc = GameBloc(ctx.read<GameStatsRepository>());
                    return gameBloc
                      ..add(GameStarted(level, chosenCategory: chosenCategory, chosenAuthor: chosenAuthor));
                  },
                  child: const GamePage(),
                );
              }),
            );
          },
          highlightColor: level.color,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Card(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
            shadowColor: level.color,
            elevation: 3.0,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                child: Text(level.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: level.color, fontFamily: 'ProcrastinatingPixie')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

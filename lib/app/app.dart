import 'package:cryptogram_game/data.dart';
import 'package:cryptogram_game/pages/quotes/bloc/quotes_bloc.dart';
import 'package:cryptogram_game/pages/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'colors.dart';

class CryptogramGameApp extends StatelessWidget {
  const CryptogramGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kryptogram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.shade1,
        brightness: Brightness.dark,
        fontFamily: 'Ubuntu',
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          color: Colors.transparent,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(64, 48),
            textStyle: const TextStyle(
              fontFamily: 'Ubuntu',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(64, 48),
            side: const BorderSide(width: 1, color: AppColors.primary),
            textStyle: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(64, 48),
            textStyle: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: BlocProvider(
          create: (ctx) =>
              QuotesBloc(ctx.read<GameStatsRepository>())..add(const GetQuotes(forceGetFromFirestore: true)),
          child: const HomeMenuScreen()),
    );
  }
}
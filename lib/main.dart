import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'data.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //FirestoreService.getData();

  runApp(RepositoryProvider(
    create: (context) => GameStatsRepository(GameStatsSharedPrefProvider()),
    child: const CryptogramGameApp(),
  ));
}

///do dodania cytaty

///https://cytatybaza.pl/cytaty/ekonomiczne/o-pieniadzach/

///https://refleksja.info/kategorie
///
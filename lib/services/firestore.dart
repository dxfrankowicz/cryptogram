import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptogram_game/models/quote.dart';
import 'package:flutter/services.dart';

class FirestoreService {
  static final db = FirebaseFirestore.instance;

  static Future<List<Quote>> getData() async {
    // final res = await db.collection('quotes').get();
    // if (res.docs.isNotEmpty) {
    //   return res.docs.map((e) {
    //     return Quote.fromJson(e.data());
    //   }).toList();
    // } else
    //   return [];

    String data = await rootBundle.loadString("assets/quotes/quotes.json");
    List json = jsonDecode(data);

    return json.map((e) {
      return Quote.fromJson(e);
    }).toList();
  }

  static Future<void> addData() async {
    // String data = await rootBundle.loadString("assets/quotes/quotes.json");
    // List json = jsonDecode(data);
    //
    // int i = 0;
    // for (var x in json) {
    //   await db.collection('quotes').doc().set(x);
    // }
  }
}

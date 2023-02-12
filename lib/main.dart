import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zefyrka/zefyrka.dart';
import 'package:card_flow/home_screen.dart';
import 'deck_data.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  Data.instance.deleteDatabase();
  await Data.instance.deleteAllDecks();
  print(await Data.instance.createDeck(Deck(name: "AP Calculus", cardsDue: 13, dateCreated: DateTime.now())));

  Deck southAmerica = await Data.instance.createDeck(Deck(name: "South American Capitals", cardsDue: 3, dateCreated: DateTime.now()));
  await Data.instance.createFlashcard(Flashcard.fromPlainText("Argentina", "Buenos Aires", deckID: southAmerica.id ));
  await Data.instance.createFlashcard(Flashcard.fromPlainText("Bolivia", "La Paz Sucre", deckID: southAmerica.id));
  await Data.instance.createFlashcard(Flashcard.fromPlainText("Brazil", "Brasilia", deckID: southAmerica.id));
  await Data.instance.createFlashcard(Flashcard.fromPlainText("Chile", "Santiago", deckID: southAmerica.id));

  await Data.instance.createDeck(Deck(name: "AP Statistics Chapter 6 Equations", cardsDue: 3, dateCreated: DateTime.now()));

  await Data.instance.createDeck(Deck(name: "Anatomy of the brain", cardsDue: 7, dateCreated: DateTime.now()));

  await Data.instance.createDeck(Deck(name: "Trigonometry Identities", cardsDue: 8, dateCreated: DateTime.now()));

  runApp(const MaterialApp(home: HomeScreen()));




}





class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  ZefyrController? _controller;
  FocusNode? _focusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _focusNode = FocusNode();
    _controller = ZefyrController();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ZefyrToolbar.basic(controller: _controller!),
          Center(child: ZefyrEditor(controller: _controller!,))
        ],
      ),
    );
  }
}

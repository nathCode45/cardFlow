import 'dart:convert';

import 'package:card_flow/launch_deck.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zefyrka/zefyrka.dart';
import 'package:card_flow/home_screen.dart';
import 'card_edit_screen.dart';
import 'deck_data.dart';
import 'image_card_view_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();



  Data.instance.deleteDatabase();
  await Data.instance.deleteAllDecks();
  await Data.instance.deleteAllFlashcards();
  print(await Data.instance.createDeck(Deck(name: "AP Calculus", dateCreated: DateTime.now())));

  Deck southAmerica = await Data.instance.createDeck(Deck(name: "South American Capitals", dateCreated: DateTime.now()));
  await Data.instance.createFlashcard(Flashcard.fromPlainText("Argentina", "Buenos Aires", deckID: southAmerica.id ));
  await Data.instance.createFlashcard(Flashcard.fromPlainText("Bolivia", "La Paz Sucre", deckID: southAmerica.id));
  await Data.instance.createFlashcard(Flashcard.fromPlainText("Brazil", "Brasilia", deckID: southAmerica.id));
  await Data.instance.createFlashcard(Flashcard.fromPlainText("Chile", "Santiago", deckID: southAmerica.id));

  await Data.instance.createDeck(Deck(name: "AP Statistics Chapter 6 Equations", dateCreated: DateTime.now()));

  await Data.instance.createDeck(Deck(name: "Anatomy of the brain", dateCreated: DateTime.now()));

  await Data.instance.createDeck(Deck(name: "Trigonometry Identities", dateCreated: DateTime.now()));

  runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const HomeScreen(),
        LaunchDeck.routeName: (context)=> const LaunchDeck(),
        CardEdit.routeName: (context)=> const CardEdit(),
        ImageCardViewScreen.routeName: (context)=>const ImageCardViewScreen()
        //'/launch_deck': (context) => const LaunchDeck(deck: decks,)),
      }
  ),
    
  );




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

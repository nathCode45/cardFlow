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
  await Data.instance.deleteAllProgress();

  // print(await Data.instance.createDeck(Deck(name: "AP Calculus", dateCreated: DateTime.now())));
  //
  Deck sampleDeck = await Data.instance.createDeck(Deck(name: "Sample Deck - How to use CardFlow", dateCreated: DateTime.now()));



  Flashcard card1 = Flashcard(deckID: sampleDeck.id,'[{"insert":"How does CardFlow help you learn?\n"}]', '[{"insert":"CardFlow optimizes the timing of information recall using a spaced repetition algorithm"},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"This works by presenting you with flashcards at increasing intervals of time, based on how well you remember it"},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"If you recall the flashcard easily, the algorithm will wait longer before asking you to recall it again"},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"If you struggle to recall the flashcard, the algorithm will present the information to you again sooner"},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"The algorithm will adapt to your individual learning style and pace"},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"This approach helps to ensure that you spend your time and energy on the information that you need to focus on the most"},{"insert":"\n","attributes":{"block":"ul"}}]');
  //await Data.instance.createFlashcard(card1);
  // await Data.instance.createFlashcard(Flashcard.fromPlainText("Argentina", "Buenos Aires", deckID: southAmerica.id ));
  // await Data.instance.createFlashcard(Flashcard.fromPlainText("Bolivia", "La Paz Sucre", deckID: southAmerica.id));
  // await Data.instance.createFlashcard(Flashcard.fromPlainText("Brazil", "Brasilia", deckID: southAmerica.id));
  // await Data.instance.createFlashcard(Flashcard.fromPlainText("Chile", "Santiago", deckID: southAmerica.id));
  //
  // await Data.instance.createDeck(Deck(name: "AP Statistics Chapter 12 Equations", dateCreated: DateTime.now()));
  //
  // await Data.instance.createDeck(Deck(name: "Anatomy of the brain", dateCreated: DateTime.now()));
  //
  // await Data.instance.createDeck(Deck(name: "Trigonometry Identities", dateCreated: DateTime.now()));
  //
  // for(int i =0; i<3; i++){
  //   await Data.instance.createProgressRep(ProgressRep(dateTime: DateTime(2023, 4, 6), deckID: 0));
  // }
  // for(int i =0; i<2; i++){
  //   await Data.instance.createProgressRep(ProgressRep(dateTime: DateTime(2023, 4, 4), deckID: 0));
  // }
  // for(int i =0; i<6; i++){
  //   await Data.instance.createProgressRep(ProgressRep(dateTime: DateTime(2023, 4, 7), deckID: 0));
  // }
  // for(int i =0; i<3; i++){
  //   await Data.instance.createProgressRep(ProgressRep(dateTime: DateTime(2023, 3, 28), deckID: 0));
  // }
  // for(int i =0; i<8; i++){
  //   await Data.instance.createProgressRep(ProgressRep(dateTime: DateTime(2023, 4, 10), deckID: 0));
  // }
  //
  // for(int i =0; i<3; i++){
  //   await Data.instance.createProgressRep(ProgressRep(dateTime: DateTime(2023, 4, 9), deckID: 0));
  // }
  //
  // for(int i =0; i<18; i++){
  //   await Data.instance.createProgressRep(ProgressRep(dateTime: DateTime(2023, 4, 8), deckID: 0));
  // }



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

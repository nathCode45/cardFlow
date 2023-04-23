import 'dart:convert';

import 'package:card_flow/capitals_deck.dart';
import 'package:card_flow/launch_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Deck sampleDeck = await Data.instance.createDeck(Deck(name: "Sample Deck - CardFlow & Memory", dateCreated: DateTime.now()));
  CapitalsDeck.createDeck();



  Flashcard card1 = Flashcard(deckID: sampleDeck.id,
      '[{"insert":"How does CardFlow help you learn?\\n"}]','[{"insert":"CardFlow optimizes the timing of information recall using a spaced repetition algorithm"},{"insert":"\\n","attributes":{"block":"ul"}},{"insert":"This works by presenting you with flashcards at increasing intervals of time, based on how well you remember them"},{"insert":"\\n","attributes":{"block":"ul"}},{"insert":"If you recall the flashcard easily, the algorithm will wait longer before asking you to recall it again"},{"insert":"\\n","attributes":{"block":"ul"}},{"insert":"If you struggle to recall the flashcard, the algorithm will present the information to you again sooner"},{"insert":"\\n","attributes":{"block":"ul"}},{"insert":"The algorithm will adapt to your individual learning style and pace"},{"insert":"\\n","attributes":{"block":"ul"}},{"insert":"This approach helps to ensure that you spend your time and energy on the information that you need to focus on the most"},{"insert":"\\n","attributes":{"block":"ul"}}]'
  );
  Flashcard card2 = Flashcard(deckID: sampleDeck.id, '[{"insert":"Tips for creating good flashcards\\n"}]',
  '[{"insert":"Keep it simple: use short and concise sentences/phrases—break up larger pieces of information into multiple flashcards of shorter chunks"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"Understand your cards before you try to memorize them"},{"insert":"\\n","attributes":{"block":"ol"}},{"insert":"Try using mnemonics and acronyms"},{"insert":"\\n","attributes":{"block":"ol"}}]');

  Flashcard memory = Flashcard(deckID: sampleDeck.id,
      '[{"insert":"Definition of "},{"insert":"memory","attributes":{"b":true}},{"insert":"\\n"}]',
        '[{"insert":"the persistence of learning over time through the mental process of encoding, storing, and retrieving information\\n"}]');
  Flashcard encoding = Flashcard(deckID: sampleDeck.id,
    '[{"insert":"encoding ","attributes":{"b":true}},{"insert":"(psychology definition)\\n"}]',
    '[{"insert":"the processing of information from the external environment into the brain’s memory system—for example, by extracting meaning\\n"}]'
  );

  Flashcard storage = Flashcard(deckID: sampleDeck.id,
      '[{"insert":"storage","attributes":{"b":true}},{"insert":" (psychology definition)\\n"}]',
      '[{"insert":"the process of retaining encoded information over time\\n"}]'
  );

  Flashcard retrieval = Flashcard(deckID: sampleDeck.id,
    '[{"insert":"retrieval","attributes":{"b":true}},{"insert":" (psychology definition)\\n"}]',
    '[{"insert":"the process of accessing information from memory storage\\n"}]'
  );

  Flashcard effortfulProcessing = Flashcard(deckID: sampleDeck.id,
    '[{"insert":"effortful processing","attributes":{"b":true}},{"insert":" (psychology definition)\\n"}]',
    '[{"insert":"the intentional and conscious processing of information that requires mental effort, attention, and cognitive resources\\nmore optimal for learning and memory performance than shallow processing"},{"insert":"\\n","attributes":{"block":"ul"}}]'
  );

  Flashcard shallowProcessing = Flashcard(deckID: sampleDeck.id,
    '[{"insert":"shallow processing","attributes":{"b":true}},{"insert":" (psychology definition)\\n"}]',
    '[{"insert":"the relatively superficial and surface-level processing of information involving limited attention and cognitive resources\\nex: skimming through notes"},{"insert":"\\n","attributes":{"block":"ul"}},{"insert":"less optimal for learning and memory performance than effortful processing"},{"insert":"\\n","attributes":{"block":"ul"}}]'
  );

  Flashcard hippocampus = Flashcard(deckID: sampleDeck.id,
    '[{"insert":"hippocampus\\n"}]',
    '[{"insert":"a part of the brain that plays a critical role in the formation and consolidation of new memories\\n"}]'
  );

  ByteData ebbClearImage = await rootBundle.load('assets/EBB_clear.png');
  String encodedClear = base64Encode(ebbClearImage.buffer.asUint8List());

  ByteData ebbTitleImage = await rootBundle.load('assets/EBB_title_mask.png');
  Flashcard ebbTitle = Flashcard(deckID: sampleDeck.id,
    base64Encode(ebbTitleImage.buffer.asUint8List()),
    encodedClear,
    isImage: true
  );


  ByteData ebbYAxisImage = await rootBundle.load('assets/EBB_y_mask.png');
  Flashcard ebbYAxis = Flashcard(deckID: sampleDeck.id,
    base64Encode(ebbYAxisImage.buffer.asUint8List()),
    encodedClear,
    isImage: true
  );


  ByteData ebbXAxisImage = await rootBundle.load('assets/EBB_x_mask.png');
  Flashcard ebbXAxis = Flashcard(deckID: sampleDeck.id,
    base64Encode(ebbXAxisImage.buffer.asUint8List()),
    encodedClear,
    isImage: true
  );



  //Flashcard card1 = Flashcard(, deckID: sampleDeck.id);
  List <Flashcard> samples = [memory,card1,card2,ebbTitle,ebbYAxis, ebbXAxis, encoding, storage, retrieval, effortfulProcessing,
  shallowProcessing, hippocampus];
  for(int i =0; i<samples.length; i++){
    await Data.instance.createFlashcard(samples[i]);
  }

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




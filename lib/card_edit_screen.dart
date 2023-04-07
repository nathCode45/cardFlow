import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

import 'package:card_flow/deck_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart';

class DeckDrop{
  int? id;
  String? name;

  DeckDrop(id, name);

}

class CardEditScreenArguments{
  Flashcard? card;
  final int selectedDeckID;

  CardEditScreenArguments({this.card, required this.selectedDeckID});
}


class CardEdit extends StatefulWidget {

  static const routeName = '/card_edit';


  const CardEdit({super.key});


  @override
  State<CardEdit> createState() => _CardEditState();
}

class _CardEditState extends State<CardEdit> {
  _CardEditState();

  ZefyrController? _controller;
  ZefyrController? _controller2;
  FocusNode? _focusNode;

  bool isLoading = false;
  late List<Deck> decks;
  late List<DeckDrop> drops;
  Map<int, String> deckDropMap={};

  var args;




  Future refreshDecks() async {
    setState(() {
      isLoading = true;
    });

    this.decks = await Data.instance.readDecks();

    decks.forEach(
        (Deck d){
          deckDropMap[d.id!] = d.name;
        }
    );

    //widget.selectedDeckID = deckDropMap.keys.toList().first;

    setState(() => isLoading = false);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    refreshDecks();


    _focusNode = FocusNode();
    _controller = ZefyrController();
    _controller2 = ZefyrController();
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as CardEditScreenArguments;

    if (args.card == null) {
      args.card = Flashcard("", "", id: 1);
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            args.card!.front,
            style: const TextStyle(fontFamily: 'Lexend'),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Deck: ", style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontFamily: "Lexend",
                        fontWeight: FontWeight.bold)),
                    isLoading? const Center(child: CircularProgressIndicator()) : DropdownButton<int>(
                        value: args.selectedDeckID,
                        items:
                        deckDropMap.keys.toList().map<DropdownMenuItem<int>>((int idv){
                          print("current decks: ${decks}");
                          return DropdownMenuItem<int>(value: idv, child: Text(deckDropMap[idv]!, style: const TextStyle(
                              fontSize: 16.0, color: Colors.black, fontFamily: "Lexend")));
                        }
                        ).toList(),
                        onChanged: (int? idv) {
                          setState(() {
                            args.selectedDeckID = idv!;
                          });
                        }
                    )
                    // DeckListDropdown(initialSelectedDeck: widget.selectedDeck!)

                  ],
                ),
              )
              , const Text("Front", style: TextStyle(
                  fontSize: 26.0, color: Colors.black, fontFamily: "Lexend")),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ZefyrToolbar.basic(controller: _controller!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Container(decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.black)), child:
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ZefyrEditor(controller: _controller!
                    ,),
                ))),
              ),
              SizedBox(height: 50,),
              const Text("Back", style: TextStyle(
                  fontSize: 26.0, color: Colors.black, fontFamily: "Lexend")),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ZefyrToolbar.basic(controller: _controller2!),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Container(decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.black)), child:
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ZefyrEditor(controller: _controller2!
                    ,),
                ))),
              ),
              Center(
                child: Container(
                  width: 125,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveDocument(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.save),
                        SizedBox(width: 8,),
                        Text("Save"),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                  child: Container(
                    width: 125,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey[400]!),
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.white)
                      ),
                      onPressed: () {

                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.delete),
                          SizedBox(width: 8,),
                          Text("Delete"),
                        ],
                      ),
                    ),
                  )
              )
            ],
          ),
        )
    );
  }

  void _saveDocument(BuildContext context) async {
    final contents = jsonEncode(_controller!.document);
    final contents2 = jsonEncode(_controller2!.document);
    await Data.instance.createFlashcard(Flashcard(contents, contents2, deckID: args.selectedDeckID));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Saved.')));

    ///reset controllers to be empty
    setState(() {
      _controller = ZefyrController();
      _controller2 = ZefyrController();
    });




    // final file = File(Directory.systemTemp.path + '/front_save.json');
    // final file2 = File(Directory.systemTemp.path + "/back_save.json");
    // file.writeAsString(contents).then((_) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(SnackBar(content: Text('Saved.')));
    // });
    // file2.writeAsString(contents2);
  }
}

// class DeckListDropdown extends StatefulWidget {
//   DeckListDropdown({Key? key, required this.initialSelectedDeck}) : super(key: key);
//   final Deck initialSelectedDeck;
//
//
//   @override
//   State<DeckListDropdown> createState() => DeckListDropdownState();
// }
//
// class DeckListDropdownState extends State<DeckListDropdown> {
//   Deck? selectedDeck;
//   bool isLoading = false;
//   late List<Deck> decks;
//
//   @override
//   void initState() {
//     refreshDecks();
//     selectedDeck = widget.initialSelectedDeck;
//     super.initState();
//   }
//
//   Future refreshDecks() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     this.decks = await Data.instance.readDecks();
//
//     setState(() => isLoading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
//       shrinkWrap: true,
//         itemCount: decks.length,
//         itemBuilder: (context, index) {
//           return DropdownButton<Deck>(
//               value: selectedDeck,
//               items:
//                   List.generate(decks.length, (index) {
//                     return DropdownMenuItem<Deck>(value: decks[index],
//                                   child: Text(decks[index].name, style: const TextStyle(
//                                       fontSize: 16.0,
//                                       color: Colors.black,
//                                       fontFamily: "Lexend")));
//                   }),
//               onChanged: (Deck? value) {
//                 setState(() {
//                   selectedDeck = value!;
//                 });
//               }
//           );
//
//         }
//     );
//   }
// }
//
//

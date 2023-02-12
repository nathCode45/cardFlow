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


class CardEdit extends StatefulWidget {
  Flashcard? card;
  int? selectedDeckID;


  CardEdit({super.key, this.card, this.selectedDeckID});


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
    if (widget.card == null) {
      widget.card = Flashcard("", "", id: 1);
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.card!.front,
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
                        value: widget.selectedDeckID,
                        items:
                        deckDropMap.keys.toList().map<DropdownMenuItem<int>>((int idv){
                          print("current decks: ${decks}");
                          return DropdownMenuItem<int>(value: idv, child: Text(deckDropMap[idv]!, style: const TextStyle(
                              fontSize: 16.0, color: Colors.black, fontFamily: "Lexend")));
                        }
                        ).toList(),
                        onChanged: (int? idv) {
                          setState(() {
                            widget.selectedDeckID = idv!;
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

  void _saveDocument(BuildContext context) {
    NotusDocument document = NotusDocument();
    document.insert(0, "This");
    NotusDocument().insert(0,'This');
    //TODO FOR NEXT TIME, just change database type to JSON for NotusDoc, the above lines are how you insert text into one,
    String mString = jsonEncode(document);
    final contents = jsonEncode(_controller!.document);
    final contents2 = jsonEncode(_controller!.document);
    final file = File(Directory.systemTemp.path + '/front_save.json');
    final file2 = File(Directory.systemTemp.path + "/back_save.json");
    file.writeAsString(contents).then((_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved.')));
    });
    file2.writeAsString(contents2);
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

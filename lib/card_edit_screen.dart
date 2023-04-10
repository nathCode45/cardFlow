import 'dart:convert';
import 'dart:io';
import 'package:card_flow/launch_deck.dart';
import 'package:sqflite/sqflite.dart';

import 'package:card_flow/deck_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart';
import 'package:google_fonts/google_fonts.dart';

class DeckDrop{
  int? id;
  String? name;

  DeckDrop(id, name);

}

class CardEditScreenArguments{
  Flashcard? card;
  int selectedDeckID;



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
  late bool isExistingCard;




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

  String _shorten(String str){
    const int CHARACTER_LIMIT = 20;
    String singleLine = str.replaceAll("\n", " ");
    if (singleLine.length>CHARACTER_LIMIT){
      return '${singleLine.substring(0, CHARACTER_LIMIT)}...';
    }else{
      return singleLine;
    }

  }

  String _decodeCardTitle(Flashcard input)=> _shorten(NotusDocument.fromJson(jsonDecode(input.front)).toPlainText());


  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    refreshDecks();


    _focusNode = FocusNode();
    _controller = ZefyrController();
    _controller2 = ZefyrController();
  }

  Future<void> _showDeleteDialog() async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Are you sure you want to delete this card?"),
          content: const SingleChildScrollView(
              child: Text("This action cannot be undone.")
          ),
          actions: [
            TextButton(
              autofocus: true,
                onPressed: (){
              Navigator.of(context).pop();
            }, child: const Text("NO", style: TextStyle(fontWeight: FontWeight.bold),)),
            TextButton(onPressed: (){
              String name = _shorten(NotusDocument.fromJson(jsonDecode(args.card.front)).toPlainText());
              Data.instance.deleteFlashcard(args.card.id);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Deleted $name')));
              Navigator.popUntil(context, ModalRoute.withName(LaunchDeck.routeName));
            }, child: Text("YES")),


          ],
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as CardEditScreenArguments;
    print(args.card?.front);
    isExistingCard = (args.card?.front != null && args.card?.front!="");

    args.card ??= Flashcard("", "", id: 1);

    if(isExistingCard){
      print("It is an existing card!");
      setState(() {
        _controller = ZefyrController(NotusDocument.fromJson(jsonDecode(args.card.front)));
        _controller2 = ZefyrController(NotusDocument.fromJson(jsonDecode(args.card.back)));
      });
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            (isExistingCard)? _decodeCardTitle(args.card) : args.card!.front,
            style: GoogleFonts.getFont('Open Sans'),
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
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
                , const Padding(
                  padding: EdgeInsets.fromLTRB(0,8,0,0),
                  child: Text("Front", style: TextStyle(
                      fontSize: 18.0, color: Colors.black, fontFamily: "Lexend")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ZefyrToolbar.basic(controller: _controller!, hideHeadingStyle: true,),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Container(decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: Colors.black)), child:
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ZefyrEditor(controller: _controller!,
                      ),
                  ))),
                ),
                SizedBox(height: 50,),
                const Text("Back", style: TextStyle(
                    fontSize: 18.0, color: Colors.black, fontFamily: "Open Sans")),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ZefyrToolbar.basic(controller: _controller2!, hideHeadingStyle: true),
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
                        print("Is it an existing card? $isExistingCard");
                        _saveDocument(context, isExistingCard);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.save),
                          SizedBox(width: 8,),
                          Text("Save", style: TextStyle(fontFamily: "Lexend"),),
                        ],
                      ),
                    ),
                  ),
                ),
                (isExistingCard)?Center(
                    child: Container(
                      width: 125,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey[400]!),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.white)
                        ),
                        onPressed: ()=>_showDeleteDialog(),
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
                ):Container()
              ],
            ),
          ),
        )
    );
  }

  void _saveDocument(BuildContext context, bool isExistingCard) async {
    final contents = jsonEncode(_controller!.document);
    final contents2 = jsonEncode(_controller2!.document);

    if(!isExistingCard) {
      await Data.instance.createFlashcard(
          Flashcard(contents, contents2, deckID: args.selectedDeckID));
    }else{
      args.card.front = contents;
      args.card.back = contents2;
      args.card.deckID = args.selectedDeckID;
      await Data.instance.updateFlashcard(args.card);
    }

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

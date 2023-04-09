import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:card_flow/card_edit_screen.dart';
import 'package:card_flow/image_card_view_screen.dart';
import 'package:card_flow/image_to_fcard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zefyrka/zefyrka.dart';
import 'deck_data.dart';
import 'learn.dart';

class LaunchDeck extends StatefulWidget {

  static const routeName = '/launch_deck';

  const LaunchDeck({super.key});


  @override
  State<LaunchDeck> createState() => _LaunchDeckState();
}

class _LaunchDeckState extends State<LaunchDeck> {
  late List<Flashcard> cards;
  bool isLoading = false;

  var args;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as Deck;
    refreshCards();
  }





  Future refreshCards() async{
    setState((){
      isLoading = true;
    });
    cards = await args.getCards();

    setState(() => isLoading = false);
  }




  @override
  Widget build(BuildContext context) {



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          args.name,
          style: const TextStyle(fontFamily: 'Lexend'),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () async{
              if(!mounted) return;
              final value = await Navigator.pushNamed(context, CardEdit.routeName, arguments: CardEditScreenArguments(selectedDeckID: args.id!));
              setState(() {refreshCards(); print("called btn1");});
            },
            child: Icon(Icons.add),
        ),
          const SizedBox(height: 8),

          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () async{
              final cameras = await availableCameras();

              final firstCamera = cameras.first;
              if(!mounted) return;
              final value = await Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageCardScreen(camera: firstCamera, deck: args)));
              setState(() {refreshCards(); print("called btn2");});
            },
            child: Icon(Icons.camera),
          )
        ]
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0,24.0,0,0),
                child: RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            fontSize: 26.0, color: Colors.black, fontFamily: "Lexend"),
                        children: [
                      TextSpan(
                          text: '${args.cardsDue} ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'Cards Due')
                    ]))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: OutlinedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Learn(deck: args)));
              }, child: Text("Start Studying", style: TextStyle(fontFamily: "Lexend"),)),
            ),
            Expanded(
              child: Material(
                color: Colors.white,
                child: isLoading ? const Center(child: CircularProgressIndicator()): cardList()
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget cardList(){
    if(cards!=null){ ///potential issues could occur if deck.cards changes
      return Container(
        decoration: const BoxDecoration(border: Border(top:BorderSide(width: 1.0, color: Colors.black))),
        child: ListView.builder(itemCount: cards.length,itemBuilder: (context, index){
          if(cards[index]!=null) {
            String front = (cards[index].isImage==null ||(cards[index].isImage!=null && cards[index].isImage==false))? _shorten(NotusDocument.fromJson(jsonDecode(cards[index].front)).toPlainText())
            : "Image";//decodes Notus Document stored through JSON in SQL database
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 18.0),
              shape: const ContinuousRectangleBorder(side: BorderSide(
                  color: Colors.black12, width: 1)),
              leading: const Image(image: AssetImage(
                  'assets/card_icon.png')),
              title: (cards[index].isImage==null ||(cards[index].isImage!=null && cards[index].isImage==false))?
              Text(front):
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 50,
                    height: 50,
                    child: Image.memory(base64Decode(cards[index].front)) //TODO load the image in a lower resolution
                ),
              ),
              onTap: (cards[index].isImage==null ||(cards[index].isImage!=null && cards[index].isImage==false))?
              () async {
                await Navigator.pushNamed(context, CardEdit.routeName, arguments: CardEditScreenArguments(selectedDeckID: args.id!, card: cards[index]));
                setState(() {
                  refreshCards();
                });
              }:
                  ()async {
                    await Navigator.pushNamed(context, ImageCardViewScreen.routeName, arguments: cards[index]);
                    setState(() {
                      refreshCards();
                    });
                  }
            );
          }else{
            return Container();
          }
        }),
      );
    }else{
      return Text("No cards yet");
    }
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


}




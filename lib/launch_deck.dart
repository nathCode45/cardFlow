import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:card_flow/card_edit_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zefyrka/zefyrka.dart';
import 'deck_data.dart';
import 'learn.dart';

class LaunchDeck extends StatefulWidget {
  const LaunchDeck({super.key, required this.deck});

  final Deck deck;

  @override
  State<LaunchDeck> createState() => _LaunchDeckState();
}

class _LaunchDeckState extends State<LaunchDeck> {
  late List<Flashcard> cards;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshCards();
  }



  Future refreshCards() async{
    setState((){
      isLoading = true;
    });
    cards = await widget.deck.getCards();

    setState(() => isLoading = false);
  }

  void launchCardCameraScreen() async{
    final cameras = await availableCameras();

    final firstCamera = cameras.first;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.deck.name,
          style: const TextStyle(fontFamily: 'Lexend'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final value = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CardEdit(selectedDeckID: widget.deck.id,)));
          setState(() {refreshCards();});
        },
        child: Icon(Icons.add),
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
                          text: '${widget.deck.cardsDue} ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: 'Cards Due')
                    ]))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: OutlinedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Learn(deck: widget.deck)));
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
            String front = _shorten(NotusDocument.fromJson(jsonDecode(cards[index].front)).toPlainText());//decodes Notus Document stored through JSON in SQL database
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 18.0),
              shape: const ContinuousRectangleBorder(side: BorderSide(
                  color: Colors.black12, width: 1)),
              leading: const Image(image: AssetImage(
                  'assets/card_icon.png')),
              title: Text(front),
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




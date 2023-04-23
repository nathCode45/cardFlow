import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:card_flow/card_edit_screen.dart';
import 'package:card_flow/image_card_view_screen.dart';
import 'package:card_flow/image_to_fcard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late Deck args;
  late int cardsDue;

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


  Future<void> _showDeleteDialog() async{
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Are you sure you want to delete this deck?", style: GoogleFonts.openSans(),),
            content: SingleChildScrollView(
                child: Text("This action cannot be undone.", style: GoogleFonts.openSans(),)
            ),
            actions: [
              TextButton(
                  autofocus: true,
                  onPressed: (){
                    Navigator.of(context).pop();
                  }, child:  Text("NO", style:GoogleFonts.openSans(fontWeight: FontWeight.bold))),
              TextButton(onPressed: () async{

                List<Flashcard> cards = await args.getCards();
                for(int i = 0; i<cards.length; i++){
                  Data.instance.deleteFlashcard(cards[i].id!);
                }

                Data.instance.deleteDeck(args.id!);

                if(mounted){
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Deleted ${args.name}')));

                  Navigator.popUntil(context, ModalRoute.withName('/'));
                }
              }, child: const Text("YES")),


            ],
          );
        }
    );
  }





  Future refreshCards() async{
    setState((){
      isLoading = true;
    });
    cards = await args.getCards();
    List<int> dueList = await args.getCardsDueIDs();
    cardsDue = dueList.length;

    setState(() => isLoading = false);
  }




  @override
  Widget build(BuildContext context) {



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed:() async{
            _showDeleteDialog();
          }
          )
        ],
        title: Text(
          args.name,
          style: GoogleFonts.openSans(),
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
              setState(() {refreshCards();});
            },
            child: const Icon(Icons.add),
        ),
          const SizedBox(height: 8),

          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () async{
              final cameras = await availableCameras();

              final firstCamera = cameras.first;
              if(!mounted) return;
              final value = await Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageCardScreen(camera: firstCamera, deck: args)));
              setState(() {refreshCards();});
            },
            child: const Icon(Icons.camera_alt),
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
                        style: GoogleFonts.openSans(
                            fontSize: 26.0, color: Colors.black),
                        children: [
                      TextSpan(
                          text: (isLoading)?"":'$cardsDue ',
                          style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Cards Due', style: GoogleFonts.openSans())
                    ]))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: CupertinoButton(onPressed: () async {

                if(cards.isNotEmpty){
                  final value = await Navigator.push(context, MaterialPageRoute(builder: (context) => Learn(deck: args)));
                  setState(() {
                    refreshCards();
                  });
                }else{
                  //TODO actually wait nvm it should open and then give them the option to skip to the next review
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('No cards have been created in this deck yet. ', style: GoogleFonts.openSans(),)));
                }

              }, child: Text("Start Studying", style: GoogleFonts.openSans(),)),
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
        child: RefreshIndicator(
          onRefresh: () async{
            refreshCards();
          },
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
                Text(front, style: GoogleFonts.openSans(),):
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 45,
                      height: 45,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(base64Decode(cards[index].front), fit: BoxFit.cover,)) //TODO load the image in a lower resolution
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
        ),
      );
    }else{
      return Text("No cards yet", style: GoogleFonts.openSans(),);
    }
  }

  String _shorten(String str){
    const int CHARACTER_LIMIT = 30;
    String singleLine = str.replaceAll("\n", " ");
    if (singleLine.length>CHARACTER_LIMIT){
      return '${singleLine.substring(0, CHARACTER_LIMIT)}...';
    }else{
      return singleLine;
    }

  }


}




import 'dart:convert';

import 'package:card_flow/deck_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'launch_deck.dart';

class ImageCardViewScreen extends StatefulWidget {
  const ImageCardViewScreen({Key? key}) : super(key: key);

  static const routeName = "/image_view";

  @override
  State<ImageCardViewScreen> createState() => _ImageCardViewScreenState();
}

class _ImageCardViewScreenState extends State<ImageCardViewScreen> {
  late Flashcard flashcard;

  Widget cardSide(String side){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
      ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child:
        Stack(
          children: [
            Center(
              child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF000000),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(15),
                //   color: const Color(0xFF000000),
                //   border: Border.all(color: Colors.black26, width: 2),
                // ),
              child: InteractiveViewer(
                maxScale: 10,
                minScale: 0.1,
                //boundaryMargin: const EdgeInsets.all(double.infinity),
                //clipBehavior: Clip.none,
                //constrained: true,
                child: Image.memory(
                  base64Decode(side),
                  //fit: BoxFit.cover,//BoxFit.fitHeight,
                ),
              ),
          ),
            ),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: const Icon(Icons.pinch, color: Color(0xCCffffff),)
                ),
              )
          )
          ]
        ),
      )

    );
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
                Data.instance.deleteFlashcard(flashcard.id!);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Deleted card')));
                Navigator.popUntil(context, ModalRoute.withName(LaunchDeck.routeName));
              }, child: const Text("YES")),


            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    flashcard = ModalRoute.of(context)!.settings.arguments as Flashcard;

    return Scaffold(
      appBar: AppBar(actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.grey[700]!),
                foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white)
            ),
            onPressed: (){
              _showDeleteDialog();
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete),
                const SizedBox(width: 8,),
                Text("Delete", style: GoogleFonts.openSans(),),
              ],
            ),
          ),
        ),
      ],),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Front", style: GoogleFonts.openSans(
                  fontSize: 24.0,
                  color: Colors.black)),
            ),
            Expanded(
              child: cardSide(flashcard.front)
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Back", style: GoogleFonts.openSans(
                  fontSize: 24.0,
                  color: Colors.black)),
            ),
            Expanded(
                child: cardSide(flashcard.back)
            )
          ],
        ),
      ),
    );
  }
}

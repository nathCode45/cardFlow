import 'dart:convert';

import 'package:card_flow/deck_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFF000000),
          border: Border.all(color: Colors.black26, width: 2),
        ),
        child: Center(
            child: InteractiveViewer(
              maxScale: 10,
              clipBehavior: Clip.none,
              child: Image.memory(
                  base64Decode(side),
                  fit: BoxFit.fitWidth,
              ),
            )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    flashcard = ModalRoute.of(context)!.settings.arguments as Flashcard;

    return Scaffold(
      appBar: AppBar(actions: [
        Padding(
          padding: EdgeInsets.all(8),
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.grey[700]!),
                foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white)
            ),
            onPressed: (){},
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
        ),
      ],),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: cardSide(flashcard.front)
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

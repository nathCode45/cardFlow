import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_painter/image_painter.dart';
//import 'package:card_flow/flutter_image_painter_fork/lib/image_painter.dart'; //TODO this package should be deleted entirely from your project eventually because it gets it from github instead

import 'package:path_provider/path_provider.dart';


import 'deck_data.dart';
import 'launch_deck.dart';

class DispAndMaskScreen extends StatefulWidget {
  final String baseImagePath;
  final Deck deck;

  const DispAndMaskScreen({Key? key, required this.baseImagePath, required this.deck}) : super(key: key);

  @override
  State<DispAndMaskScreen> createState() => _DispAndMaskState();
}

class _DispAndMaskState extends State<DispAndMaskScreen> {

  final _imageKey = GlobalKey<ImagePainterState>();
  final _key = GlobalKey<ScaffoldState>();
  late final Uint8List baseImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void saveImage() async{
    final image = await _imageKey.currentState?.exportImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath =
        '$directory/sample/${DateTime.now().millisecondsSinceEpoch}.png';
    final imgFile = File('$fullPath');
    imgFile.writeAsBytesSync(image!);
    String finalImage = base64Encode(imgFile.readAsBytesSync());
    String baseImage = base64Encode(File(widget.baseImagePath).readAsBytesSync());
    await Data.instance.createFlashcard(Flashcard(finalImage,baseImage, isImage: true, deckID: widget.deck.id));

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Saved.')));


  }

  Future<void> _showExitDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to quit?'),
          content: const SingleChildScrollView(
              child: Text("If you exit, you will lose your progress and your card will not be saved.")
          ),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              child: const Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                onPressed: (){
                  Navigator.popUntil(context, ModalRoute.withName(LaunchDeck.routeName));

                },
                child: const Text("YES")
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: ()=>_showExitDialog()
          ,),
        actions: [
          //IconButton(onPressed: (){saveImage();}, icon: const Icon(Icons.save))
        ],
      ), //TODO make this so that
      //Todo ...it warns if not saved
      body:
          // ImagePainter.asset(
          //   widget.baseImagePath,
          //   controlsAtTop: true,
          //   scalable: true,
          //   key: _imageKey,
          //   //height: 500, //TODO make this a size that will work for every screen
          //   width: MediaQuery.of(context).size.width,
          //   brushIcon: const Icon(Icons.brush_outlined),
          //   undoIcon: const Icon(Icons.undo),
          //   clearAllIcon: const Icon(Icons.clear_all_outlined),
          //   initialPaintMode: PaintMode.freeStyle,
          //   initialStrokeWidth: 30,
          //   initialColor: Colors.blueAccent,
          // ),

      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 3,
            child: ImagePainter.asset(
              widget.baseImagePath,
              controlsAtTop: true,
              scalable: true,
              key: _imageKey,
              //height: 500, //TODO make this a size that will work for every screen
              width: MediaQuery.of(context).size.width,
              brushIcon: const Icon(Icons.brush_outlined),
              undoIcon: const Icon(Icons.undo),
              clearAllIcon: const Icon(Icons.clear_all_sharp),
              initialPaintMode: PaintMode.freeStyle,
              initialStrokeWidth: 30,
              initialColor: Colors.blueAccent,
            ),
          ),
          Flexible(
            child: Container(
              alignment: Alignment.center,
                child: SizedBox(
                    child: TextButton(onPressed: (){
                      saveImage();
                    }, child: Text("Save"))
                )
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool isNewEdits = false;
  int numClears = 0;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //isNewEdits = false;
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
    print('front: $finalImage');
    print('back: $baseImage');
    await Data.instance.createFlashcard(Flashcard(finalImage,baseImage, isImage: true, deckID: widget.deck.id));

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Saved.', style: GoogleFonts.openSans(),)));


  }

  Future<void> _showExitDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to quit?', style: GoogleFonts.openSans(),),
          content: SingleChildScrollView(
              child: Text("If you exit, you will lose your progress and your card will not be saved.", style: GoogleFonts.openSans(),)
          ),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              child: Text('NO', style: GoogleFonts.openSans(),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                onPressed: (){
                 // Navigator.popUntil(context, ModalRoute.withName(LaunchDeck.routeName));
                  Navigator.pushNamedAndRemoveUntil(context, LaunchDeck.routeName, ModalRoute.withName('/'), arguments: widget.deck);


                },
                child: Text("YES", style: GoogleFonts.openSans(),)
            ),
          ],
        );
      },
    );
  }

  void newEdit(){
    isNewEdits = true;
  }






  @override
  Widget build(BuildContext context) {
    ImagePainter currentPainter = ImagePainter.asset(
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
        onEdit: (){isNewEdits = true; print("NEW EDIT $isNewEdits");},
        clearedID: 0
    );
    return Scaffold(
      key: _key,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(4,0,0,0),
          child: TextButton(child: Text("Done", style: GoogleFonts.openSans(color: Colors.white),),
            onPressed: ()=>Navigator.pushNamedAndRemoveUntil(context, LaunchDeck.routeName, ModalRoute.withName('/'), arguments: widget.deck)),
        ),
          // onPressed: (){
          // (isNewEdits)?
          //   _showExitDialog():
          //   Navigator.pushNamedAndRemoveUntil(context, LaunchDeck.routeName, ModalRoute.withName('/'), arguments: widget.deck);
          // }),
        actions: [
          //IconButton(onPressed: (){saveImage();}, icon: const Icon(Icons.save))
        ],
      ), //TODO make this so that
      //Todo ...it warns if not saved
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 4,
            child: currentPainter
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(textAlign: TextAlign.center,"Mask out the part of the image you want to hide until you flip the flashcard", style: GoogleFonts.openSans(),),
          ),
          Flexible(
            child: Container(
              alignment: Alignment.center,
                child: SizedBox(
                    child: ElevatedButton.icon(
                      onPressed: (){
                      setState(() {
                        saveImage();

                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DispAndMaskScreen(baseImagePath: widget.baseImagePath, deck: widget.deck)));

                        // isNewEdits = false;
                        // numClears++; ///increase the numClears so that a cleared image painter is constructed
                        // currentPainter.createState();
                      });
                    }, icon: const Icon(Icons.add),
                    label: Text("Create New Card", style: GoogleFonts.openSans(),))
                )
            ),
          )
        ],
      ),
    );

  }
}

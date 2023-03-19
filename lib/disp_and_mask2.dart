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

class DispAndMaskScreen extends StatefulWidget {
  final String baseImagePath;
  const DispAndMaskScreen({Key? key, required this.baseImagePath}) : super(key: key);

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
    await Data.instance.createFlashcard(Flashcard(finalImage,baseImage));
    //TODO add isImage property to flashcard and database and then make it so that learn screen can display image (or maybe just make sure
    //the paint works first

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Saved.')));


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: ()=>Navigator.pop(context),),), //TODO make this so that
      //Todo ...it warns if not saved
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              width: double.infinity,
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
          ),
          Expanded( flex: 1,
              child: TextButton(onPressed: (){}, child: Text("Save")))
        ],
      ),
    );
  }
}

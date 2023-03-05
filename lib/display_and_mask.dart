import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MaskImageScreen extends StatefulWidget {
  final String imagePath;
  const MaskImageScreen({super.key, required this.imagePath});

  @override
  State<MaskImageScreen> createState() => _MaskImageScreenState();
}

class _MaskImageScreenState extends State<MaskImageScreen> {
  late ui.Image image;
  bool isImageLoaded = false;
  GlobalKey _myCanvasKey = new GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  Future init() async{
    final ByteData data = await rootBundle.load(widget.imagePath);
    image = await loadImage(Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    ImageEditor editor = ImageEditor(image: image);
    if (isImageLoaded) {
      return GestureDetector(
        onPanDown: (detailData) {
          editor.update(detailData.localPosition);
          _myCanvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
        },
        onPanUpdate: (detailData) {
          editor.update(detailData.localPosition);
          _myCanvasKey.currentContext?.findRenderObject()?.markNeedsPaint();
        },
        child: FittedBox(
          child: SizedBox(
            width: image.width.toDouble(),
            height: image.height.toDouble(),

            child: CustomPaint(
              size: Size.infinite,
              key: _myCanvasKey,
              painter: editor,
            ),
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mask your image")),
      body: (isImageLoaded)? _buildImage() : const Center(child: CircularProgressIndicator())//Image.file(File(widget.imagePath)),
    );
  }

}

class ImageEditor extends CustomPainter {

  ImageEditor({
    required this.image,
  });

  ui.Image image;

  List<Offset> points= [];

  final Paint painter = new Paint()
    ..color = Colors.blue[400]!
    ..style = PaintingStyle.fill;

  void update(Offset offset){
    points.add(offset);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image,  const Offset(0.0, 0.0),  Paint());
    for(Offset offset in points){
      canvas.drawCircle(offset, 10, painter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }




}

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//TODO WARNING:

class ImageCardScreen extends StatefulWidget {

  final CameraDescription camera;

  const ImageCardScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<ImageCardScreen> createState() => _ImageCardScreenState();
}

class _ImageCardScreenState extends State<ImageCardScreen> {

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium
    );

    _initializeControllerFuture = _controller.initialize();

  }

  @override
  void dispose() {
    // TODO: implement dispose

    _controller.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot){

        },
      ),
    );
  }
}

import 'dart:convert';

import 'dart:io' as Io;
import 'package:camera/camera.dart';
import 'package:card_flow/disp_and_mask2.dart';
import 'package:card_flow/display_and_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'deck_data.dart';
//TODO WARNING:

class ImageCardScreen extends StatefulWidget {
  final CameraDescription camera;
  final Deck deck;

  const ImageCardScreen({Key? key, required this.camera, required this.deck}) : super(key: key);

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

    _controller = CameraController(widget.camera, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.yuv420);

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
    List<Widget> _camChildren (bool portrait){
      return[
        (portrait)?const SizedBox(height: 0,):
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children: [SizedBox(height: 8,),IconButton(onPressed: ()=>Navigator.of(context).pop(), icon: Icon(Icons.arrow_back_ios_new, color: Colors.white,))]
        ),

        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;

                    final image = await _controller.takePicture();

                    if (!mounted) return;
                    await Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => DispAndMaskScreen(
                          baseImagePath: image.path,
                          deck: widget.deck,
                        )));
                  } catch (e) {
                    print(e);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder()
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    size: 32 ,
                    Icons.camera_alt,
                    color: Colors.black,
                  ),
                ),
              ),
            )
        )
      ];
    }


    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return
          Scaffold(
            backgroundColor: Colors.black12,
            appBar: (orientation==Orientation.portrait)?AppBar(backgroundColor: Colors.black12,):null,
            body: (orientation==Orientation.portrait)?
            SafeArea(
              child: Column(
                children: _camChildren(true)
              ),
            ):SafeArea(child: Row(
                children: _camChildren(false)
            )),
          );
        },
    );


  }
}

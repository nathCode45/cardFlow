


import 'package:camera/camera.dart';
import 'package:card_flow/disp_and_mask2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';


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

    _controller = CameraController(widget.camera, ResolutionPreset.high, imageFormatGroup: ImageFormatGroup.yuv420);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _controller.dispose();

    super.dispose();
  }

  // Future<String> _resizePhoto(String filePath) async {
  //   ImageProperties properties =
  //   await FlutterNativeImage.getImageProperties(filePath);
  //
  //   int width = properties.width;
  //   var offset = (properties.height - properties.width) / 2;
  //
  //   File croppedFile = await FlutterNativeImage.cropImage(
  //       filePath, 0, offset.round(), width, width);
  //
  //   return croppedFile.path;
  // }



  @override
  Widget build(BuildContext context) {
    List<Widget> _camChildren (bool portrait){
      return[
        (portrait)?const SizedBox(height: 0,):
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
            children: [const SizedBox(height: 8,),IconButton(onPressed: ()=>Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,))]
        ),

        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            double sizeBy = (portrait)? MediaQuery.of(context).size.width: MediaQuery.of(context).size.height;
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [FittedBox(
                      fit: (portrait)?BoxFit.fitWidth: BoxFit.fitHeight,
                      child: Container(
                      width: sizeBy,
                      child: CameraPreview(_controller)
                      )),
                  Container(
                    color: const Color(0xCC000000),
                    width: double.infinity,
                    height: 150,
                    child:
                    Center(
                      child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await _initializeControllerFuture;
                                _controller;

                                final image = await _controller.takePicture();


                                CroppedFile? croppedFile = await ImageCropper().cropImage(
                                  sourcePath: image.path,
                                  aspectRatioPresets: [
                                    CropAspectRatioPreset.square,
                                    CropAspectRatioPreset.ratio3x2,
                                    CropAspectRatioPreset.original,
                                    CropAspectRatioPreset.ratio4x3,
                                    CropAspectRatioPreset.ratio16x9
                                  ],
                                  uiSettings: [
                                    AndroidUiSettings(
                                        toolbarTitle: 'Crop/Adjust your image',
                                        toolbarColor: Colors.deepOrange,
                                        toolbarWidgetColor: Colors.white,
                                        initAspectRatio: CropAspectRatioPreset.original,
                                        lockAspectRatio: false),
                                    IOSUiSettings(
                                      title: 'Crop your image',
                                    ),
                                  ],
                                );


                                String path = "";



                                if (!mounted) return;
                                if(croppedFile!=null){
                                  path = croppedFile.path;
                                  await Navigator.of(context).pushReplacement(MaterialPageRoute(
                                      builder: (context) => DispAndMaskScreen(
                                        baseImagePath: path,
                                        deck: widget.deck,
                                      )));
                                }

                              } catch (e) {
                                //print(e);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: const CircleBorder()
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Icon(
                                size: 32,
                                Icons.camera_alt,
                                color: Colors.black,
                              ),
                            ),
                          ),
                    ),
                      ),
                    ]);

            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),

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

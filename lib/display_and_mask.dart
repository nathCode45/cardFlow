import 'dart:io';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mask your image")),
      body: Image.file(File(widget.imagePath)),
    );
  }
}

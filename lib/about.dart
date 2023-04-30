import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(style: GoogleFonts.openSans(), "About"),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(style: GoogleFonts.openSans(),"CardFlow is an app that allows users to create and study flashcards. Users can create flashcards either through a rich text editor with both front/back and fill-in-the-blank options or by taking a picture of handwritten notes and masking out parts of the picture to occlude in the flashcard. Cards are studied using a spaced repetition schedule based on user feedback given through a slider scale after each repetition. This creates a more personalized and efficient study experience. "),
            const SizedBox(height: 8,),
            Text(style: GoogleFonts.openSans(), "You can contact the developer at cardflowdeveloper@gmail.com")
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart';

import 'deck_data.dart';

class Learn extends StatefulWidget {
  const Learn({super.key, required this.deck});

  final Deck deck;

  @override
  State<Learn> createState() => _LearnState();
}

class _LearnState extends State<Learn> {
  late List<Flashcard> cards;
  bool isLoading = false;
  ZefyrController? _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshCards();


  }

  Future<NotusDocument> _loadDocument(String str) async{
    return NotusDocument.fromJson(jsonDecode(str));
  }



  Future refreshCards() async{
    setState((){
      isLoading = true;
    });
    cards = await widget.deck.getCards();
    _loadDocument(cards[0].front).then((document){
      setState(() {
        _controller = ZefyrController(document);
      });
    });
    setState(() => isLoading = false);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "${widget.deck.name} | Learn",
          style: const TextStyle(fontFamily: 'Lexend'),
        ),
      ),
      body: Center(child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  border: Border.all(color: Colors.black26, width: 2),
                ),
                child: Center(
                  child: (_controller == null) ?
                  const Center(child: CircularProgressIndicator(),)
                      :ZefyrEditor(controller: _controller!, readOnly: true, padding: const EdgeInsets.all(16),),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: (){},
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.black12, width: 2.0)
                      )
                    )
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Reveal"),
                  ),
              ),
            )
          ],
        )

      ),
    );
  }
}

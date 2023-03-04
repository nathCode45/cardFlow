import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart';
import 'custom_widgets/slider_widget.dart';

import 'deck_data.dart';

class Learn extends StatefulWidget {
  const Learn({super.key, required this.deck});

  final Deck deck;

  @override
  State<Learn> createState() => _LearnState();
}

class _LearnState extends State<Learn> {
  late List<Flashcard> cards;
  bool reveal = false;
  bool isLoading = false;
  late ZefyrController? _controllerFront = ZefyrController();
  late ZefyrController? _controllerBack = ZefyrController();
  double _diffFactor = 1;
  double _slideFactor = 0.5;
  int _correctIndex = 0;


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
        _controllerFront = ZefyrController(document);
      });
    });
    setState(() => isLoading = false);
  }



  // String _getDifficultyLabel(int difficulty){
  //   switch(difficulty){
  //     case 0:
  //       return ""
  //   }
  // }

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
          mainAxisAlignment: MainAxisAlignment.start,
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
                  child: (_controllerFront == null) ?
                  const Center(child: CircularProgressIndicator(),)
                      : ZefyrEditor(controller: _controllerFront!, readOnly: true, padding: const EdgeInsets.all(16), showCursor: false,),
                ),
              ),
            ),
            (reveal) ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  border: Border.all(color: Colors.black26, width: 2),
                ),
                child: Center(
                  child: (_controllerBack == null) ?
                  const Center(child: CircularProgressIndicator(),)
                      : ZefyrEditor(controller: _controllerBack!, readOnly: true, padding: const EdgeInsets.all(16), showCursor: false,),
                ),
              ),
            ): const SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: (){
                    setState((){
                      reveal = !reveal;
                    });
                    if(reveal) {
                      setState(() {
                        isLoading = true;
                      });
                      _loadDocument(cards[0].back).then((document) {
                        setState(() {
                          _controllerBack = ZefyrController(document);
                        });
                      });
                      setState(() => isLoading = false);
                    }
                  },
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
                    child: Text("Flip"),
                  ),
              ),
            ),
            (reveal)? Column(
              children: [
                // const Padding(
                //   padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
                //   child: Text("Difficulty", style: TextStyle(
                //     fontSize: 24
                //   ),),
                // ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,8,16,8),
                  child: SliderWidget(card: cards[0], onSliderChanged: (double value){_diffFactor = value;}),
                ),
                // Container(
                //   decoration: const BoxDecoration(
                //     gradient: LinearGradient(colors: [Color.fromARGB(255, 29, 221, 163), Colors.green])
                //   ),
                //   child: Slider(
                //     value: _slideFactor,
                //     min: 0,
                //     max: 2,
                //     onChanged: (double value) {
                //       setState(() {
                //         _slideFactor = value;
                //         _diffFactor = _correctIndex*3+_slideFactor;
                //       });
                //       },
                //     divisions: 6,
                //     label: "Next repetition: ${cards[0].reviewInterval(_diffFactor, cards[0].repetitions).inMinutes} minutes",
                //   ),
                // ),
                /*TODO left off with this idea: make grading scale not non-discrete (doubles not just 0-5)
                   there will be two factors influencing the grading: time to answer and difficulty rating
                   time to answer will have the greatest impact on grading but difficulty rating will also have a 35% effect or sum like that
                   This approach makes sense because some cards may have a long prompt at the front but they are still easy for the user to
                   guess, so looking at the time to guess alone would be misleading, therefore it will take both time and diff rating into account
                */
                /*
                  updated TODO i think we should actually go for the one slider approach instead with a red wrong section and a green right section
                  use this: https://medium.com/flutter-community/flutter-sliders-demystified-4b3ea65879c to help make it
                 */
              ],

            ): Container(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: ((){
                setState(() {
                  cards[0].updateRepetitions(_diffFactor);
                  if(_diffFactor>=3) {
                    cards[0].eFactor = cards[0].getUpdatedEFactor(_diffFactor);
                    print("Updated eFactor: ${cards[0].getUpdatedEFactor(_diffFactor)}");
                  }
                });

              }), child: Icon(Icons.arrow_forward_ios_sharp)),
            )
          ],
        )

      ),
    );
  }
}

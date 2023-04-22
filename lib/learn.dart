import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late Flashcard? currentCard;
  bool reveal = false;
  bool isLoading = false;
  bool isCardsDue = false;
  bool isImage = false;
  Duration skipBuffer = Duration.zero;
  Timer? _timer;

  late ZefyrController? _controllerFront = ZefyrController();
  late ZefyrController? _controllerBack = ZefyrController();
  double _diffFactor = 0;

  DateTime _getWhenNext(){
    DateTime nearest = cards[0].nextReview;
    for(int i = 0; i<cards.length; i++){
      if(cards[i].nextReview.compareTo(nearest) < 0){
        nearest = cards[i].nextReview;
      }
    }
    return nearest;
  }



  Future<Flashcard?> getLearnCard() async {
    int nearest = 0;

    //List<int> dueListIDs = []; //list of ids instead of entire cards, in order to save space

    // for(int i = 0; i<cards.length; i++){
    //   if(cards[i].nextReview.compareTo(DateTime.now()) < 0){
    //     dueListIDs.add(cards[i].id!);
    //     print("${cards[i].front} added to Due List");
    //   }
    // }

    List<int> dueListIDs = await widget.deck.getCardsDueIDs(skipBuffer: skipBuffer);
    skipBuffer = Duration.zero;

    if(dueListIDs.isNotEmpty) {
      for (int i = 0; i < dueListIDs.length; i++) {
        for (int j = 0; j < cards.length; j++) {
          if (cards[j].id == dueListIDs[i] &&
              cards[j].nextReview.compareTo(cards[nearest].nextReview) < 0) {
            nearest = j;
          }
        }
      }
      return cards[nearest];
    }else{
      return null;
    }



  }


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

    currentCard = await getLearnCard();

    if(currentCard==null){
      setState(() {
        isCardsDue = false;
      });
    }else{
      Flashcard finalCard = currentCard!;
      if(finalCard.isImage){
        isImage = true;
      }else{
        isImage =false;
        _loadDocument(currentCard!.front).then((document){
          setState(() {
            _controllerFront = ZefyrController(document);
          });
        });

        _loadDocument(currentCard!.back).then(
                (document){
              setState(() {
                _controllerBack = ZefyrController(document);
              });
            }
        );
      }


      setState(() {
        isCardsDue = true;
      });

    }

    setState(() => isLoading = false);

  }

  void startTimer(){
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(_getWhenNext().difference(DateTime.now()).inSeconds<=0){
        timer.cancel();
        Timer(const Duration(milliseconds: 100), (){});//wait a small amount of time so that transition is smoother
        setState(() {
          refreshCards();
        });
      }else if(isCardsDue) {
        timer.cancel();
      }else {
          setState(() {});
      }
    });
  }

  Widget cardSide(String? side){
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child:
          Stack(
              children: [
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 500,
                    color: const Color(0xFF000000),
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(15),
                    //   color: const Color(0xFF000000),
                    //   border: Border.all(color: Colors.black26, width: 2),
                    // ),
                    child: InteractiveViewer(
                      maxScale: 10,
                      minScale: 0.1,
                      //boundaryMargin: const EdgeInsets.all(double.infinity),
                      //clipBehavior: Clip.none,
                      //constrained: true,
                      child: Image.memory(
                        base64Decode(side!),
                        //fit: BoxFit.cover,//BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(

                          child: Icon(Icons.pinch, color: Color(0xCCffffff),)
                      ),
                    )
                )
              ]
          ),
        )

    );
  }

  // Widget cardSide(String? side){
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Container(
  //       clipBehavior: Clip.hardEdge,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(15),
  //         color: const Color(0xFF000000),
  //         border: Border.all(color: Colors.black26, width: 2),
  //       ),
  //       child: Center(
  //           child: InteractiveViewer(
  //             maxScale: 10,
  //             clipBehavior: Clip.none,
  //             child: Image.memory(
  //               base64Decode(side!),
  //               fit: BoxFit.fitWidth,
  //             ),
  //           )
  //       ),
  //     ),
  //   );
  // }



  // String _getDifficultyLabel(int difficulty){
  //   switch(difficulty){
  //     case 0:
  //       return ""
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    _diffFactor = 0; //reset diff factor to zero because thats how the slider widget intiitalizes

    if(!isCardsDue && !isLoading && _getWhenNext().difference(DateTime.now()).inSeconds<120){
      startTimer();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "${widget.deck.name} | Learn",
          style: GoogleFonts.openSans(),
        ),
      ),
      body: (isCardsDue) ?
      Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Center(
                  child: (isImage && !isLoading)?
                      cardSide((reveal)?currentCard?.back:currentCard?.front)
                    :

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16,32,16,16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          border: Border.all(color: Colors.black26, width: 2),
                        ),
                        child: (_controllerFront == null) ?
                        const Center(child: CircularProgressIndicator(),)
                            : ZefyrEditor(controller: _controllerFront!, readOnly: true, padding: const EdgeInsets.all(16), showCursor: false,),
                      ),
                    ),
                ),
              ),
              (reveal && !isImage) ? Padding(
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
                        if(!isImage){
                          _loadDocument(currentCard!.back).then((document) {
                            setState(() {
                              _controllerBack = ZefyrController(document);
                            });
                          });
                        }

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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Flip", style: GoogleFonts.openSans(),),
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
                    child: SliderWidget(card: currentCard!, onSliderChanged: (double value){_diffFactor = value;}),
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

              (reveal)?Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: ((){
                  setState(() {

                    currentCard!.nextReview = DateTime.now().add(currentCard!.reviewInterval(_diffFactor, currentCard!.repetitions)); //schedule next review
                    //print("\n\n ${currentCard!.front.toString()} next review interval:${currentCard!.reviewInterval(_diffFactor, currentCard!.repetitions)} nextReview: ${currentCard!.nextReview}");

                    currentCard!.updateRepetitions(_diffFactor);


                    // if(_diffFactor>=3) {
                    //   currentCard!.eFactor = currentCard!.getUpdatedEFactor(_diffFactor);
                    //   //print("Updated eFactor: ${currentCard.getUpdatedEFactor(_diffFactor)}");
                    // }
                    currentCard!.eFactor = currentCard!.getUpdatedEFactor(_diffFactor);
                    //print("\neFactor:${currentCard!.eFactor} repetitions: ${currentCard!.repetitions}");


                    Data.instance.updateFlashcard(currentCard!);
                    Data.instance.createProgressRep(ProgressRep(dateTime: DateTime.now(), deckID: widget.deck.id!)); //record the progress

                    reveal = false;



                    refreshCards();
                  });

                }), child: Icon(Icons.arrow_forward_ios_sharp)),
              ):Container(),
              SizedBox(height: 100,)
            ],
          ),
        ),
      ):
      Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

              children: [
                (isLoading)? CircularProgressIndicator():Text("Next card due in: ${
                    SliderWidget.formattedTime(_getWhenNext().difference(DateTime.now()), seconds: true) //uses formatted time from slider widget
                }"),
                TextButton(onPressed: refreshCards, child: Text("Refresh", style: GoogleFonts.openSans(),)),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Text("Waiting betweeen repetitions enhances memory training, but if you're in a rush you can skip to the next review", textAlign: TextAlign.center, style: GoogleFonts.openSans(),),
                  ),
                ),
                TextButton.icon(onPressed: (){
                  skipBuffer = _getWhenNext().difference(DateTime.now());
                  setState(() {
                    refreshCards();
                  });
                }, icon: Icon(Icons.skip_next), label: Text("Skip", style: GoogleFonts.openSans(),),),

              ]
          )
      ) //if not isCardsDue
      ,
    );
  }
}

import 'dart:math';

import 'package:card_flow/launch_deck.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:card_flow/deck_data.dart';
import 'package:google_fonts/google_fonts.dart';




class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const List months = ['Jan', 'February', 'March', "April", 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  bool isLoading = false;
  bool isProgressLoading = false;
  List<Deck> decks = [];
  List<int> cardsDueList = [];
  List<int> deckSizeList = [];
  late DateTime sunday;
  int streak = 0;
  int weeksBack = 0;
  late List<int> numProgressPastWeek = [0,0,0,0,0,0,0];

  final TextEditingController _addController = TextEditingController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
    refreshWeeklyProgress();
    refreshStreak();
  }

  @override
  void dispose() {
    Data.instance.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   // TODO: implement didChangeAppLifecycleState
  //   super.didChangeAppLifecycleState(state);
  //
  //   if(state == AppLifecycleState.detached){
  //     Data.instance.deleteAllDecks();
  //   }
  // }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future refreshWeeklyProgress() async{ //returns a list of integers of the number of progress reps from that week

    //DateTime sunday = getDate(DateTime.now().subtract(Duration(days: DateTime.now().weekday-1)));
    int dSubration;
    if(DateTime.now().weekday==DateTime.sunday){
      dSubration = 0;
    }else{
      dSubration = DateTime.now().weekday;
    }
    dSubration= dSubration + 7*weeksBack; //account for weeks back
    sunday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - dSubration);

    print('SUNDAY: $sunday');
    List<ProgressRep> weeklyProgressReps = await Data.instance.readProgress(sunday, sunday.add(const Duration(days: 6, hours: 24, minutes: 59, seconds: 59)));
    print('PROGRESS REPS: $weeklyProgressReps');

    numProgressPastWeek=[0,0,0,0,0,0,0]; //position 0 is sunday, position 6 is saturday
    for(ProgressRep rep in weeklyProgressReps){
      //datetime weekdays mondays are 1 and sundays are 7
      print("PROGRESS REP: weekday: ${rep.dateTime.weekday}, time: ${rep.dateTime}");
      if(rep.dateTime.weekday==DateTime.sunday){
        numProgressPastWeek[0]++;
      }else{
        numProgressPastWeek[rep.dateTime.weekday]++;
      }
    }
  }

  Future refreshStreak() async{
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    bool done = false;
    int i = -1;
    while(!done){
      //print("between: ${today.subtract(Duration(days: i+1))} and ${today.subtract(Duration(days: i)).subtract(Duration(milliseconds: 1))}");
      List<ProgressRep> progress = await Data.instance.readProgress(today.subtract(Duration(days: i+1)), today.subtract(Duration(days: i)).subtract(const Duration(milliseconds: 1)));
      //print("progress: $progress");
      if(progress.isEmpty){
        done = true;
      }else{
        i++;
      }
    }
    streak = i+1;
  }

  Future refresh() async {
    setState(() {
      isLoading = true;
    });

    try {
      decks = await Data.instance.readDecks();
    }catch(e){
      decks = [];
    }

    cardsDueList = [];
    deckSizeList = [];
    for(Deck d in decks){
      List<Flashcard> cardsList = await d.getCards();
      List<int> dueIDs = await d.getCardsDueIDs();
      cardsDueList.add(dueIDs.length);
      deckSizeList.add(cardsList.length);
    }

    setState(() => isLoading = false);
  }

  void dateBack(){
    setState(() {
      weeksBack++;
      refreshWeeklyProgress();
    });
  }
  void dateForward(){
    print(sunday);
    print(weeksBack);
    if(daysBetween(DateTime.now(), sunday)<=-7) {
      setState(() {
        weeksBack--;
        refreshWeeklyProgress();
      });
    }
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }


  Future<void> _showCreateDeckDialog(){

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context){
        return AlertDialog(
          title: Text("Create new deck", style: GoogleFonts.openSans(),),
          content: SingleChildScrollView(
            child:
            Column(
              children: [
                TextField(
                  onChanged: (value){

                  },
                  style: GoogleFonts.openSans(),
                  controller: _addController,
                  decoration: const InputDecoration(hintText: "Enter deck name here"),
                ),
                TextButton(onPressed: (){
                  String? retrieved = _addController.text;

                  if(retrieved!=""){
                    _addController.clear();
                    Deck newDeck = Deck(name: retrieved, dateCreated: DateTime.now());
                    Data.instance.createDeck(newDeck);
                    setState(() {
                      refresh();
                    });
                    Navigator.of(context).pop();
                  }else{
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Please enter a deck name')));
                  }


                }, child: Text("Create", style: GoogleFonts.openSans(),))
              ],
            ),
          )
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(onPressed: ()=>_showCreateDeckDialog(),child: const Icon(Icons.add),),
      body: Center(child:
      Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 75, 0, 0),
            child: Image(image: AssetImage('assets/cflow_logo.png')),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 16), child:
          (streak>0)?Text("🔥$streak", style: GoogleFonts.openSans(fontSize: 18),):Container(),
            ),
          const Text("",),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: Center(
                child: Text("${months[sunday.month-1]} ${sunday.day} - ${sunday.add(const Duration(days: 6)).day}",
                style: GoogleFonts.openSans(fontSize: 16),),
              )),
            ],
          )
          ,Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8,0,0,0),
                child:
                SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: (){
                      dateBack();
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onHorizontalDragEnd: (details){
                      int sensitivity = 3;
                      if (details.primaryVelocity! > sensitivity) {
                        // Right Swipe
                        dateBack();
                      } else if(details.primaryVelocity! < -sensitivity){
                        //Left Swipe
                        dateForward();
                      }
                    },
                    child:
                        AspectRatio(
                          aspectRatio: 1.6,
                          child: Card(elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            child: _BarChart(numWeeklyProgress: numProgressPastWeek, sunday: sunday,),),

                        ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,8,0),
                child:
                  SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: Icon(Icons.arrow_forward_ios, color: (daysBetween(DateTime.now(), sunday)<=-7)? Colors.black:Colors.grey[300],),
                    onPressed: (){
                      dateForward();
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Material(
                color: Colors.white,
                child:
                ((decks.isNotEmpty) ? (isLoading ? const Center(child: CircularProgressIndicator()) :deckListBuilder()):
                Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(textAlign: TextAlign.center, "No decks have been created yet. Tap the plus button to create a deck.", style: GoogleFonts.openSans(color: Colors.grey[500]),),
                )))
            ),
          ), //this will be to display the cards

        ],
      )
      ),
    );
  }

  Widget deckListBuilder() {
    return RefreshIndicator(
      onRefresh: () async{
        refresh();
        refreshStreak();
        refreshWeeklyProgress();
      },
      child:
      ListView.builder(
        padding: const EdgeInsets.fromLTRB(0,0,0,75),
        shrinkWrap: true,
          itemCount: decks.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () async {
                await Navigator.pushNamed(context, LaunchDeck.routeName, arguments: decks[index]);
                setState(() {
                  refresh();
                  refreshWeeklyProgress();
                  refreshStreak();
                });
              },
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 18.0),
              shape: const ContinuousRectangleBorder(
                  side: BorderSide(color: Colors.black12, width: 1)),
              leading: Stack(
                  children: <Widget>[
                    const Image(image: AssetImage('assets/deck_icon.png')),
                    Positioned(
                        bottom: 16,
                        right: 23,
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(deckSizeList[index].toString(), style: GoogleFonts.openSans(),),
                          ),
                        )
                    ),
                  ]
              ),
              trailing: (cardsDueList[index]>0)?Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)
                ),
              ):null,
              title: Text(decks[index].name, style: GoogleFonts.openSans(),),
            );
          }
      ),
    );
  }
}


class _BarChart extends StatelessWidget {
  List<int> numWeeklyProgress;
  DateTime sunday;
  _BarChart({Key? key, required this.numWeeklyProgress, required this.sunday}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
        BarChartData(
            titlesData: titlesData,
            barGroups: barGroups,
            gridData: FlGridData(show: true, horizontalInterval: 1, verticalInterval: 10),
            maxY: numWeeklyProgress.reduce(max).toDouble()+5-(numWeeklyProgress.reduce(max).toDouble()%5),
        )
    );


  }
  BarChartRodData getRod(double toY){
    return BarChartRodData(toY: toY, borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)), width: 20);
  }

  Widget getTitles(double value, TitleMeta meta){
    var textStyleBold = GoogleFonts.openSans(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
    );
    var textStyle = GoogleFonts.openSans(
      color: Colors.black,
      fontSize: 16,
    );

    String text;
    String date = "\n${sunday.day +value.toInt()}";

    switch(value.toInt()){
      case 0:
        text = "Sn";
        break;
      case 1:
        text = "Mn";
        break;
      case 2:
        text = 'Te';
        break;
      case 3:
        text = 'Wd';
        break;
      case 4:
        text = "Th";
        break;
      case 5:
        text = "Fr";
        break;
      case 6:
        text = "St";
        break;
      default:
        text = "";
        break;
    }


    return SideTitleWidget(axisSide: meta.axisSide, child:
    RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(text: text, style: textStyleBold),
          TextSpan(text: date,style: textStyle)
        ]
      ),

    )
    );
  }

  FlTitlesData get titlesData=>FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: getTitles
          )
      ),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))
  );

  List<BarChartGroupData>get barGroups => List.generate(7, (index) => BarChartGroupData(x: index, barRods: [getRod(numWeeklyProgress[index].toDouble())]));
}

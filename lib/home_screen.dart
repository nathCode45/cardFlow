import 'dart:math';

import 'package:card_flow/launch_deck.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:card_flow/deck_data.dart';




class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const List months = ['Jan', 'February', 'March', "April", 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  bool isLoading = false;
  bool isProgressLoading = false;
  late List<Deck> decks;
  List<int> cardsDueList = [];
  late DateTime sunday;
  int weeksBack = 0;
  late List<int> numProgressPastWeek = [0,0,0,0,0,0,0];

  AppLifecycleState? _lastLifecycleState;
  final TextEditingController _addController = TextEditingController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
    refreshWeeklyProgress();
  }

  @override
  void dispose() {
    Data.instance.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.detached){
      Data.instance.deleteAllDecks();
    }
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future refreshWeeklyProgress() async{ //returns a list of integers of the number of progress reps from that week
    print("refresh Weekly Progress Called!");
    //DateTime sunday = getDate(DateTime.now().subtract(Duration(days: DateTime.now().weekday-1)));
    int dSubration;
    if(DateTime.now().weekday==DateTime.sunday){
      dSubration = 0;
    }else{
      dSubration = DateTime.now().weekday+1;
    }
    dSubration= dSubration + 7*weeksBack; //account for weeks back
    sunday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - dSubration);
    print("sunday: ${sunday.toString()}");
    List<ProgressRep> weeklyProgressReps = await Data.instance.readProgress(sunday, sunday.add(const Duration(days: 6)));
    print("WEEKLY REPS: $weeklyProgressReps");
    numProgressPastWeek=[0,0,0,0,0,0,0]; //position 0 is sunday, position 6 is saturday
    for(ProgressRep rep in weeklyProgressReps){
      //datetime weekdays mondays are 1 and sundays are 7
      if(rep.dateTime.weekday==DateTime.sunday){
        numProgressPastWeek[0]++;
      }else{
        numProgressPastWeek[rep.dateTime.weekday]++;
      }
    }
  }

  Future refresh() async {
    setState(() {
      isLoading = true;
    });

    decks = await Data.instance.readDecks();

    cardsDueList = [];
    for(Deck d in decks){
      List<int> dueIDs = await d.getCardsDueIDs();
      cardsDueList.add(dueIDs.length);
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
    if(daysBetween(DateTime.now(), sunday)<0) {
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
          title: Text("Create new deck"),
          content: SingleChildScrollView(
            child:
            Column(
              children: [
                TextField(
                  onChanged: (value){

                  },
                  controller: _addController,
                  decoration: InputDecoration(hintText: "Enter deck name here"),
                ),
                TextButton(onPressed: (){
                  if(_addController?.text!=null){
                    String? retrieved = _addController?.text;
                    Deck newDeck = Deck(name: retrieved!, dateCreated: DateTime.now());
                    Data.instance.createDeck(newDeck);
                    setState(() {
                      refresh();
                    });
                    Navigator.of(context).pop();
                  }

                }, child: Text("Create"))
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
      floatingActionButton: FloatingActionButton(onPressed: ()=>_showCreateDeckDialog(),child: Icon(Icons.add),),
      body: Center(child:
      Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 75, 0, 0),
            child: Image(image: AssetImage('assets/cflow_logo.png')),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 16), child:
          Text("🔥12", style: TextStyle(fontSize: 18),)
            ,),
          const Text(""),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 8),
              //   child: SizedBox(
              //     width: 50,
              //     child: ElevatedButton(
              //     onPressed: (){
              //       dateBack();
              //     }, child: Center(child: Icon(Icons.arrow_back_ios, size: 15,))
              //     ),
              //   ),
              // ),
              Expanded(child: Center(
                child: Text("${months[sunday.month-1]} ${sunday.day} - ${sunday.add(Duration(days: 6)).day}",
                style: TextStyle(fontFamily: "Lexend", fontSize: 16),),
              )),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //   child: SizedBox(
              //     width: 50,
              //     child: ElevatedButton(onPressed: (){
              //       dateForward();
              //     }, child: Center(child: Icon(Icons.arrow_forward_ios, size: 15 ,)),
              //     ),
              //   ),
              // ),
            ],
          )
          ,Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8,0,0,0),
                child:
                SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    padding: EdgeInsets.all(0),
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
                padding: EdgeInsets.fromLTRB(0,0,8,0),
                child:
                  SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.arrow_forward_ios, color: (daysBetween(DateTime.now(), sunday)<0)? Colors.black:Colors.grey[300],),
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
                child: isLoading ? const Center(child: CircularProgressIndicator()) : deckListBuilder()
            ),
          ), //this will be to display the caards

        ],
      )
      ),
    );
  }

  Widget deckListBuilder() {
    return RefreshIndicator(
      onRefresh: ()=>refresh(),
      child:
      ListView.builder(
        padding: EdgeInsets.fromLTRB(0,0,0,75),
        shrinkWrap: true,
          itemCount: decks.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () async {
                final value = await Navigator.pushNamed(context, LaunchDeck.routeName, arguments: decks[index]);
                setState(() {
                  refresh();
                  refreshWeeklyProgress();
                  print("HOMESCREEN called");
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
                            child: Text(cardsDueList[index].toString()),
                          ),
                        )
                    ),
                  ]
              ),
              title: Text(decks[index].name),
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
    const textStyleBold = TextStyle(
        color: Colors.black,
        fontFamily: "Lexend",
        fontWeight: FontWeight.bold,
        fontSize: 16,
    );
    const textStyle = TextStyle(
      color: Colors.black,
      fontFamily: "Lexend",
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

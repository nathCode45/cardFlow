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
  bool isLoading = false;
  bool isProgressLoading = false;
  late List<Deck> decks;
  List<int> cardsDueList = [];
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
    DateTime sunday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - dSubration);
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
            padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
            child: Image(image: AssetImage('assets/cflow_logo.png')),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 16), child:
          Text("🔥12", style: TextStyle(fontSize: 18),)
            ,),
          const Text(""),
          Row(
            children: [
              IconButton(onPressed: ()=>weeksBack--, icon: Icon(Icons.arrow_back_ios)),
              IconButton(onPressed: ()=>weeksBack++, icon: Icon(Icons.arrow_forward_ios))
            ],
          )
          ,Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 1.7,
              child: Card(elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                child: _BarChart(numWeeklyProgress: numProgressPastWeek,),),

            ),
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
      child: ListView.builder(
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
  _BarChart({Key? key, required this.numWeeklyProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
        BarChartData(
            titlesData: titlesData,
            barGroups: barGroups,
            gridData: FlGridData(show: false),
            maxY: 15
        )
    );


  }
  BarChartRodData getRod(double toY){
    return BarChartRodData(toY: toY, borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)), width: 20);
  }

  Widget getTitles(double value, TitleMeta meta){
    const textStyle = TextStyle(
        color: Colors.black,
        fontFamily: "Lexend",
        fontWeight: FontWeight.bold,
        fontSize: 16
    );

    String text;

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

    return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: textStyle,));
  }

  FlTitlesData get titlesData=>FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: getTitles
          )
      ),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))
  );

  List<BarChartGroupData>get barGroups => List.generate(7, (index) => BarChartGroupData(x: index, barRods: [getRod(numWeeklyProgress[index].toDouble())]));
}

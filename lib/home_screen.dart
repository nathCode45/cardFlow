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
  late List<Deck> decks;
  AppLifecycleState? _lastLifecycleState;
  final TextEditingController _addController = TextEditingController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshDecks();
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

  Future refreshDecks() async {
    setState(() {
      isLoading = true;
    });

    this.decks = await Data.instance.readDecks();

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
                    print(newDeck);
                    Data.instance.createDeck(newDeck);
                    setState(() {
                      refreshDecks();
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 1.7,
              child: Card(elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                child: _BarChart(),),

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
    return ListView.builder(
        shrinkWrap: true,
        itemCount: decks.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.pushNamed(context, LaunchDeck.routeName, arguments: decks[index]);
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
                          child: Text(decks[index].cardsDue.toString()),
                        ),
                      )
                  ),
                ]
            ),
            title: Text(decks[index].name),
          );
        }
    );
  }
}


class _BarChart extends StatelessWidget {
  const _BarChart({Key? key}) : super(key: key);

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

  List<BarChartGroupData>get barGroups => [
    BarChartGroupData(x:0,barRods: [getRod(8)],),
    BarChartGroupData(x:1,barRods: [getRod(10)],),
    BarChartGroupData(x:2,barRods: [getRod(2)],),
    BarChartGroupData(x:3,barRods: [getRod(9)],),
    BarChartGroupData(x:4,barRods: [getRod(5)],),
    BarChartGroupData(x:5,barRods: [getRod(6)],),
    BarChartGroupData(x:6,barRods: [getRod(8)],),
    

  ];
}

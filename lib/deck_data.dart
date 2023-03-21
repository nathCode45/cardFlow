
import 'dart:async';
import 'dart:convert';
import 'dart:math';


import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:zefyrka/zefyrka.dart';
import 'package:intl/intl.dart';


class Deck{
  int? id;
  String name;
  int? cardsDue;
  DateTime? dateCreated;



  Deck({required this.name, this.cardsDue =0, this.id, this.dateCreated});

  Map<String, dynamic> toMap(){
      return{
        'id': id,
        'name': name,
        'cards_due' : cardsDue,
        'date_created' : dateCreated?.toIso8601String()
      };
  }

  @override
  String toString() {
    return 'Deck{id: $id, name: $name, cards_due: $cardsDue, date_created: $dateCreated}';
  }

  Deck copy({int? id, String? name, int? cardsDue, DateTime? dateCreated}) {
    return Deck(id: id ?? this.id, name: name ?? this.name, cardsDue: cardsDue ?? this.cardsDue, dateCreated: dateCreated ?? this.dateCreated);
  }

  Future<List<Flashcard>> getCards() async{
    return await Data.instance.readFlashcards(deckID: id);
  }
}

class Flashcard{
  int? id;
  String front;
  String back;
  int? deckID;
  bool? isImage = false;

  double eFactor;
  int repetitions;
  DateTime nextReview;

  static const double INITIAL_EFACTOR = 2.5;

  Flashcard(this.front, this.back, {this.id, this.deckID, this.isImage}):
    nextReview = DateTime.now(),
    eFactor = INITIAL_EFACTOR,//2.5,
    repetitions = 1; //repetitions cannot be zero
  Flashcard.withData(this.front, this.back, {this.id, this.deckID, required this.nextReview, required this.eFactor, required this.repetitions, this.isImage});

  Flashcard.fromPlainText(String plainFront, String plainBack, {this.id, this.deckID, this.isImage}):
    front = jsonEncode(NotusDocument().insert(0, '$plainFront\n')),
    back = jsonEncode(NotusDocument().insert(0, '$plainBack\n')),
    nextReview = DateTime.now(),
    eFactor = INITIAL_EFACTOR,//2.5,
    repetitions = 1; //repetitions cannot be zero

  Map<String, dynamic> toMap(){
    var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return{
      'id': id,
      'deckID': deckID,
      'front': front,
      'back': back,
      'formattedRevDate': formatter.format(nextReview),
      'repetitions': repetitions,
      'eFactor': eFactor,
      'isImage': (isImage!=null && isImage==true)? 1:0
    };

    }


  void repeat(){
     repetitions = repetitions+1;
  }

  Duration reviewInterval(double grade, int gRepetitions){

    print("eFactor: ${getUpdatedEFactor(grade)}, repetitions: $repetitions ");


    if(gRepetitions<=2) {
      int roundedGrade = grade.round();
      switch (roundedGrade) {
        case 0:
          return const Duration(minutes: 1);
        case 1:
          return const Duration(minutes: 2);
        case 2:
          return const Duration(minutes: 5);
        default:
          return const Duration(minutes: 10);
      }
    }else if(grade<2) {
      return reviewInterval(grade, 1);
    }else if(grade==2) {
      return Duration(minutes: 10);
    }else if(gRepetitions ==5){
      return(Duration(hours: 18));
    } else {
      return reviewInterval(grade, gRepetitions-1)*getUpdatedEFactor(grade as double); ///this recursion is what is causing the eFactor to be so large
    }
  }

  double getUpdatedEFactor(double grade){
    double tempEFactor;
    if(eFactor<0.3){
      tempEFactor = 0.3;
    }else{
      var eMultiplier = 0.9; ///initially 0.02
      tempEFactor = (1/15)*pow(grade-3,3)+1;///(0.1-(5-grade)*((0.1-eMultiplier)+(5-grade)*eMultiplier));///eFactor + (grade-3)*0.5;
      //print("eFactor = eFactor + ${(0.1-(5-grade)*(0.08+(5-grade)*0.02))} = $eFactor");

    }
    return tempEFactor;

  }

  void updateRepetitions(double grade){
    if(grade<3 && repetitions > 3){
      repetitions = repetitions-2;
    }else{
      repeat();
    }
  }


  Flashcard copy({int? id, int? deckID, String? front, String? back}){
    return Flashcard(front?? this.front, back??this.back, id: id?? this.id, deckID: deckID ?? this.deckID);
  }

}





// abstract class Decks{
//   static List<Deck> deckList = [
//     Deck(name: "AP Calc BC", cardsDue: 3, cards: [
//       Flashcard("Squeeze Theorem","Suppose that g(x)<=f(x)<=h(x)"),
//       Flashcard("f(x) is continuous at x=c if...", "1. f(c) exists \n2. limx->cf(x) exists")
//     ]),
//     Deck(name: "AP Economics Unit 3", cardsDue: 14),
//     Deck(name: "Spanish conjugations", cardsDue: 12),
//     Deck(name: "AP Statistics chapter 4 vocabulary", cardsDue: 23),
//
//   ];
// }

class Data{

  static final Data instance = Data._init();

  static const String FILE_NAME = "deck_and_card_data.db";

  static Database? _database;
  //one database with two tables

  Data._init();

  Future<Database> get database async {
    if (_database!=null){
      return _database!;
    }
    _database = await _initDB(FILE_NAME);

    return _database!;


  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);

  }

  Future _createDB(Database db, int version) async {
    db.execute('CREATE TABLE decks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, cards_due INTEGER NOT NULL, date_created TEXT)');
    db.execute('CREATE TABLE flashcards(id INTEGER PRIMARY KEY AUTOINCREMENT, deckID INTEGER, front TEXT, back TEXT, formattedRevDate TEXT, repetitions INTEGER, eFactor INTEGER, isImage BIT)');
  }


  Future<Deck> createDeck(Deck deck) async {
    final db = await instance.database;
    final id = await db.insert("decks", deck.toMap());
    return deck.copy(id: id);
  }

  Future<Flashcard> createFlashcard(Flashcard flashcard) async{
    final db = await instance.database;
    final id = await db.insert("flashcards", flashcard.toMap());
    return flashcard.copy(id: id);
  }

  //TODO this function will read all decks but not load the cards from it so that less has to load
  Future<List<Deck>> readDecks() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('decks', columns: ['id', 'name', 'cards_due']);
    print("maps");
    print(maps);

    if(maps.isNotEmpty){
      return List.generate(
          maps.length,
              (int i){
            return Deck(
                id: maps[i]['id'],
                name: maps[i]['name'],
                cardsDue: maps[i]['cards_due'],
            );
          }
      );
    }else{
      throw Exception('no decks were found');
    }
  }

  Future<List<Flashcard>> readFlashcards({int? deckID}) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps;
    if(deckID==null){
      maps = await db.query('flashcards', columns: ['id','deckID', 'front', 'back', 'repetitions','eFactor', 'formattedRevDate', 'isImage']);
    }else{
      maps = await db.query('flashcards', columns: ['id', 'deckID', 'front', 'back', 'repetitions', 'eFactor', 'formattedRevDate', 'isImage'], where: 'deckID = ?', whereArgs: [deckID]);
    }


    if(maps.isNotEmpty){
      return List.generate(maps.length, (int i) => Flashcard.withData(maps[i]['front'], maps[i]['back'], id: maps[i]['id'],
          deckID: maps[i]['deckID'], nextReview: DateFormat('yyyy-MM-dd HH:mm:ss').parse(maps[i]['formattedRevDate']), eFactor: maps[i]['eFactor'],
        isImage: maps[i]['isImage']==1, repetitions: maps[i]['repetitions']),);
    }else{
      throw Exception('no cards were found');
    }
  }

  //TODO this function will read one specific deck including the cards in it
  Future<Deck> readDeck(int id) async{
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('decks', where: 'id = ?', whereArgs: [id]);

    if(maps.isNotEmpty){
      return Deck(
          id: maps[id]['id'],
          name: maps[id]['name'],
          cardsDue: maps[id]['cardsDue'],
          dateCreated: maps[id]['dateCreated']
      );
    }else{
      throw Exception('ID $id is not found');
    }
  }

  Future<Flashcard> readFlashcard(int id) async{
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('cards', where: 'id = ?', whereArgs: [id]);

    if(maps.isNotEmpty){
      return Flashcard.withData(maps[id]['front'], maps[id]['back'], id: maps[id]['id'], deckID: maps[id]['deckID'],
          nextReview: maps[id]['formattedRevDate'], eFactor: maps[id]['eFactor'], repetitions: maps[id]['repetitions'], isImage: maps[id]['isImage']==1);
    }else{
      throw Exception('ID $id is not found');
    }
  }


  Future<int> deleteDeck(int id) async{
    final db = await instance.database;

    return await db.delete('decks', where: 'id = ?', whereArgs: [id]);//TODO this isn't working

  }

  Future<int> deleteFlashcard(int id) async{
    final db = await instance.database;

    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);//TODO this isn't working

  }

  Future deleteAllDecks() async{
    final db = await instance.database;

    await db.delete('decks', where: null); //passing null to where just deletes all rows

  }

  Future deleteAllFlashcards() async{
    final db = await instance.database;

    await db.delete('flashcards', where: null); //passing null to where just deletes all rows

  }



  Future close() async {
    final db = await instance.database;
    db.close();
  }



  Future<void> deleteDatabase() async{
    String path = await getDatabasesPath();
    databaseFactory.deleteDatabase(join(path, FILE_NAME));

  }



}




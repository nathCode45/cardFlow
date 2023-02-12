
import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


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
        'date_created' : dateCreated?.toIso8601String(),
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

  Flashcard(this.front, this.back, {this.id, this.deckID});

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'deckID': deckID,
      'front': front,
      'back': back,
    };
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
    db.execute('CREATE TABLE flashcards(id INTEGER PRIMARY KEY AUTOINCREMENT, deckID INTEGER, front TEXT, back TEXT)');
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
      maps = await db.query('flashcards', columns: ['id','deckID', 'front', 'back']);
    }else{
      maps = await db.query('flashcards', columns: ['id', 'deckID', 'front', 'back'], where: 'deckID = ?', whereArgs: [deckID]);
    }


    if(maps.isNotEmpty){
      return List.generate(maps.length, (int i) => Flashcard(maps[i]['front'], maps[i]['back'], id: maps[i]['id'], deckID: maps[i]['deckID']));
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
      return Flashcard(maps[id]['front'], maps[id]['back'], id: maps[id]['id'], deckID: maps[id]['deckID']);
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




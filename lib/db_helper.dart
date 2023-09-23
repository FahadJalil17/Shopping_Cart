import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'cart_model.dart';

class DBHelper{
  static Database? _db;

  Future<Database?> get db async{
    // if database is not equal to null then return database
    if(_db != null){
      return _db!;
    }

    _db = await initDatabase();
  }

  initDatabase() async{
    // create path in mobile for local storage memory
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'cart.db');  // cart.db name of database
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async{
    // creating table in which we will store our data
    await db.execute('''
    CREATE TABLE cart (id INTEGER PRIMARY KEY , productId VARCHAR UNIQUE,
    productName TEXT, initialPrice INTEGER, productPrice INTEGER , quantity INTEGER, unitTag TEXT , image TEXT )
    ''');
  }

  // insert method
  Future<Cart> insert(Cart cart) async{
    var dbClient = await db;
    await dbClient!.insert('cart', cart.toMap()); // toMap method in cart model class
    return cart;
  }

  // All the cart list added in database this method will return it => For fetching data
  Future<List<Cart>> getCartList() async{
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult = await dbClient!.query('cart');
    return queryResult.map((e) => Cart.fromMap(e)).toList();
  }

  // For removing any item
Future<int> delete(int id) async{
    var dbClient = await db;
    return await dbClient!.delete('cart', where: 'id = ?', whereArgs: [id]);
}

// for updating quantity
Future<int> updateQuantity(Cart cart) async{
    var dbClient = await db;
    return await dbClient!.update('cart', cart.toMap(), where: 'id = ?', whereArgs: [cart.id]);
}

}


import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_cart/db_helper.dart';

import 'cart_model.dart';

class CartProvider with ChangeNotifier{

  DBHelper db = DBHelper();

  // counter for cart items increment
  int _counter = 0;
  int get counter => _counter;

  // total price for items in cart merged amount
  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;


  void _setPrefItems() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('cart_item', _counter);
    prefs.setDouble('total_price', _totalPrice);
    notifyListeners();
  }

  void _getPrefItems() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('cart_item') ?? 0;
    _totalPrice = prefs.getDouble('total_price') ?? 0.0;
    notifyListeners();
  }

  // incrementing the add to cart number
void addCounter() {
    _counter++; // _counter value will be stored in shared preference
  _setPrefItems();
  notifyListeners();
}

void removeCounter() {
    _counter--;
    _setPrefItems();
    notifyListeners();
}

//
int getCounter() {
    _getPrefItems();
    return _counter;
}

// we wil call this method when we click on add to cart
void addTotalPrice(double productPrice){
_totalPrice = _totalPrice + productPrice;
_setPrefItems();
notifyListeners();
}

void removeTotalPrice(double productPrice){
    _totalPrice = _totalPrice - productPrice;
    _setPrefItems();
    notifyListeners();
}

double getTotalPrice(){
    _getPrefItems();
    return _totalPrice;
}


  late Future<List<Cart>> _cart;  // modelclass as list
  Future<List<Cart>> get cart => _cart;

  Future<List<Cart>> getData() async{
    _cart = db.getCartList();
    return _cart ;
  }


}

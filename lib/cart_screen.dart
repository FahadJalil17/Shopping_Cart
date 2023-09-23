import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:shopping_cart/cart_provider.dart';
import 'package:shopping_cart/db_helper.dart';

import 'cart_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  DBHelper? dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Products"),
        centerTitle: true,
        actions: [
          Center(
            child: Badge(
              badgeContent: Consumer<CartProvider>(builder: (context, value, child){
                return Text(value.getCounter().toString(), style: TextStyle(color: Colors.white));  // call get Counter method
              },),
              child: Icon(Icons.shopping_bag_outlined),
            ),
          ),
          SizedBox(width: 20,),

        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              FutureBuilder(
              future: cart.getData(),
              builder: (context, AsyncSnapshot<List<Cart>> snapshot){
                if(snapshot.hasData){
                  if(snapshot.data!.isEmpty){
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60,),
                          Image(image: AssetImage("assets/empty_cart.png")),
                          SizedBox(height: 20,),
                          Text("Explore Products", style: Theme.of(context).textTheme.headlineMedium,),
                        ],
                      ),
                    );
                  }
                  else{
                    return Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index){
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,  // will occupy full space
                                      children: [
                                        Image(
                                          height: 100,
                                          width: 100,
                                          image: NetworkImage(snapshot.data![index].image.toString()),
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(snapshot.data![index].productName.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),

//  for deleting any item from the cart => counter should be decrement and item price should be removed from total price
                                                  InkWell(
                                                      onTap: (){
                                                        dbHelper!.delete(snapshot.data![index].id!);
                                                        cart.removeCounter();
                                                        cart.removeTotalPrice(double.parse(snapshot.data![index].productPrice.toString()));
                                                      },
                                                      child: Icon(Icons.delete)),
                                                ],
                                              ),

                                              SizedBox(height: 5,),
                                              Text(snapshot.data![index].unitTag.toString() + " " + r"$" + snapshot.data![index].productPrice.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                              SizedBox(height: 5,),

                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: (){

                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(4.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [

                                                          // decrement -
                                                          InkWell(
                                                              onTap: (){
                                                                // when quantity increases the total amount will also be increase
                                                                int quantity = snapshot.data![index].quantity!;  // 1
                                                                int price = snapshot.data![index].initialPrice!;  // 20
                                                                quantity--;  // 2
                                                                int newPrice= quantity * price;  // 2 * 20 = 40 new price

                                                                if(quantity > 0){
                                                                  dbHelper!.updateQuantity(
                                                                    Cart(
                                                                        id: snapshot.data![index].id!,
                                                                        productId: snapshot.data![index].id!.toString(),
                                                                        productName: snapshot.data![index].productName.toString(),
                                                                        initialPrice: snapshot.data![index].initialPrice,
                                                                        productPrice: newPrice,  // this will be changed now
                                                                        quantity: quantity,  // new quantity
                                                                        unitTag: snapshot.data![index].unitTag.toString(),
                                                                        image: snapshot.data![index].image.toString()
                                                                    ),
                                                                  ).then((value){

                                                                    //if above query is updated successfully then set newPrice & quantity to 0
                                                                    newPrice = 0;
                                                                    quantity = 0;
                                                                    cart.removeTotalPrice(double.parse(snapshot.data![index].initialPrice.toString()));
                                                                  }).onError((error, stackTrace){
                                                                        (kDebugMode){
                                                                      print(error.toString());
                                                                    };
                                                                  });
                                                                }

                                                              },
                                                              child: Icon(Icons.remove, color: Colors.white,)),

                                                          Text(snapshot.data![index].quantity.toString(), style: TextStyle(color: Colors.white),),

                                                          // increment +
                                                          InkWell(
                                                              onTap: (){
                                                                // when quantity increases the total amount will also be increase
                                                                int quantity = snapshot.data![index].quantity!;  // 1
                                                                int price = snapshot.data![index].initialPrice!;  // 20
                                                                quantity++;  // 2
                                                                int newPrice= quantity * price;  // 2 * 20 = 40 new price

                                                                dbHelper!.updateQuantity(
                                                                  Cart(
                                                                      id: snapshot.data![index].id!,
                                                                      productId: snapshot.data![index].id!.toString(),
                                                                      productName: snapshot.data![index].productName.toString(),
                                                                      initialPrice: snapshot.data![index].initialPrice,
                                                                      productPrice: newPrice,  // this will be changed now
                                                                      quantity: quantity,  // new quantity
                                                                      unitTag: snapshot.data![index].unitTag.toString(),
                                                                      image: snapshot.data![index].image.toString()
                                                                  ),
                                                                ).then((value){

                                                                  //if above query is updated successfully then set newPrice & quantity to 0
                                                                  newPrice = 0;
                                                                  quantity = 0;
                                                                  cart.addTotalPrice(double.parse(snapshot.data![index].initialPrice.toString()));
                                                                }).onError((error, stackTrace){
                                                                      (kDebugMode){
                                                                    print(error.toString());
                                                                  };
                                                                });

                                                              },
                                                              child: Icon(Icons.add, color: Colors.white,)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  }

                }
                return Text("data");
               }),

              Consumer<CartProvider>(builder: (context, value, child){
                return Visibility(
                  visible: value.getTotalPrice().toStringAsFixed(2) == "0.00" ? false : true,
                  child: Column(
                  children: [
                   // ReusableWidget(title: "Sub Total", value: r'$'+value.getTotalPrice().toStringAsFixed(2)),
                    // ReusableWidget(title: "Discount 5%", value: r"$" + "20"),
                    ReusableWidget(title: "Total", value: r"$" + value.getTotalPrice().toStringAsFixed(2)),
                  ],
                  ),
                );
              }),

            ],
          ),
        ),
      ),
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  ReusableWidget({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Text(value.toString(), style: Theme.of(context).textTheme.titleLarge,)
      ],
    );
  }
}


import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:shopping_cart/cart_model.dart';
import 'package:shopping_cart/cart_screen.dart';
import 'package:shopping_cart/db_helper.dart';

import 'cart_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {

  DBHelper? dbHelper = DBHelper();

  List<String> productName = ['Strawberry','Orange','Tomato','Watermelon','cauliflower','Apple', 'Mango' , 'Orange' , 'Grapes' , 'Banana' , 'Chery' , 'Peach','Mixed Fruit Basket'];
  List<String> productUnit = ['KG','Dozen', 'KG','KG','KG','KG', 'KG' , 'Dozen' , 'KG' , 'Dozen' , 'KG' , 'KG','KG',];
  List<int> productPrice = [5, 10, 15, 20, 25, 30, 35, 40 , 45 , 50 , 55, 60 , 65 ];
  List<String> productImage = [
    'https://www.shutterstock.com/image-photo/fresh-sweet-strawberry-isolated-on-white-600w-106641707.jpg',
    'https://www.shutterstock.com/image-photo/orange-cut-half-green-leaves-isolated-600w-1927497314.jpg',
    'https://www.shutterstock.com/image-photo/fresh-tomato-shadow-isolated-on-white-600w-70788040.jpg',
    'https://www.shutterstock.com/image-photo/ripe-single-full-watermelon-berry-isolated-600w-566226250.jpg',
    'https://www.shutterstock.com/image-photo/cauliflower-vegetable-isolated-on-white-background-600w-784308772.jpg',
    'https://www.shutterstock.com/image-photo/isolated-apples-whole-red-apple-fruit-600w-575378506.jpg',
    'https://image.shutterstock.com/image-photo/mango-isolated-on-white-background-600w-610892249.jpg' ,
    'https://image.shutterstock.com/image-photo/orange-fruit-slices-leaves-isolated-600w-1386912362.jpg' ,
    'https://image.shutterstock.com/image-photo/green-grape-leaves-isolated-on-600w-533487490.jpg' ,
    'https://media.istockphoto.com/photos/banana-picture-id1184345169?s=612x612' ,
    'https://media.istockphoto.com/photos/cherry-trio-with-stem-and-leaf-picture-id157428769?s=612x612' ,
    'https://media.istockphoto.com/photos/single-whole-peach-fruit-with-leaf-and-slice-isolated-on-white-picture-id1151868959?s=612x612' ,
    'https://media.istockphoto.com/photos/fruit-background-picture-id529664572?s=612x612',
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Product List"),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
            },
            child: Center(
              child: Badge(
                badgeContent: Consumer<CartProvider>(builder: (context, value, child){
                  return Text(value.getCounter().toString(), style: TextStyle(color: Colors.white));  // call get Counter method
                },),
                child: Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          SizedBox(width: 20,),

        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: productName.length,
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
                            image: NetworkImage(productImage[index].toString()),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(productName[index].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                SizedBox(height: 5,),
                                Text(productUnit[index].toString() + " " + r"$" + productPrice[index].toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                SizedBox(height: 5,),
                                
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: (){
                                      dbHelper!.insert(
                                        Cart(id: index, //primary key
                                            productId: index.toString(), // it is varchar
                                            productName: productName[index].toString(),
                                            initialPrice: productPrice[index],  // both are integers
                                            productPrice: productPrice[index],
                                            quantity: 1,
                                            unitTag: productUnit[index].toString(),
                                            image: productImage[index].toString()),
                                      ).then((value){
                                        if(kDebugMode){
                                         print("product is added to cart");
                                        }

                                        // product price is in int convert it to double
                                        cart.addTotalPrice(double.parse(productPrice[index].toString()));
                                        cart.addCounter();  // it will be updated

                                      }).onError((error, stackTrace){
                                        (kDebugMode){
                                         print(error.toString());
                                        };
                                      });
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Text("Add To Cart", style: TextStyle(color: Colors.white),),
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
          ),
        ],
      )
    );
  }
}


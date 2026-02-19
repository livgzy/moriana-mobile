import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/checkout.dart';
import 'package:moriana_mobile/detail_menu.dart';
import 'package:moriana_mobile/providers/cart_provider.dart';
import 'package:moriana_mobile/providers/menu_provider.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final menus = Provider.of<MenuProvider>(context).menuList;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar:  AppBar(
        backgroundColor: const Color.fromARGB(255, 76, 175, 80),
        title: const Text(
          "Salad Buah Moriana",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => (CheckoutScreen()))
                  );
                },
              ),
              if (cart.totalQty > 0)
                Positioned(
                  right: 8,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Text(
                      cart.totalQty.toString(),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // penting
              children: [
                Container(
                  width: 100,
                  height: 90,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(menu.imageURL),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.nmMenu,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        menu.isian.join(', '),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(color: Colors.black),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Rp.${menu.harga}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(right: 15, top: 10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailMenuScreen(menu: menu),
                        ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 76, 175, 80),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
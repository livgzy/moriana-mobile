import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/checkout.dart';
import 'package:moriana_mobile/detail_menu.dart';
import 'package:moriana_mobile/promo.dart';
import 'package:moriana_mobile/providers/cart_provider.dart';
import 'package:moriana_mobile/providers/menu_provider.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:moriana_mobile/providers/user_providers.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
    Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).userData;
    final menus = Provider.of<MenuProvider>(context).menuList;
    final promo = Provider.of<PromotionProvider>(context).promos;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hai ${user?.username ?? ''}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Dapatkan salad buah terbaik di sini.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
           SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: promo.length, 
              itemBuilder: (context, index) {
                return Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1659821638991-c43fc142ec14',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => (PromoScreen(fromHome: true,))),
                      );
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 76, 175, 80),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Text(
                          "Lihat Promo",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

            const SizedBox(height: 20),
            const Text(
              "Menu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Grid Menu
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menus.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3 / 3.5,
              ),
              itemBuilder: (context, index) {
                final menu = menus[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                            image: CachedNetworkImageProvider(menu.imageURL),
                            fit: BoxFit.cover,
                          )
                  ),

                  child: Stack(
                    children: [
    
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          height: 32,
                          width: 32,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 76, 175, 80),
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                            onTap : () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => (DetailMenuScreen(menu: menu))),
                              );
                            }, 
                            child: const Icon(Icons.add, color: Colors.white)
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )

          ],
        ),
      ),
    );
  }
}




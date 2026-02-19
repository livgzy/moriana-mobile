import 'package:flutter/material.dart';
import 'package:moriana_mobile/providers/menu_provider.dart';
import 'package:moriana_mobile/providers/navigation_provider.dart';
import 'package:moriana_mobile/providers/order_provider.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:moriana_mobile/providers/user_providers.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'menu.dart';
import 'order.dart';
import 'profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUser();
    Provider.of<MenuProvider>(context, listen: false).loadMenus();
    Provider.of<PromotionProvider>(context, listen: false).fetchPromotions();
    Provider.of<OrderProvider>(context, listen: false).fetchOrdersForUser();
  }

  final List<Widget> pages = [
    HomeScreen(),
    MenuScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return Scaffold(
      body: pages[nav.currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nav.currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: nav.changeTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

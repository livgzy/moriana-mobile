import 'package:flutter/material.dart';
import 'package:moriana_mobile/admin/menu.dart';
import 'package:moriana_mobile/admin/promo.dart';
import 'package:moriana_mobile/providers/menu_provider.dart';
import 'package:moriana_mobile/providers/order_provider.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:moriana_mobile/providers/user_providers.dart';
import 'package:provider/provider.dart';

import 'order.dart';
import "home.dart";
// import 'menu.dart';
// import 'promo.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }
  
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUser();
    Provider.of<MenuProvider>(context, listen: false).loadMenus();
    Provider.of<PromotionProvider>(context, listen: false).fetchPromotions();
    Provider.of<OrderProvider>(context, listen: false).fetchOrder();
  }
  
  @override
  Widget build(BuildContext context) {
  final List<Widget> pages = [
    HomeAdminScreen(onQuickTap: changeTab),
    OrderAdminScreen(),
    MenuAdminScreen(),
    PromoAdminScreen(),
  ];
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
            changeTab(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.discount), label: "Promo"),
        ],
      ),
    );
  }
}

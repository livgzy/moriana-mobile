import 'package:flutter/material.dart';
import 'package:moriana_mobile/providers/menu_provider.dart';
import 'package:moriana_mobile/providers/order_provider.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:moriana_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomeAdminScreen extends StatefulWidget {
  final Function(int) onQuickTap;
  const HomeAdminScreen({super.key, required this.onQuickTap});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  final AuthService _auth = AuthService();

  void _signOut(context) async{
     try {

      await _auth.signout();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign out Gagal: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  final orderProvider = Provider.of<OrderProvider>(context);
  final menuProvider = Provider.of<MenuProvider>(context);
  final promoProvider = Provider.of<PromotionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            _quickActionCard(
              title: "Orders",
              subtitle: "Kelola pesanan yang masuk",
              buttonText: "Lihat",
              onTap: () =>  widget.onQuickTap(1)
            ),

            const SizedBox(height: 15),

            _quickActionCard(
              title: "Menu",
              subtitle: "Perbarui menu dan harga Anda",
              buttonText: "Edit",
              onTap: () => widget.onQuickTap(2)
            ),

            const SizedBox(height: 15),
 
            _quickActionCard(
              title: "Promos",
              subtitle: "Buat dan kelola penawaran promosi",
              buttonText: "Edit",
              onTap: () => widget.onQuickTap(3)
            ),

            const SizedBox(height: 30),

            /// ---------- OVERVIEW ----------
            const Text(
              "Overview",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _overviewCard(
                    title: "Total Order",
                    value: orderProvider.allOrderList.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _overviewCard(
                    title: "Menu Items",
                    value: menuProvider.menuList.length.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Active Promos",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            promoProvider.promos.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text("No active promo"),
                  )
                : Column(
                    children: promoProvider.promos.map((promo) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(20, 0, 0, 0),
                              blurRadius: 4,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_offer,color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Expanded(child: Text(promo.nama)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 30),
            SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {_signOut(context);},
                child: const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      
    );
  }
    Widget _quickActionCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: const Color.fromARGB(20, 0, 0, 0),
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 76, 175, 80),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(buttonText, style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _overviewCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: const Offset(0, 2),
            color: const Color.fromARGB(20, 0, 0, 0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          )
        ],
      ),
    );
  }
}
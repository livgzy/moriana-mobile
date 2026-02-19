import 'package:flutter/material.dart';
import 'package:moriana_mobile/edit_profile.dart';
import 'package:moriana_mobile/providers/cart_provider.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:moriana_mobile/providers/user_providers.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  

  final AuthService _auth = AuthService();

  void _signOut(context) async{
     try {
      Provider.of<CartProvider>(context, listen: false).clearCart();
      Provider.of<PromotionProvider>(context, listen: false).clearPromo();
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
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userData;
    final image = userProvider.userImage;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: image != null ? MemoryImage(image) : null,
                    child: image == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${user?.username}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${user?.email}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Card Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(40, 179, 179, 179),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text("Akun Saya", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Edit Profil"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfilePage()),
                        );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Ganti Password"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.add_card),
                    title: const Text("Metode Pembayaran"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(40, 179, 179, 179),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text("Aktivitas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text("Riwayat Pesanan"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(40, 179, 179, 179),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),             
              child: Column(
                children: [
                  const Text("Pusat Bantuan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ListTile(
                    leading: const Icon(Icons.public),
                    title: const Text("Bahasa"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text("Notifikasi"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text("Pusat Bantuan"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

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
}
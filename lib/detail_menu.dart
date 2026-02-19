
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/checkout.dart';
import 'package:moriana_mobile/models/menu.dart';
import 'package:moriana_mobile/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class DetailMenuScreen extends StatefulWidget {
  final MenuModel menu;

  const DetailMenuScreen({
    super.key,
    required this.menu,
  });

  @override
  State<DetailMenuScreen> createState() => _DetailMenuScreenState();
}

class _DetailMenuScreenState extends State<DetailMenuScreen> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 76, 175, 80),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(widget.menu.imageURL),
                )
              ),
            ),

            const SizedBox(height: 12),
            Text(widget.menu.nmMenu,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),
            Text("Rp ${widget.menu.harga}",
                style: const TextStyle(
                    fontSize: 19, fontWeight: FontWeight.bold, color: Colors.green)),

            const SizedBox(height: 12),
            
            const Text( "Bahan Utama", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 12), 
            Text(
                widget.menu.isian.join(', '),
                style: const TextStyle(color: Colors.black),
            ),
            // SizedBox(height: 42, 
            //   child: ListView.builder( 
            //     itemCount: widget.menu.isian.length, 
            //     itemBuilder: (context, index) { 
            //       final item = widget.menu; 
            //       return Container(
            //         child: Text(
            //           "${item.isian[index]},",
            //           style: TextStyle(
            //             color: Colors.black
            //           ),
            //         ),
            //       );
            //     }, 
            //   ), 
            // ), 
            const SizedBox(height: 18), 
            const Text("Ukuran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 10), 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), 
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400), 
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ), 
              child: Text(widget.menu.ukuran)
            ), 
            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (qty > 1) qty--;
                      });
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text(qty.toString(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        qty++;
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  cart.addToCart(
                    id: widget.menu.id,
                    name: widget.menu.nmMenu,
                    price: widget.menu.harga,
                    qty: qty,
                    imageURL: widget.menu.imageURL,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${widget.menu.nmMenu} ditambahkan ke keranjang"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  "Tambah ke Keranjang",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

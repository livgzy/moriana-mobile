import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/checkout.dart';
import 'package:moriana_mobile/order_detail.dart';
import 'package:moriana_mobile/providers/cart_provider.dart';
import 'package:moriana_mobile/providers/qris_payment_provider.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
// import 'detail_pemesanan.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final orders = orderProv.orderList;
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

      body: RefreshIndicator(
        onRefresh: () async {
          await orderProv.fetchOrdersForUser();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final firstImage = order.items.first.imageURL;
        
            DateTime date = order.createdAt.toDate();
        
        
            String formattedDate =
              "${date.day.toString().padLeft(2, '0')}-"
              "${date.month.toString().padLeft(2, '0')}-"
              "${date.year}";
        
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
        
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 90,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: DecorationImage(
                              image: CachedNetworkImageProvider(firstImage),
                              fit: BoxFit.cover,
                            )
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pesanan #$formattedDate",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
        
                        const SizedBox(height: 4),
                        Text(
                          "${order.items.length} item • Rp.${order.total}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            RealtimeOrderStatus(orderId: order.id),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider(
                                      create: (_) => QrisPaymentProvider(order.id, context.read<OrderProvider>()),
                                      child: OrderDetailScreen(order: order),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Lihat Detail",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color.fromARGB(255, 76, 175, 80),
                                  color: Color.fromARGB(255, 76, 175, 80),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
        
                  const SizedBox(width: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class RealtimeOrderStatus extends StatelessWidget {
  final String orderId;

  const RealtimeOrderStatus({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text(
            "Loading...",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'Pending';

        Color color;
        switch (status) {
          case 'Expired':
            color = Colors.red;
            break;
          case 'Cancel':
            color = Colors.red;
            break;
          case 'Process':
            color = Colors.green;
            break;
          default:
            color = Colors.green;
        }

        return Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

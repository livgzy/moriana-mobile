import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/models/order.dart';
import 'package:moriana_mobile/providers/order_provider.dart';
import 'package:moriana_mobile/providers/qris_payment_provider.dart';
import 'package:provider/provider.dart';
// import 'package:moriana_mobile/providers/user_providers.dart';
// import 'package:provider/provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {


  @override
  Widget build(BuildContext context) {
    final isQris = widget.order.paymentMethod == "QRIS";
    QrisPaymentProvider? qris;

    if (isQris) {
      qris = context.watch<QrisPaymentProvider>();
    }

    final isProcess = widget.order.status == "Process" || qris?.isProcessing == true;
    final isExpired = widget.order.status == "Expired" || qris?.expired == true;
    // final isPending = widget.order.status == "Pending" || qris?.isPending == true;

      
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 76, 175, 80),
        iconTheme:  const IconThemeData(color: Colors.white),
        title: const Text(
          "Detail Riwayat Pesanan",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isQris && qris != null) ...[
            if (qris.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (isProcess) ...[
              _paymentStatus(qris),
            ]
            else if (isExpired) ...[
              _paymentStatus(qris),
              _qrisImageBox(qris),
            ]
            else ...[
              _paymentStatus(qris),
              _qrisImageBox(qris),
              if (!qris.isLoading && qris.canCancel)
                _buttonCancel(qris),
            ]
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "Rincian Pesanan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.order.items.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(item.imageURL),
                              fit: BoxFit.cover,
                            ) 
                        ),
                      ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
            
                              const SizedBox(height: 4),
            
                              Text("${item.qty}x"),
                            ],
                          ),
                        ),
            
                        Text(
                          "Rp.${item.harga}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            
                const SizedBox(height: 10),

                _priceRow("Subtotal", widget.order.subtotal),
                _priceRow("Biaya Ongkir", widget.order.ongkir),
                _priceRow("Diskon", widget.order.diskonMenu),
            
                const Divider(),
                _priceRow("Total", widget.order.total, bold: true),
              ],
            ),
          ),
          

          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detail Pengiriman",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.payment, color: Colors.green),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Metode Pembayaran",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          widget.order.paymentMethod,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tujuan Pengiriman",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                      
                          Text(
                            widget.order.destinationAddress,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_rounded, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Catatan",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                      
                          Text(
                            "${widget.order.note}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buttonCancel(QrisPaymentProvider qris) {
    final orderProvider = Provider.of<OrderProvider>(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final confirm = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Batalkan Pesanan"),
              content: const Text("Yakin ingin membatalkan pesanan ini?"),
              actions: [
                TextButton(
                  child: const Text("Batal"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  child: const Text("Ya"),
                  onPressed: () => {

                    orderProvider.fetchOrdersForUser(),
                    Navigator.pop(context, true),
                    Navigator.pop(context, true),
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Pesanan Berhasil Dibatalkan",
                            style: TextStyle(color: Colors.white)),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  }
                  
                ),
              ],
            ),
          );
          if (confirm == true) {
              await FirebaseFirestore.instance.collection('orders').doc(widget.order.id).delete();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "Batalkan Pemesanan (${qris.formattedTime})",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _qrisImageBox(QrisPaymentProvider qris) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(20, 0, 0, 0),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "QRIS Pembayaran",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          AspectRatio(
            aspectRatio: 1,
            child: qris.expired
                ? _expiredQrisView()
                : _activeQrisView(qris.qrisUrl),
          ),

          const SizedBox(height: 8),
          Text(
            qris.expired
                ? "Waktu pembayaran telah habis"
                : "Scan QR untuk melakukan pembayaran",
            style: TextStyle(
              color: qris.expired ? Colors.red : Colors.grey,
              fontWeight: qris.expired ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeQrisView(String? url) {
    if (url == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _expiredQrisView(),
      ),
    );
  }

  Widget _expiredQrisView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.timer_off, color: Colors.red, size: 40),
          SizedBox(height: 8),
          Text(
            "QRIS Expired",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }


  Widget _paymentStatus(QrisPaymentProvider qris) {
    Color bg;
    IconData icon;
    String text;

    if (qris.isProcessing) {
      bg = Colors.green.shade100;
      icon = Icons.sync;
      text = "Pesanan sedang diproses";
    } else if (qris.expired) {
      bg = Colors.red.shade100;
      icon = Icons.timer_off;
      text = "Pembayaran kedaluwarsa";
    } else {
      bg = Colors.orange.shade100;
      icon = Icons.timer;
      text = "Lakukan pembayaran (${qris.formattedTime})";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  Widget _priceRow(String title, int value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "Rp.$value",
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}


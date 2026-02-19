import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/providers/order_provider.dart';
import 'package:moriana_mobile/providers/qris_payment_provider.dart';
import 'package:provider/provider.dart';

class QrisPaymentPage extends StatefulWidget {
  final int totalBayar;
  final String orderId;
  final List<dynamic> items;

  const QrisPaymentPage({
    super.key,
    required this.totalBayar,
    required this.orderId,
    required this.items,
  });

  @override
  State<QrisPaymentPage> createState() => _QrisPaymentPageState();
}

class _QrisPaymentPageState extends State<QrisPaymentPage> {


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QrisPaymentProvider(widget.orderId, context.read<OrderProvider>(),),
      child: _QrisPaymentView(
        totalBayar: widget.totalBayar,
        items: widget.items,
      ),
    );
  }
}

class _QrisPaymentView extends StatelessWidget {
  final int totalBayar;
  final List<dynamic> items;

  const _QrisPaymentView({
    required this.totalBayar,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final qris = context.watch<QrisPaymentProvider>();
    if (qris.isProcessing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pesanan sedang diproses"),
            backgroundColor: Colors.green,
          ),
        );
      });
    } else if (qris.expired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pembayaran Sudah Kadaluarsa"),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Halaman Pembayaran",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _countdown(qris),
            _qrisImageBox(qris),
            _productCard(),
            _paymentDetail(),
          ],
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
            color: const Color.fromARGB(107, 0, 0, 0),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "QRIS Pembayaran",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),

          AspectRatio(
            aspectRatio: 1,
            child: qris.qrisUrl != null
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(qris.qrisUrl!),
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : Container(
                color: const Color.fromARGB(179, 118, 118, 118),
            )
          ),

          const SizedBox(height: 5),
          const Text(
            "Scan QR untuk melakukan pembayaran",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _countdown(QrisPaymentProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Batas waktu bayar"),
          Text(
            provider.formattedTime,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detail Produk",
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
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
                        item.name,
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
                  "Rp.${item.price}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ),
  );

  Widget _paymentDetail() => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "Rp$totalBayar",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      );
}

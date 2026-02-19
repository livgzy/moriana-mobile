import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String selected;
  const PaymentMethodScreen({super.key, required this.selected});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Pilih Metode Pembayaran",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          paymentTile(
            "QRIS",
            Icons.account_balance,
          ),
          paymentTile(
            "Tunai",
            Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget paymentTile(String title, IconData icon) {
    final isSelected = selected == title;

    return InkWell(
      onTap: () {
        setState(() {
          selected = title;
        });
        Navigator.pop(context, title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                color: isSelected ? Colors.green : Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

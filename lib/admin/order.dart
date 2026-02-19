import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';

class OrderAdminScreen extends StatefulWidget {
  const OrderAdminScreen({super.key});

  @override
  State<OrderAdminScreen> createState() => _OrderAdminScreenState();
}

class _OrderAdminScreenState extends State<OrderAdminScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final orders = provider.allOrderList;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pemesanan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await provider.fetchOrder();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final userData = provider.userDataCache[order.user.id];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    color: const Color.fromARGB(25, 0, 0, 0),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Orderan ${userData?["username"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _statusDropdown(context, order),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Total: Rp ${order.total}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatDate(order.createdAt.toDate()),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Color.fromARGB(255, 76, 175, 80),
                        ),
                      ),
                      onPressed: () => _openDetailSheet(context, order, userData),
                      child: const Text(
                        "Detail",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statusDropdown(BuildContext context, OrderModel o) {
    final provider = Provider.of<OrderProvider>(context, listen: false);

    const statusList = ["Pending", "Process", "On Delivery", "Done", "Expired"];

    return DropdownButton<String>(
      value: o.status,
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(12),
      onChanged: (value) {
        if (value != null) provider.updateStatus(o.id, value);
      },
      items: statusList.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            status,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  void _openDetailSheet(BuildContext context, OrderModel o, userData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        "${userData?["username"]}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${userData?["email"]}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${userData?["noHp"]}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Detail Order",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text("Order ID : ${o.id}"),
                Text("Status : ${o.status}"),
                Text("Subtotal : Rp ${o.subtotal}"),
                Text("Promo : ${o.promo?.nama ?? "Tidak Ada Promo"} (${((o.promo?.nominal ?? 0)*100).floor()}%)"),
                Text("Diskon Menu : Rp ${o.diskonMenu}"),
                Text("Diskon Ongkir : Rp ${o.diskonOngkir}"),
                Text("Total : Rp ${o.total}"),
                Text("Ongkir : Rp ${o.ongkir}"),
                Text("Payment : ${o.paymentMethod}"),
                Text("Tanggal : ${_formatDate(o.createdAt.toDate())}"),

                const SizedBox(height: 20),

                Text(
                  "Catatan : ${o.note}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Text(
                  "Tujuan Pengiriman : ${o.destinationAddress}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Items:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ...o.items.map((item) => ListTile(
                      title: Text(item.nama),
                      subtitle: Text("Qty: ${item.qty}  |  Harga: ${item.harga}"),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}


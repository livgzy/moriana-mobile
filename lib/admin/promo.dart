import 'package:flutter/material.dart';
import 'package:moriana_mobile/admin/promo_add.dart';
import 'package:moriana_mobile/admin/promo_edit.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:moriana_mobile/services/firestore_service.dart';
import 'package:provider/provider.dart';

class PromoAdminScreen extends StatefulWidget {
  const PromoAdminScreen({super.key});

  @override
  State<PromoAdminScreen> createState() => _PromoAdminScreenState();
}

class _PromoAdminScreenState extends State<PromoAdminScreen> {
  @override
  Widget build(BuildContext context) {
  final promos = Provider.of<PromotionProvider>(context).promos;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_offer,color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              promo.nama,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          
                        ],
                      ),
                      const SizedBox(height: 4),                     
                      Text(
                            "Nominal Promo: ${(promo.nominal *100).floor()}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      const SizedBox(height: 4),
                      Text(
                        "Min Pembelian: Rp.${promo.min.toString()}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Tipe : ${promo.isTypeFood ? "Diskon Pemesanan" : "Diskon Ongkir"}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => PromoEditScreen(promoData: promo,))
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final provider = Provider.of<PromotionProvider>(context, listen: false);
                    final confirm = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Menu"),
                        content: const Text("Yakin ingin menghapus menu ini?"),
                        actions: [
                          TextButton(
                            child: const Text("Batal"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          ElevatedButton(
                            child: const Text("Hapus"),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await FirestoreService().deletePromo(promo.id!);
                      await provider.fetchPromotions();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => PromoAddScreen())
          );
        },
        label: const Text("Tambah Promo", style: TextStyle(color: Colors.white),),
        icon: const Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.green,
      ),
    );
  }
}
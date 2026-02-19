import 'package:flutter/material.dart';
import 'package:moriana_mobile/models/promo.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:moriana_mobile/services/firestore_service.dart';
import 'package:provider/provider.dart';

class PromoEditScreen extends StatefulWidget {
  final PromotionModel promoData;
  const PromoEditScreen({super.key, required this.promoData});

  @override
  State<PromoEditScreen> createState() => _PromoEditScreenState();
}

class _PromoEditScreenState extends State<PromoEditScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _minPembelianController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  
  late bool isTypeFood;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.promoData.nama;
    _minPembelianController.text = widget.promoData.min.toString();
    _nominalController.text = ((widget.promoData.nominal*100).floor()).toString();
    isTypeFood = widget.promoData.isTypeFood;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _minPembelianController.dispose();
    _nominalController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Promo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 76, 175, 80),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(30, 0, 0, 0),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nama Promo :",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _namaController,
                    onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      hintText: "Masukkan Judul Promo",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Pilih Tipe Promo:",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),

                  RadioListTile(
                    value: true,
                    groupValue: isTypeFood,
                    title: const Text("Diskon Pemesanan"),
                    onChanged: (val) => setState(() => isTypeFood = val!),
                    dense: true,
                  ),
                  RadioListTile(
                    value: false,
                    groupValue: isTypeFood,
                    title: const Text("Diskon Ongkir"),
                    onChanged: (val) => setState(() => isTypeFood = val!),
                    dense: true,
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Persentase Promo (0-100)% :",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _nominalController,
                    onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Masukkan nominal promo % ",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Min. Pembelian :",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _minPembelianController,
                    onTapUpOutside: (_) => FocusScope.of(context).unfocus(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Masukkan minimal pembelian",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final provider = Provider.of<PromotionProvider>(context, listen: false);

                  if (_namaController.text.isEmpty ||
                  _minPembelianController.text.isEmpty ||
                  _nominalController.text.isEmpty 
                  ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text( "Semua field wajib diisi!"),
                      backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  int? nominal = int.tryParse(_nominalController.text);

                  if (nominal! < 0 || nominal > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nominal promo harus antara 0 - 100"), backgroundColor: Colors.red,),
                    );
                    return;
                  }

                  int? minPembelian = int.tryParse(_minPembelianController.text);
                  if (minPembelian == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Minimal pembelian harus berupa angka"), backgroundColor: Colors.red,),
                    );
                    return;
                  }
                  if (minPembelian <= 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Minimal pembelian harus lebih dari 1"), backgroundColor: Colors.red,),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Promo berhasil Diedit!", style: TextStyle(color: Colors.white)),backgroundColor: Colors.green,),
                  );

                  final updatePromo = PromotionModel(
                    nama: _namaController.text,
                    nominal: double.parse(_nominalController.text)/100 ,
                    min: int.parse(_minPembelianController.text),
                    isTypeFood: isTypeFood,
                  );

                  await FirestoreService().updatePromo(widget.promoData.id!, updatePromo);
                  await provider.fetchPromotions();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Simpan Promo",
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
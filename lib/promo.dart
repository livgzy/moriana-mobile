import 'package:flutter/material.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:provider/provider.dart';

class PromoScreen extends StatefulWidget {
  final bool fromHome;
  final int? minPembelian;

  const PromoScreen({super.key, this.fromHome = false, this.minPembelian});

  @override
  State<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  @override
  Widget build(BuildContext context) {
    final promoProvider = Provider.of<PromotionProvider>(context);
    final biggest = promoProvider.biggestPromo;
    final others = promoProvider.otherPromos;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Promo"),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (biggest != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rekomendasi Promo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8FFD8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            biggest.isTypeFood ? Icons.restaurant : Icons.motorcycle,
                            size: 38,
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${biggest.nama} ${(biggest.nominal*100).toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Min. pembelian ${biggest.min ~/ 1000}rb",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.fromHome)
                            GestureDetector(
                              onTap: () {
                                if (widget.minPembelian! >= biggest.min) {
                                  promoProvider.selectPromo(biggest);
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Minimal Pembelian Sebesar Rp.${biggest.min}", 
                                        style: TextStyle(color: Colors.white)
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: Colors.red,
                                    )
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  "Pakai",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Promo yang bisa kamu pakai",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: others.length,
                itemBuilder: (context, index) {
                  final promo = others[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            promo.isTypeFood ? Icons.restaurant : Icons.motorcycle,
                            size: 30,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${promo.nama} ${(promo.nominal*100).toInt()}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Min. pembelian ${promo.min ~/ 1000}rb",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.fromHome)
                            GestureDetector(
                              onTap: () {
                                if (widget.minPembelian! >= promo.min) {
                                  promoProvider.selectPromo(promo);
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Minimal Pembelian Sebesar Rp.${promo.min}", 
                                        style: TextStyle(color: Colors.white)
                                      ),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: Colors.red,
                                    )
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  "Pakai",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

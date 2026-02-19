import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
// import 'package:moriana_mobile/main_page.dart';
import 'package:moriana_mobile/metode_pembayaran.dart';
import 'package:moriana_mobile/providers/navigation_provider.dart';
import 'package:moriana_mobile/qris_payment_page.dart';
import 'package:moriana_mobile/promo.dart';
import 'package:moriana_mobile/providers/order_provider.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';
import 'package:moriana_mobile/services/firestore_service.dart';
import 'package:moriana_mobile/services/reverse_geolocator_service.dart';
import 'package:provider/provider.dart';
import 'package:moriana_mobile/providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _catatanController = TextEditingController();

  String selectedPayment = "Tunai";
  late FocusNode _catatanFocusNode;

  final LatLng tokoLatLng = LatLng(-6.7580933393441835, 108.55594634352596);
  LatLng? selectedLatLng;

  double jarakKm = 0;
  int ongkir = 0;
  String alamatTujuan = "Geser pin untuk memilih alamat";
  Timer? _debounce;
  
  bool isLoadingAddress = false;
  bool isLocationGranted = false;
  bool isCheckingLocation = true;

  @override
  void initState() {
    super.initState();
    _catatanFocusNode = FocusNode(
      skipTraversal: true,
      canRequestFocus: false,
    );
    _loadUserLocation();
  }

  @override
  void dispose() {
    _catatanFocusNode.dispose();
    _catatanController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // MAP
  Future<LatLng> getCurrentUserLocation() async {
  if (!mounted) throw 'Widget disposed';

  setState(() => isCheckingLocation = true);

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    if (!mounted) throw 'Widget disposed';
    setState(() {
      isCheckingLocation = false;
      isLocationGranted = false;
    });
    throw 'Izin lokasi ditolak';
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.best),
  );

  if (!mounted) throw 'Widget disposed';
  setState(() {
    isLocationGranted = true;
    isCheckingLocation = false;
  });

  return LatLng(position.latitude, position.longitude);
  }


  Future<void> _loadUserLocation() async {
    try {
      final userLocation = await getCurrentUserLocation();
      if (!mounted) return;

      updateSelectedLocation(userLocation);

      setState(() => isLoadingAddress = true);

      final address = await ReverseGeocodingService.getAddress(
        lat: userLocation.latitude,
        lng: userLocation.longitude,
      );

      if (!mounted) return;
      setState(() {
        alamatTujuan = address;
        isLoadingAddress = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  
  void updateSelectedLocation(LatLng latLng) {
    if (!mounted) return;
    setState(() {
      selectedLatLng = latLng;
    });

    hitungJarakDanOngkir();
  }
  

  void hitungJarakDanOngkir() {
    if (selectedLatLng == null) return;

    jarakKm = Geolocator.distanceBetween(
          tokoLatLng.latitude,
          tokoLatLng.longitude,
          selectedLatLng!.latitude,
          selectedLatLng!.longitude,
        ) /
        1000;

    const int hargaPerKm = 8000;
    ongkir = (((jarakKm * hargaPerKm).ceil() + 499)  ~/ 500) * 500;
  }


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final promoProvider = Provider.of<PromotionProvider>(context);
    final promoSelected = promoProvider.selectedPromo;
    debugPrint("promo : $promoSelected");

    final int subtotal = cart.totalPrice;
    int diskonMenu = 0;
    int diskonOngkir = 0;

    if (promoSelected != null) {
      if(subtotal >= promoSelected.min) {
        if (promoSelected.isTypeFood) {
          diskonMenu = (subtotal * (promoSelected.nominal)).round();
        } else{
          diskonOngkir = (ongkir * (promoSelected.nominal)).round();
        }
      }
    }

    final total = (subtotal - diskonMenu) + (ongkir - diskonOngkir);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 76, 175, 80),
        elevation: 0,
        title: const Text("Keranjang Saya", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...cart.items.map((item) {
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    margin: const EdgeInsets.only(bottom: 6, left: 4, right: 4, top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade300,
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(item.imageURL),
                              fit: BoxFit.cover,
                            ),
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
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${item.price}",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 76, 175, 80),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (item.qty > 1) {
                                  cart.decreaseQty(item.id, promoProvider: promoProvider);
                                } 
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.remove, size: 16),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.qty.toString(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                cart.increaseQty(item.id, promoProvider: promoProvider);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 76, 175, 80),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => cart.removeItem(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(190, 244, 67, 50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 10),

            const Text(
              "Ringkasan Pesanan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            summaryRow("Subtotal", "Rp $subtotal"),
            if (diskonMenu > 0)
              summaryRow("Diskon Salad", "- Rp $diskonMenu", bold: true),
            summaryRow("Biaya Ongkir", "Rp $ongkir"),
            if (diskonOngkir > 0)
              summaryRow("Diskon Ongkir", "- Rp $diskonOngkir", bold: true),
            const Divider(height: 22, thickness: 1),

            summaryRow(
              "Total Pembayaran",
              "Rp $total",
              bold: true,
            ),
            const SizedBox(height: 20),

            const Text(
              "Tujuan Pengiriman",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // MAP
            SizedBox(
            height: 250,
            child: isCheckingLocation
              ? const Center(child: CircularProgressIndicator())
              : (!isLocationGranted)
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off, size: 40, color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text(
                            "Nyalakan lokasi untuk memilih alamat tujuan",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed:() async {
                              await Geolocator.openLocationSettings();
                              _loadUserLocation();
                            },
                            child: const Text("Nyalakan Lokasi", style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                    ),
                  )
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: selectedLatLng!,
                      initialZoom: 17,
                      onPositionChanged: (position, hasGesture) {
                        if (!hasGesture) return;

                        selectedLatLng = position.center;
                        updateSelectedLocation(position.center);

                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 800), () async {
                          if (!mounted) return;

                          setState(() => isLoadingAddress = true);

                          final address = await ReverseGeocodingService.getAddress(
                            lat: selectedLatLng!.latitude,
                            lng: selectedLatLng!.longitude,
                          );

                          if (!mounted) return;
                          setState(() {
                            alamatTujuan = address;
                            isLoadingAddress = false;
                          });
                        });
                      }
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.moriana.mobile',
                        errorTileCallback: (tile, error, stackTrace) => debugPrint('TILE ERROR: $error'),
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedLatLng!,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution('OpenStreetMap'),
                      ],
                  ),
                ],
              ),
            ),
        
            const SizedBox(height: 12),
            isLocationGranted
            ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: isLoadingAddress
                        ? const Text("Mengambil alamat...")
                        : Text(
                            alamatTujuan,
                            style: const TextStyle(fontSize: 13),
                          ),
                  ),
                ],
              ),
            )
            : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_off),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tidak Dapat Memilih Alamat Tujuan",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            // MAP
            const SizedBox(height: 12),
            promoCard(
              title: "Cek promo menarik di sini",
              color: Colors.red.shade400,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => (PromoScreen(fromHome: false, minPembelian: subtotal,)))
                );
              },
            ),
            const SizedBox(height: 10),
            
              if (promoSelected != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer, color: Colors.green),
                      SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Promo diterapkan: ${promoSelected.nama} (${(promoSelected.nominal*100).toInt()}%)",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          promoProvider.clearPromo();
                        },
                        child: Icon(Icons.close, color: Colors.red),
                      )
                    ],
                  ),
                ),
              ],

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () async {
                 final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentMethodScreen(selected: selectedPayment),
                  ),
                );
                if (!mounted) return;
                if (result != null) {
                  setState(() {
                    selectedPayment = result;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wallet, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      "Metode Pembayaran",
                      style:TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600
                      )
                    ),
                    Spacer(),
                    Text(
                      selectedPayment,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _catatanController,
              focusNode: _catatanFocusNode,
              autofocus: false,
              onTap: () {
                _catatanFocusNode.canRequestFocus = true; 
                _catatanFocusNode.requestFocus();
              },
              onTapOutside: (_) {
                _catatanFocusNode.unfocus();
                _catatanFocusNode.canRequestFocus = false;
              },
              decoration: InputDecoration(
                labelText: "Catatan",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            if (cart.items.isNotEmpty) {
              final tempItems = List.from(cart.items);

              if (selectedLatLng == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Tujuan Pengiriman Harus Di Isi",
                        style: TextStyle(color: Colors.white)),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
                          
              cart.clearCart();
              promoProvider.clearPromo();

              Timestamp? expiredTime;

              selectedPayment == "QRIS"  
              ? expiredTime = Timestamp.fromDate(
                DateTime.now().add(const Duration(minutes: 1)),
              )
              : expiredTime = null;

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
            
                  return FutureBuilder(
                    future: FirestoreService().createOrder(
                      userId: FirebaseAuth.instance.currentUser?.uid,
                      ongkir: ongkir,
                      diskonMenu: diskonMenu,
                      diskonOngkir: diskonOngkir,
                      subtotal: subtotal,
                      total: total,
                      paymentMethod: selectedPayment,
                      expiredTime: expiredTime,
                      destinationLatLng: selectedLatLng!,
                      destinationAddress: alamatTujuan,
                      note: _catatanController.text,
                      items: tempItems,
                      promo: promoSelected,
                    ),
                    builder: (context, snapshot) {
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(color: Colors.green),
                              SizedBox(height: 16),
                              Text("Memproses pesanan..."),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        final orderId = snapshot.data.toString();

                        return AlertDialog(
                          title: const Text("Pesanan Berhasil!"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Provider.of<OrderProvider>(context, listen: false).fetchOrdersForUser();
                                if (selectedPayment == "QRIS") {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                  Provider.of<NavigationProvider>(context, listen: false).goToOrders();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QrisPaymentPage(
                                        totalBayar: total,
                                        orderId: orderId,
                                        items: tempItems,
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Provider.of<NavigationProvider>(context, listen: false).goToOrders();
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      }

                      return AlertDialog(
                        title: const Text("Gagal"),
                        content: Text(snapshot.error.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          )
                        ],
                      );
                    },
                  );
                },
              );

            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Tidak ada item di cart",
                      style: TextStyle(color: Colors.white)),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "Pesan dan antar sekarang",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget summaryRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: bold ? FontWeight.bold : FontWeight.w500
            )
          ),
          Text(value,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: bold ? FontWeight.bold : FontWeight.w600
            )
          ),
        ],
      ),
    );
  }

  Widget promoCard({
    required String title,
    required Color color,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              title,
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }
}


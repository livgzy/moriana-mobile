import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moriana_mobile/models/order.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<OrderModel> _orderList = [];
  List<OrderModel> _allOrderList = [];

  // Map<String, Uint8List?> imageCache = {};
  // Map<String, Uint8List?> firstImageOfOrder = {};
  Map<String, Map<String, String>> userDataCache = {};


  List<OrderModel> get orderList => _orderList;
  List<OrderModel> get allOrderList => _allOrderList;
  // Uint8List? getImage(String menuId) => imageCache[menuId];
  // Uint8List? getFirstOrderImage(String orderId) => firstImageOfOrder[orderId];

  
  Future<void> fetchOrder() async {

    _allOrderList = await _firestoreService.getOrdersAll();
    await _loadUserNamesForOrders(_allOrderList);

    notifyListeners();
  }

  Future<void> fetchOrdersForUser() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    _orderList = await _firestoreService.getOrders(uid);
    debugPrint("$_orderList");

    notifyListeners();
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    await _firestoreService.updateOrderStatus(orderId, newStatus);

    final index = _allOrderList.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _allOrderList[index] = OrderModel(
        id: _allOrderList[index].id,
        user: _allOrderList[index].user,
        ongkir: _allOrderList[index].ongkir,
        diskonMenu: _allOrderList[index].diskonMenu,
        diskonOngkir: _allOrderList[index].diskonOngkir,
        total: _allOrderList[index].total,
        subtotal: _allOrderList[index].subtotal,
        paymentMethod: _allOrderList[index].paymentMethod,
        expiredTime: _allOrderList[index].expiredTime,
        destination: _allOrderList[index].destination,
        destinationAddress: _allOrderList[index].destinationAddress,
        note: _allOrderList[index].note,
        promo: _allOrderList[index].promo,
        status: newStatus,
        items: _allOrderList[index].items,
        createdAt: _allOrderList[index].createdAt,
      );
    }

    notifyListeners();
  }

  Future<void> _loadUserNamesForOrders(List<OrderModel> orders) async {
    for (final order in orders) {
      final userRef = order.user;

      if (userDataCache.containsKey(userRef.id)) continue;

      try {
        final userDoc = await userRef.get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;

          userDataCache[userRef.id] = {
            'username': (data['username'] ?? 'Tanpa Nama').toString(),
            'email': (data['email'] ?? '').toString(),
            'alamat': (data['alamat'] ?? '').toString(),
            'noHp': (data['noHp'] ?? '').toString(),
          };
        } else {
          userDataCache[userRef.id] = {
            'username': 'Tanpa Nama',
          };
        }
      } catch (e) {
        userDataCache[userRef.id] = {
          'username': 'Tanpa Nama',
        };
      }
    }
  }


  // Future<void> _loadImagesForOrders() async {

  //   for (var order in _orderList) {
  //     for (var item in order.items) {
  //       if (!imageCache.containsKey(item.menuId)) {
  //         imageCache[item.menuId] = await SQLiteService().getMenuImage(item.menuId);
  //       }
  //     }
      
  //     if (order.items.isNotEmpty) {
  //       final firstId = order.items.first.menuId;
  //       firstImageOfOrder[order.id] = imageCache[firstId];
  //     }
  //   }
  // }
}

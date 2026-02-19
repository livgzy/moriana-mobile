import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
// import 'package:moriana_mobile/models/cart.dart';
import 'package:moriana_mobile/models/menu.dart';
import 'package:moriana_mobile/models/order.dart';
import 'package:moriana_mobile/models/promo.dart';
import '../models/user.dart';

class FirestoreService {

  Future<void> addUser(UserModel user, String uid) async {
     try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(user.toMap());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(UserModel user, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update(user.toMap());
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> addMenu(MenuModel menu, String docId) async {
    await FirebaseFirestore.instance.collection('menu').doc(docId).set(menu.toMap());
  }

  Future<void> updateMenu(String id, MenuModel menu) async {
    await FirebaseFirestore.instance.collection('menu').doc(id).update(menu.toMap());
  }

  Future<void> deleteMenu(String id) async {
    await FirebaseFirestore.instance.collection('menu').doc(id).delete();
  }

  Future<List<MenuModel>> getAllMenu() async {
    final snapshot = await FirebaseFirestore.instance.collection('menu').get();
    
    return snapshot.docs.map((doc) {
      return MenuModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<List<PromotionModel>> getPromotions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("promotions").get();
      return snapshot.docs
          .map((doc) => PromotionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> addPromo(PromotionModel promo) async {
    await FirebaseFirestore.instance.collection('promotions').doc().set(promo.toMap());
  }

  Future<void> updatePromo(String id, PromotionModel promo) async {
    await FirebaseFirestore.instance.collection('promotions').doc(id).update(promo.toMap());
  }

  Future<void> deletePromo(String id) async {
    await FirebaseFirestore.instance.collection('promotions').doc(id).delete();
  }

  Future<List<OrderModel>> getOrdersAll() async {
    try {
    final query = await  FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((d) => OrderModel.fromDoc(d)).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }
  
  Future<List<OrderModel>> getOrders(String uid) async {
    final userRef =  FirebaseFirestore.instance.collection('users').doc(uid);

    final result = await FirebaseFirestore.instance
        .collection("orders")
        .where("users", isEqualTo: userRef)
        .orderBy("createdAt", descending: true)
        .get();

    return result.docs.map((doc) => OrderModel.fromDoc(doc)).toList();
  }


  Future<String> createOrder({
    required String? userId,
    required int ongkir,
    required int diskonMenu,
    required int diskonOngkir,
    required int subtotal,
    required int total,
    required String paymentMethod,
    Timestamp? expiredTime,
    required LatLng destinationLatLng,
    required String destinationAddress,
    required String? note,
    required List<dynamic> items,
    required PromotionModel? promo,
  }) async {
    final doc = FirebaseFirestore.instance.collection("orders").doc();
    await doc.set({
      "users": FirebaseFirestore.instance.doc("users/$userId"),
      "ongkir": ongkir,
      "diskonMenu": diskonMenu,
      "diskonOnkir": diskonOngkir,
      "subtotal": subtotal,
      "total": total,
      "paymentMethod": paymentMethod,
      "expiredTime": expiredTime,
      'destination': GeoPoint(
        destinationLatLng.latitude,
        destinationLatLng.longitude,
      ),
      'destinationAddress': destinationAddress,
      "note": note,
      "status": "Pending",
      "createdAt": FieldValue.serverTimestamp(),
      "promo": promo != null
          ? {
              "nama": promo.nama,
              "nominal": promo.nominal,
              "isTypeFood": promo.isTypeFood,
              "min": promo.min,
            }
          : null,
      "items": items.map((item) {
        return {
          "menuId": item.id,
          "nama": item.name,
          "harga": item.price,
          "qty": item.qty,
          "imageURL": item.imageURL,
        };
      }).toList(),
    });
    return doc.id;
  }
}
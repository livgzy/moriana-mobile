import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moriana_mobile/models/promo.dart';

class OrderItemModel {
  final String menuId;
  final String nama;
  final String imageURL;
  final int qty;
  final int harga;

  OrderItemModel({
    required this.menuId,
    required this.nama,
    required this.imageURL,
    required this.qty,
    required this.harga,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      menuId: map['menuId'],
      nama: map['nama'],
      imageURL: map['imageURL'],
      qty: map['qty'],
      harga: map['harga'],
    );
  }
}

class OrderModel {
  final String id;
  final DocumentReference user;
  final int ongkir;
  final int diskonMenu;
  final int diskonOngkir;
  final int subtotal;
  final int total;
  final String paymentMethod;
  final Timestamp? expiredTime;
  final GeoPoint destination;
  final String destinationAddress;
  final String? note;
  final String status;
  final PromotionModel? promo;
  final List<OrderItemModel> items;
  final Timestamp createdAt;

  OrderModel({
    required this.id,
    required this.user,
    required this.ongkir,
    required this.diskonMenu,
    required this.diskonOngkir,
    required this.subtotal,
    required this.total,
    required this.paymentMethod,
    required this.expiredTime,
    required this.destination,
    required this.destinationAddress,
    required this.note,
    required this.status,
    required this.promo,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final promoData = data['promo'];


    return OrderModel(
      id: doc.id,
      user: data['users'],
      ongkir: data['ongkir'],
      diskonMenu: data['diskonMenu'],
      diskonOngkir: data['diskonOnkir'],
      subtotal: data['subtotal'],
      total: data['total'],
      paymentMethod: data['paymentMethod'],
      expiredTime: data['expiredTime'] != null? data['expiredTime'] as Timestamp : null,
      destination: data['destination'] as GeoPoint,
      destinationAddress: data['destinationAddress'],
      note: data['note'],
      status: data['status'],
      promo: promoData == null ? null : PromotionModel.fromMap(promoData),
      createdAt: data['createdAt'],
      items: (data['items'] as List)
          .map((i) => OrderItemModel.fromMap(i))
          .toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moriana_mobile/models/cart.dart';
import 'package:moriana_mobile/providers/promo_provider.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalQty => _items.fold(0, (a, b) => a + b.qty);

  int get totalPrice =>
      _items.fold(0, (a, b) => a + (b.price * b.qty));

  void addToCart({
    required String id,
    required String name,
    required int price,
    required int qty,
    required String imageURL,
  }) {
    final existing = _items.indexWhere((e) => e.id == id);

    if (existing >= 0) {
      _items[existing].qty += qty;
    } else {
      _items.add(CartItem(
        id: id,
        name: name,
        price: price,
        qty: qty,
        imageURL: imageURL,
      ));
    }

    notifyListeners();
  }

  void increaseQty(String id, {PromotionProvider? promoProvider}) {
    final index = _items.indexWhere((e) => e.id == id);
    _items[index].qty++;
    notifyListeners();
    if (promoProvider != null) {
      promoProvider.validatePromo(totalPrice);
    }
  }

  void decreaseQty(String id, {PromotionProvider? promoProvider}) {
    final index = _items.indexWhere((e) => e.id == id);
    if (_items[index].qty > 1) {
      _items[index].qty--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();

    if (promoProvider != null) {
      promoProvider.validatePromo(totalPrice);
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

}

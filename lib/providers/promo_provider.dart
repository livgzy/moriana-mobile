import 'package:flutter/material.dart';
import 'package:moriana_mobile/models/promo.dart';
import '../services/firestore_service.dart';

class PromotionProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<PromotionModel> _promos = [];
  List<PromotionModel> get promos => _promos;
  PromotionModel? selectedPromo;


  PromotionModel? get biggestPromo {
    if (_promos.isEmpty) return null;
    _promos.sort((a, b) => b.nominal.compareTo(a.nominal));
    return _promos.first;
  }

  List<PromotionModel> get otherPromos {
    if (_promos.length <= 1) return [];
    return _promos.sublist(1);
  }

  Future<void> fetchPromotions() async {
    _promos = await _firestoreService.getPromotions();
    notifyListeners();
  }

  void selectPromo(PromotionModel promo) {
    selectedPromo = promo;
    notifyListeners();
  }

  void clearPromo() {
    selectedPromo = null;
    notifyListeners();
  }

  void validatePromo(int subtotal) {
  if (selectedPromo != null) {
    if (subtotal < selectedPromo!.min) {
      clearPromo();
    }
  }
}
}

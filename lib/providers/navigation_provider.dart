import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToHome() => changeTab(0);
  void goToMenu() => changeTab(1);
  void goToOrders() => changeTab(2);
  void goToProfile() => changeTab(3);
}
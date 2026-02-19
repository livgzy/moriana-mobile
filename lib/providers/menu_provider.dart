import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:moriana_mobile/services/superbase_service.dart';
import '../models/menu.dart';
// import '../services/sqlite_service.dart';
import '../services/firestore_service.dart';

class MenuProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  // final SQLiteService _sqlite = SQLiteService();

  List<MenuModel> menuList = [];
  // Map<String, Uint8List?> menuImages = {};

  bool isLoading = false;

  Future<void> loadMenus() async {

    menuList = await _firestore.getAllMenu();
    debugPrint("menu dapat $menuList");

    // for (var menu in menuList) {
    //   final img = await _sqlite.getMenuImage(menu.id);
    //   menuImages[menu.id] = img;
    // }
    notifyListeners();
  }

  Future<String?> saveMenuImage(Uint8List? image, String name,) async {
    final imageURL = await SuperbaseService().uploadMenuImage(image, name);
    await loadMenus();
    return imageURL;
  }

  Future<void> updateMenu(MenuModel menu) async {
    await _firestore.updateMenu(menu.id, menu);
    await loadMenus();
  }

  Future<String?> updateMenuImage(Uint8List image, String name,) async {
    final imageURL = await SuperbaseService().updateMenuImage(image, name);
    await loadMenus();
    return imageURL;
  }

    Future<void> deleteMenu(String id) async {
    await _firestore.deleteMenu(id);
    await loadMenus();
  }

  Future<void> deleteMenuImage(String fileName) async {
    await SuperbaseService().deleteMenuImage(fileName);
    await loadMenus();
  }
}

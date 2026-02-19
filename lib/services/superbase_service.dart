import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuperbaseService {

  final supabase = Supabase.instance.client;

  Future<String?> uploadMenuImage(Uint8List? imageFile, String name) async {
    try {
    final String fileName = "$name.jpeg";

      await supabase.storage
          .from('menu_images')
          .uploadBinary(fileName, imageFile!);

      final publicUrl = supabase.storage
          .from('menu_images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  Future<String?> updateMenuImage(Uint8List? imageFile, String name) async {
    try {

    final fileName = "$name.jpeg";

      await supabase.storage
          .from('menu_images')
          .updateBinary(fileName, imageFile!, fileOptions: const FileOptions(
            upsert: true, 
            ),
          );

      final publicUrl = supabase.storage
          .from('menu_images')
          .getPublicUrl(fileName);

      return "$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}";
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  Future<void> deleteMenuImage(String name) async {
    try {
      final fileName = "$name.jpeg";

      await supabase.storage
          .from('menu_images')
          .remove([fileName]
          );

    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  // Future<void> addMenu(MenuModel menu, String docId) async {
  //   await FirebaseFirestore.instance.collection('menu').doc(docId).set(menu.toMap());
  // }

  // Future<void> updateMenu(String id, MenuModel menu) async {
  //   await FirebaseFirestore.instance.collection('menu').doc(id).update(menu.toMap());
  // }

  // Future<void> deleteMenu(String id) async {
  //   await FirebaseFirestore.instance.collection('menu').doc(id).delete();
  // }

  // Future<List<MenuModel>> getAllMenu() async {
  //   final snapshot = await FirebaseFirestore.instance.collection('menu').get();
    
  //   return snapshot.docs.map((doc) {
  //     return MenuModel.fromMap(doc.id, doc.data());
  //   }).toList();
  // }

}
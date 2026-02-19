// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:moriana_mobile/services/sqlite_service.dart';

// class MenuImageLoader {

//   static Future<void> insertAllMenuImages() async {
//     final firestore = FirebaseFirestore.instance;

//     // Ambil semua dokumen menu
//     final snapshot = await firestore.collection("menu").get();

//     for (var doc in snapshot.docs) {
//       final menuId = doc.id;

//       final assetPath = "assets/images/$menuId.jpeg";

//       try {
//         // Load gambar dari assets
//         final byteData = await rootBundle.load(assetPath);
//         final Uint8List bytes = byteData.buffer.asUint8List();

//         // Simpan ke SQLite
//         await SQLiteService().saveMenuImage(menuId, bytes);

//         debugPrint("✓ Gambar untuk menu $menuId berhasil dimasukkan ke SQLite");
//       } catch (e) {
//         debugPrint("⚠ Gambar $assetPath tidak ditemukan");
//       }
//     }

//     debugPrint("=== Semua gambar selesai diproses ===");
//   }
// }

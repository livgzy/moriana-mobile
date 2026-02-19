import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../services/sqlite_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  UserModel? userData;
  Uint8List? userImage;
  bool get isAdmin => userData?.status == "Admin";


  final FirestoreService _firestore = FirestoreService();
  final SQLiteService _sqlite = SQLiteService();

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    userData = await _firestore.getUser(uid);
    userImage = await _sqlite.getUserImage(uid);
    notifyListeners(); 
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _firestore.updateUser(updatedUser, uid);
    userData = updatedUser;
    notifyListeners();
  }

  Future<void> updateUserImage(Uint8List imageBytes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _sqlite.saveUserImage(uid, imageBytes);
    userImage = imageBytes;  
    notifyListeners();
  }
}

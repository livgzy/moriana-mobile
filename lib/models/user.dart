import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String username;
  final String alamat;
  final String noHp;
  final String status;
  final DateTime createdAt;


  UserModel({
    required this.email,
    required this.username,
    required this.alamat,
    required this.noHp,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'alamat': alamat,
      'noHp': noHp,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'],
      username: map['username'],
      alamat: map['alamat'],
      noHp: map['noHp'],
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
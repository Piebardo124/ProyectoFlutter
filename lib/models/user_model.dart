import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String address;
  final String phone;

  UserModel({
    required this.id,
    required this.email,
    this.displayName = '',
    this.address = '',
    this.phone = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'address': address,
      'phone': phone,
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}

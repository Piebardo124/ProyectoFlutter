import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String address;
  final String phone;
  final String calle;
  final String numExt;
  final String numInt;
  final String colonia;
  final String ciudad;
  final String estado;

  UserModel({
    required this.id,
    required this.email,
    this.displayName = '',
    this.address = '',
    this.phone = '',
    this.calle = '',
    this.numExt = '',
    this.numInt = '',
    this.colonia = '',
    this.ciudad = '',
    this.estado = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'address': address,
      'phone': phone,
      'calle': calle,
      'numExt': numExt,
      'numInt': numInt,
      'colonia': colonia,
      'ciudad': ciudad,
      'estado': estado,
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
      calle: data['calle'] ?? '',
      numExt: data['numExt'] ?? '',
      numInt: data['numInt'] ?? '',
      colonia: data['colonia'] ?? '',
      ciudad: data['ciudad'] ?? '',
      estado: data['estado'] ?? '',
    );
  }
}

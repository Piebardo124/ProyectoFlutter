import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:proyecto_flutter/models/order_model.dart';
import 'package:proyecto_flutter/models/product_model.dart';
import 'package:proyecto_flutter/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snaphsot = await _db.collection('products').get();

      return snaphsot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error al obtener productoss: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    } catch (e) {
      print('Error al obtener productos por categoría: $e');
      return [];
    }
  }

  // Guardar nuevo pedido
  Future<void> placeOrder(Order order) async {
    try {
      await _db.collection('orders').add(order.toJson());
    } catch (e) {
      print('Error al guardar el pedido: $e');
      throw Exception('No se pudo realizar el pedido');
    }
  }

  Stream<List<Order>> getOrderHistory(String userId) {
    try {
      return _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Order.fromSnapshot(doc)).toList(),
          );
    } catch (e) {
      print('Error al obtener historial de pedidos: $e');
      return Stream.value([]);
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final DocumentSnapshot doc = await _db
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:proyecto_flutter/models/product_model.dart';
import 'package:proyecto_flutter/models/order_model.dart';
import 'package:proyecto_flutter/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  bool _isLoading = false;

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  // Calculo de precio total
  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  bool get isLoading => _isLoading;

  //Añadir Productos a carrito
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          name: existingItem.name,
          price: existingItem.price,
          productId: existingItem.productId,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          name: product.name,
          price: product.price,
          productId: product.id,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // Reductor de cantidad de items
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          name: existingItem.name,
          price: existingItem.price,
          productId: existingItem.productId,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  //Elminar item completo
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Vacio de carrito
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Realizar pedido
  Future<void> checkout(
    String userId,
    FirestoreService firestoreService,
  ) async {
    if (_items.isEmpty) {
      throw Exception("El carrito esta vacio.");
    }

    _setLoading(true);

    try {
      final Order newOrder = Order(
        id: '',
        userId: userId,
        items: _items.values.toList(),
        totalPrice: totalPrice,
        timestamp: Timestamp.now(),
        status: 'Pendiente',
      );

      await firestoreService.placeOrder(newOrder);

      // Limpia carrito en caso de operacion Correcta
      clearCart();
    } catch (e) {
      print('Error en checkout: $e');
      throw Exception('No se pudo completar el pedido.');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

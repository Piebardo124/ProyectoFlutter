import 'package:flutter/material.dart';
import 'package:proyecto_flutter/models/product_model.dart';
import 'package:proyecto_flutter/services/firestore_service.dart';

enum ProductStatus { loading, loaded, error }

class ProductsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Product> _products = [];
  ProductStatus _status = ProductStatus.loading;
  String? _error;

  ProductsProvider() {
    fetchProducts();
  }

  List<Product> get products => _products;
  ProductStatus get status => _status;
  String? get error => _error;

  Map<String, List<Product>> get productsByCategory {
    final Map<String, List<Product>> map = {};
    for (var product in _products) {
      if (!map.containsKey(product.category)) {
        map[product.category] = [];
      }
      map[product.category]!.add(product);
    }
    return map;
  }

  List<String> get categories {
    return _products.map((p) => p.category).toSet().toList()..sort();
  }

  // Busca los productos en firebase
  Future<void> fetchProducts() async {
    _status = ProductStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _products = await _firestoreService.getProducts();

      _status = ProductStatus.loaded;
    } catch (e) {
      _error = 'Error en cargar productos: $e';
      _status = ProductStatus.error;
      print(_error);
    }
    notifyListeners();
  }
}

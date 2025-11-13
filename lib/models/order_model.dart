import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> item) {
    return CartItem(
      productId: item['productId'] ?? '',
      name: item['name'] ?? '',
      price: (item['price'] ?? 0.0).toDouble(),
      quantity: (item['quantity'] ?? 0).toInt(),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final Timestamp timestamp;
  final String status;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    this.status = 'Pendiente',
    required this.timestamp,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'timestamp': timestamp,
      'status': status,
    };
  }

  factory Order.fromSnapshot(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;

    var itemsList = data['items'] as List<dynamic>? ?? [];
    List<CartItem> cartItems = itemsList
        .map((itemMap) => CartItem.fromMap(itemMap as Map<String, dynamic>))
        .toList();

    return Order(
      id: snap.id,
      userId: data['userId'] ?? '',
      items: cartItems,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      status: data['status'] ?? 'Pendiente',
    );
  }
}

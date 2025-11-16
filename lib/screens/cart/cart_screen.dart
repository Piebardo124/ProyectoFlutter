import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/models/product_model.dart';
import 'package:proyecto_flutter/providers/auth_provider.dart';
import 'package:proyecto_flutter/providers/cart_provider.dart';
import 'package:proyecto_flutter/providers/products_provider.dart';
import 'package:proyecto_flutter/services/firestore_service.dart';
import 'package:proyecto_flutter/models/order_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text('Tu Carrito (${cart.itemCount})')),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Tu carrito está vacío.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : _buildCartList(context, cartItems),
          ),

          _buildSummary(context, cart),
        ],
      ),
    );
  }

  /// Constructor de lista de productos
  Widget _buildCartList(BuildContext context, List<CartItem> cartItems) {
    final allProducts = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).products;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (ctx, index) {
        final item = cartItems[index];

        final product = allProducts.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => Product(
            id: item.productId,
            name: item.name,
            price: item.price,
            description: '',
            imageUrl: '',
            category: '',
          ),
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: ListTile(
            // Imagen del producto
            leading: Image.asset(
              product.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.fastfood, size: 40),
            ),
            // Nombre del producto
            title: Text(item.name),
            subtitle: Text(
              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón de Restar (-)
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    cartProvider.removeSingleItem(item.productId);
                  },
                ),
                // Cantidad
                Text(
                  item.quantity.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                // Botón de Sumar (+)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Usamos el objeto Product completo
                    cartProvider.addItem(product);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context, CartProvider cart) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final firestoreService = FirestoreService();

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila del Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${cart.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Botón de Realizar Pedido
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (cart.isLoading || cart.items.isEmpty)
                  ? null
                  : () {
                      // Llama a la función de checkout
                      _checkout(
                        context,
                        authProvider.user?.uid,
                        cart,
                        firestoreService,
                      );
                    },
              child: cart.isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Realizar Pedido',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lógica para el checkout
  Future<void> _checkout(
    BuildContext context,
    String? userId,
    CartProvider cart,
    FirestoreService firestoreService,
  ) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar al usuario.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await cart.checkout(userId, firestoreService);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido realizado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}

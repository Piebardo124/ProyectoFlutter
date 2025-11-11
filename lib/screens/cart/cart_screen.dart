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
    // 1. Escuchar al CartProvider para la lista de items y el total
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text('Tu Carrito (${cart.itemCount})')),
      body: Column(
        children: [
          // 2. Construir la lista de items o mostrar un mensaje de "vacío"
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

          // 3. Mostrar el resumen del pedido (total y botón)
          _buildSummary(context, cart),
        ],
      ),
    );
  }

  /// Construye la lista de items en el carrito
  Widget _buildCartList(BuildContext context, List<CartItem> cartItems) {
    // Necesitamos la lista completa de productos para poder usar 'addItem' (+)
    final allProducts = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).products;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (ctx, index) {
        final item = cartItems[index];

        // Buscamos el objeto Product completo
        final product = allProducts.firstWhere(
          (p) => p.id == item.productId,
          // Si el producto no se encuentra (raro), usamos un producto 'dummy'
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
              product.imageUrl, // Asumiendo que es un asset
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              // Manejo de error si la imagen del asset no carga
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.fastfood, size: 40),
            ),
            // Nombre del producto
            title: Text(item.name),
            // Precio total por este item (precio * cantidad)
            subtitle: Text(
              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            ),
            // Botones para +/-/eliminar
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

  /// Construye el widget de resumen en la parte inferior
  Widget _buildSummary(BuildContext context, CartProvider cart) {
    // Instanciamos los servicios necesarios para el checkout
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final firestoreService = FirestoreService();

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -3), // Sombra en la parte superior
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Botón de Realizar Pedido
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Deshabilita el botón si está cargando o el carrito está vacío
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
              // Muestra un spinner si está cargando
              child: cart.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
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
    // Verifica que el ID de usuario exista
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
      // Llama al método checkout del provider
      await cart.checkout(userId, firestoreService);

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido realizado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Muestra cualquier error que ocurra
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}

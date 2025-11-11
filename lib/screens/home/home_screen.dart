import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/providers/products_provider.dart';
import 'package:proyecto_flutter/widgets/product_cart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Menú de Hamburguesas')),
      body: _buildBody(context, productsProvider),
    );
  }

  Widget _buildBody(BuildContext context, ProductsProvider productsProvider) {
    // 3. Manejar el estado de carga
    if (productsProvider.status == ProductStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productsProvider.status == ProductStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(productsProvider.error ?? 'Ocurrió un error'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => productsProvider.fetchProducts(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final categories = productsProvider.categories;
    final productsMap = productsProvider.productsByCategory;

    if (categories.isEmpty) {
      return const Center(
        child: Text('No hay productos disponibles por el momento.'),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((category) {
          final products = productsMap[category]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Título de la Categoría ---
              Text(
                category,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // --- Grid de Productos ---
              GridView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (ctx, index) {
                  return ProductCard(product: products[index]);
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }
}

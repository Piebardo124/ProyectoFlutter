import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_flutter/providers/products_provider.dart';
import 'package:proyecto_flutter/widgets/product_cart.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

    // Imagenes Carrusel
    final List<String> promoImagenes = [
      'assets/images/promo_combo.png',
      'assets/images/promo_burger_especial.png',
      'assets/images/promo_descuento.png',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 180.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              aspectRatio: 16 / 9,
            ),
            items: promoImagenes.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      print('Tocado: $imagePath');
                      if (imagePath.contains('promo_combo')) {
                      } else if (imagePath.contains('promo_burger_especial')) {
                      } else if (imagePath.contains('promo_descuento')) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¡Codigo de Descuento!'),
                            content: const Text('Usa el código: BURGER10'),
                            actions: [
                              TextButton(
                                child: const Text('Cerrar'),
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.map((category) {
                final products = productsMap[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titulo de Categoria
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Productos
                    GridView.builder(
                      itemCount: products.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.6,
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
          ),
        ],
      ),
    );
  }
}

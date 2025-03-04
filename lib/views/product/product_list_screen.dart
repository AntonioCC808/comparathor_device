import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:comparathor_device/providers/product_provider.dart';
import 'package:comparathor_device/views/product/product_detail_screen.dart';
import 'package:comparathor_device/views/product/add_product_screen.dart';
import 'package:comparathor_device/core/api_service.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ApiService apiService = ApiService();

  String sanitizeBase64(String base64String) {
    final regex = RegExp(r'data:image/[^;]+;base64,');
    return base64String.replaceAll(regex, '');
  }

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Products", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, "/home"),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              );

              if (result == true) {
                ref.invalidate(productProvider); // ✅ Refresh product list after adding
              }
            },
          ),
        ],
      ),
      body: productAsyncValue.when(
        data: (products) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return GestureDetector(
                onTap: () async {
                  bool? updatedOrDeleted = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(productId: product["id"]),
                    ),
                  );

                  if (updatedOrDeleted == true) {
                    ref.invalidate(productProvider); // ✅ Refresh list after edit/delete
                  }
                },
                child: Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: product["image_base64"] != null &&
                              product["image_base64"].isNotEmpty
                              ? Image.memory(
                            base64Decode(sanitizeBase64(product["image_base64"])),
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/default-product.png",
                                width: double.infinity,
                                fit: BoxFit.contain,
                              );
                            },
                          )
                              : Image.asset(
                            "assets/images/default-product.png",
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product["name"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            RatingBarIndicator(
                              rating: (product["score"] as num).toDouble(),
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "\$${product["price"]}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text("Failed to load products")),
      ),
    );
  }
}

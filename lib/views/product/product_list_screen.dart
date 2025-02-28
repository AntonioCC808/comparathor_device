import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/providers/product_provider.dart';
import 'package:comparathor_device/views/product/product_detail_screen.dart';
import 'package:comparathor_device/views/product/add_product_screen.dart';
import 'package:comparathor_device/views/product/edit_product_screen.dart';
import 'package:comparathor_device/views/comparison/select_products_screen.dart';
import 'package:comparathor_device/core/api_service.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ApiService apiService = ApiService();
  List<int> selectedProductIds = [];

  void deleteProduct(BuildContext context, WidgetRef ref, int productId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        await apiService.deleteProduct(productId);
        ref.invalidate(productProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete product")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddProductScreen()),
              );

              if (result != null) {
                ref.invalidate(productProvider);
              }
            },
          ),
        ],
      ),
      body: productAsyncValue.when(
        data: (products) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  bool isSelected = selectedProductIds.contains(product["id"]);

                  return ListTile(
                    title: Text(product["name"]),
                    subtitle: Text("Price: \$${product["price"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedProductIds.add(product["id"]);
                              } else {
                                selectedProductIds.remove(product["id"]);
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductScreen(
                                  productId: product["id"],
                                  initialProductData: product,
                                ),
                              ),
                            );

                            if (result == true) {
                              ref.invalidate(productProvider);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              deleteProduct(context, ref, product["id"]),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(productId: product["id"]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (selectedProductIds.length >= 2)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectProductsScreen(
                            selectedProductIds: selectedProductIds),
                      ),
                    );

                    if (result == true) {
                      ref.invalidate(productProvider);
                    }
                  },
                  icon: const Icon(Icons.compare),
                  label: const Text("Compare Selected Products"),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text("Failed to load products")),
      ),
    );
  }
}

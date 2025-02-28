import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/providers/product_provider.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:dio/dio.dart';

class SelectProductsScreen extends ConsumerStatefulWidget {
  final List<int> selectedProductIds; // ✅ Add this parameter

  const SelectProductsScreen({super.key, required this.selectedProductIds});

  @override
  _SelectProductsScreenState createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends ConsumerState<SelectProductsScreen> {
  final ApiService apiService = ApiService();
  bool isLoading = false;
  String? errorMessage;

  void createComparison() async {
    if (widget.selectedProductIds.length < 2) {
      setState(() {
        errorMessage = "Select at least 2 products";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await apiService.createComparison({
        "title": "New Comparison",
        "description": "Automatically generated comparison",
        "product_type_id": 1, // Adjust based on your actual product type
        "products": widget.selectedProductIds,
      });

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        errorMessage = "Failed to create comparison";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Select Products")),
      body: productAsyncValue.when(
        data: (products) => Column(
          children: [
            if (errorMessage != null)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  bool isSelected =
                      widget.selectedProductIds.contains(product["id"]);

                  return ListTile(
                    title: Text(product["name"]),
                    subtitle: Text("Price: \$${product["price"]}"),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          widget.selectedProductIds.remove(product["id"]);
                        } else {
                          widget.selectedProductIds.add(product["id"]);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: createComparison, child: Text("Compare")),
          ],
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Failed to load products")),
      ),
    );
  }
}

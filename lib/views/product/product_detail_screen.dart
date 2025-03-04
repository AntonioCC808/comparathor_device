import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../providers/product_provider.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ApiService apiService = ApiService();
  Map<String, dynamic>? product;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  void fetchProductDetails() async {
    try {
      Response response = await apiService.getProductDetails(widget.productId);
      setState(() {
        product = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load product details";
        isLoading = false;
      });
    }
  }

  void deleteProduct() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")
          ),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        await apiService.deleteProduct(widget.productId);
        Navigator.pop(context, true); // Ensure it sends `true` back after deletion
      } catch (e) {
        setState(() => errorMessage = "Failed to delete product");
      }
    }
  }


  void editProduct() async {
    if (product == null) return;

    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          productId: widget.productId,
          initialProductData: product!,
        ),
      ),
    );

    if (updated == true) {
      fetchProductDetails(); // Reload current product details
      ref.invalidate(productProvider); // Refresh product list screen
    }
  }


  String sanitizeBase64(String base64String) {
    final regex = RegExp(r'data:image/[^;]+;base64,');
    return base64String.replaceAll(regex, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Product Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: editProduct,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: deleteProduct,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product!["image_base64"] != null &&
                  product!["image_base64"].isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.memory(
                      base64Decode(sanitizeBase64(product!["image_base64"])),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/default-product.png",
                          width: double.infinity,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(product!["name"],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 10),
              Text("Brand: ${product!["brand"]}",
                  style: const TextStyle(fontSize: 18, color: Colors.black)),
              const SizedBox(height: 10),
              Text("Price: \$${product!["price"]}",
                  style: const TextStyle(fontSize: 18, color: Colors.black)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Score: ",
                      style: TextStyle(fontSize: 18, color: Colors.black)),
                  RatingBarIndicator(
                    rating: product!["score"].toDouble(),
                    itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 25.0,
                    direction: Axis.horizontal,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Attributes:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: product!["product_metadata"].length,
                itemBuilder: (context, index) {
                  final attribute = product!["product_metadata"][index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(attribute["attribute"],
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Value: ${attribute["value"]}",
                                  style: const TextStyle(fontSize: 14, color: Colors.black)),
                            ],
                          ),
                          RatingBarIndicator(
                            rating: attribute["score"].toDouble(),
                            itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

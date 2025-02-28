import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:dio/dio.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Details")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product!["name"],
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("Brand: ${product!["brand"]}",
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Text("Price: \$${product!["price"]}",
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Text("Score: ${product!["score"]}/5",
                          style: TextStyle(fontSize: 18)),
                      SizedBox(height: 20),
                      Text("Attributes:",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: product!["product_metadata"].length,
                          itemBuilder: (context, index) {
                            final attribute =
                                product!["product_metadata"][index];
                            return ListTile(
                              title: Text(attribute["attribute"]),
                              subtitle: Text("Value: ${attribute["value"]}"),
                              trailing: Text("Score: ${attribute["score"]}/5"),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/providers/product_provider.dart';
import 'package:comparathor_device/core/api_service.dart';

class SelectProductsScreen extends ConsumerStatefulWidget {
  final List<int> selectedProductIds;

  const SelectProductsScreen({super.key, required this.selectedProductIds});

  @override
  _SelectProductsScreenState createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends ConsumerState<SelectProductsScreen> {
  final ApiService apiService = ApiService();
  bool isLoading = false;
  String? errorMessage;
  String? selectedProductType;
  List<dynamic> productTypes = [];
  List<dynamic> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    fetchProductTypes();
  }

  void fetchProductTypes() async {
    setState(() => isLoading = true);
    try {
      final types = await apiService.fetchProductTypes();
      setState(() {
        productTypes = types;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load product types";
        isLoading = false;
      });
    }
  }

  void fetchProducts(String productTypeId) async {
    setState(() => isLoading = true);
    try {
      final allProducts = await apiService.fetchProducts();
      setState(() {
        filteredProducts = allProducts
            .where((product) =>
                product['product_type_id'].toString() == productTypeId)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load products";
        isLoading = false;
      });
    }
  }

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
        "product_type_id": selectedProductType,
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Products"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedProductType,
              decoration: InputDecoration(
                labelText: "Select Product Type",
                border: OutlineInputBorder(),
              ),
              items: productTypes
                  .map((type) => DropdownMenuItem(
                        value: type['id'].toString(),
                        child: Text(type['name']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedProductType = value;
                  fetchProducts(value!);
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? Center(child: Text("No products available for this type"))
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          bool isSelected =
                              widget.selectedProductIds.contains(product["id"]);

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.blue[100]!,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              title: Text(product["name"],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              subtitle: Text("Price: \$${product["price"]}"),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    widget.selectedProductIds
                                        .remove(product["id"]);
                                  } else {
                                    widget.selectedProductIds
                                        .add(product["id"]);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
          ),
          if (errorMessage != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: createComparison,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Compare"),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:dio/dio.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;
  final Map<String, dynamic> initialProductData;

  const EditProductScreen(
      {super.key, required this.productId, required this.initialProductData});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController brandController;
  late TextEditingController priceController;
  late TextEditingController scoreController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.initialProductData["name"]);
    brandController =
        TextEditingController(text: widget.initialProductData["brand"]);
    priceController = TextEditingController(
        text: widget.initialProductData["price"].toString());
    scoreController = TextEditingController(
        text: widget.initialProductData["score"].toString());
  }

  void updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await apiService.updateProduct(widget.productId, {
        "name": nameController.text,
        "brand": brandController.text,
        "price": double.parse(priceController.text),
        "score": double.parse(scoreController.text),
      });

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        errorMessage = "Failed to update product";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Product")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (errorMessage != null)
                Text(errorMessage!, style: TextStyle(color: Colors.red)),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Product Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter product name" : null,
              ),
              TextFormField(
                controller: brandController,
                decoration: InputDecoration(labelText: "Brand"),
                validator: (value) => value!.isEmpty ? "Enter brand" : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter price" : null,
              ),
              TextFormField(
                controller: scoreController,
                decoration: InputDecoration(labelText: "Score (0-5)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter score" : null,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: updateProduct, child: Text("Update Product")),
            ],
          ),
        ),
      ),
    );
  }
}

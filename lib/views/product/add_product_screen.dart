import 'package:flutter/material.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:dio/dio.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;

  void addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      Response response = await apiService.addProduct({
        "name": nameController.text,
        "brand": brandController.text,
        "price": double.parse(priceController.text),
        "score": double.parse(scoreController.text),
        "product_type_id": 1, // Change based on your actual product type
      });

      Navigator.pop(context, response.data);
    } catch (e) {
      setState(() {
        errorMessage = "Failed to add product";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Product")),
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
                      onPressed: addProduct, child: Text("Add Product")),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:comparathor_device/core/api_service.dart';

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
  String? selectedProductType;
  List<Map<String, dynamic>> productTypes = [];
  List<Map<String, dynamic>> attributes = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;
  String? imageBase64;

  @override
  void initState() {
    super.initState();
    fetchProductTypes();
  }

  Future<void> fetchProductTypes() async {
    try {
      Response response = await apiService.getProductTypes();
      setState(() {
        productTypes = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch product types";
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        imageBase64 = base64Encode(bytes);
      });
    }
  }

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
        "image_base64": imageBase64,
        "product_type": selectedProductType,
        "product_metadata": attributes,
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
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Product Type",
                  border: OutlineInputBorder(),
                ),
                value: selectedProductType,
                items: productTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type["id"].toString(),
                    child: Text(type["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProductType = value;
                    final selectedType = productTypes.firstWhere((type) => type["id"].toString() == value);
                    attributes = (selectedType["metadata_schema"] as Map<String, dynamic>).entries.map((entry) {
                      return {
                        "attribute": entry.key.toString(),
                        "type": entry.value["type"],
                        "value": "",
                        "score": "",
                      };
                    }).toList();
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter product name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: brandController,
                decoration: const InputDecoration(
                  labelText: "Brand",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter brand" : null,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text("Upload Image"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Take Photo"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (imageBase64 != null)
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Image.memory(
                    base64Decode(imageBase64!),
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Add Product"),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

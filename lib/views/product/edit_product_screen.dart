import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:comparathor_device/core/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;
  final Map<String, dynamic> initialProductData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.initialProductData,
  });

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController brandController;
  late TextEditingController priceController;
  late TextEditingController totalScoreController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  bool isLoading = false;
  String? errorMessage;
  String? imageBase64;
  File? _selectedImage;
  List<Map<String, dynamic>> attributes = [];
  List<TextEditingController> valueControllers = [];
  List<TextEditingController> scoreControllers = [];

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.initialProductData["name"] ?? "");
    brandController =
        TextEditingController(text: widget.initialProductData["brand"] ?? "");
    priceController = TextEditingController(
        text: widget.initialProductData["price"]?.toString() ?? "0.0");
    totalScoreController = TextEditingController(
        text: widget.initialProductData["score"]?.toString() ?? "0.0");

    imageBase64 = widget.initialProductData["image_base64"];

    // Initialize attributes and controllers
    attributes =
        (widget.initialProductData["product_metadata"] as List<dynamic>?)
            ?.map((attr) =>
        {
          "attribute": attr["attribute"] ?? "Unknown",
          "value": attr["value"] ?? "",
          "score": attr["score"] != null ? attr["score"].toDouble() : 0.0,
        })
            .toList() ??
            [];

    valueControllers = attributes.map((attr) =>
        TextEditingController(text: attr["value"].toString())).toList();
    scoreControllers = attributes.map((attr) =>
        TextEditingController(text: attr["score"].toString())).toList();
  }
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final String base64String = base64Encode(bytes);

      setState(() {
        _selectedImage = File(image.path);
        imageBase64 = "data:image/png;base64,$base64String"; // Add correct prefix
      });

      print("Base64 Encoded Image: $imageBase64"); // Debugging output
    }
  }

  void updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final double? price = double.tryParse(priceController.text);
      final double? totalScore = double.tryParse(totalScoreController.text);

      if (price == null || totalScore == null || totalScore < 0 ||
          totalScore > 5) {
        setState(() {
          errorMessage = "Invalid price or total score (0-5)";
          isLoading = false;
        });
        return;
      }

      // Update attributes list with user input
      for (int i = 0; i < attributes.length; i++) {
        attributes[i]["value"] = valueControllers[i].text;
        attributes[i]["score"] =
            double.tryParse(scoreControllers[i].text) ?? 0.0;
      }

      final Map<String, dynamic> updatedProductData = {
        "name": nameController.text,
        "brand": brandController.text,
        "price": priceController.text,
        "score": totalScoreController.text,
        "image_base64": imageBase64,
        "product_metadata": attributes,
      };

      await apiService.updateProduct(widget.productId, updatedProductData);

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Product"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),

                // General Data Section
                _buildSection(
                  title: "General Data",
                  children: [
                    _buildTextField("Product Name", nameController),
                    _buildTextField("Brand", brandController),
                    _buildTextField("Price", priceController, isNumeric: true),
                    _buildTextField("Total Score (0-5)", totalScoreController,
                        isNumeric: true),
                  ],
                ),

                const SizedBox(height: 20),

                // Image Section
                _buildSection(
                  title: "Product Image",
                  children: [
                    _selectedImage != null
                        ? Image.file(_selectedImage!, height: 200)
                        : (imageBase64 != null && imageBase64!.isNotEmpty)
                        ? Image.memory(base64Decode(imageBase64!.split(',').last), height: 200)
                        : const Icon(Icons.image, size: 100, color: Colors.blue),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Take Photo"),
                            onPressed: () => pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text("Upload Image"),
                            onPressed: () => pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Attributes Section
                if (attributes.isNotEmpty)
                  _buildSection(
                    title: "Attributes",
                    children: List.generate(attributes.length, (i) =>
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(attributes[i]["attribute"],
                                style: const TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue)),
                            const SizedBox(height: 5),
                            _buildTextField("Value", valueControllers[i]),
                            _buildTextField("Score (0-5)", scoreControllers[i],
                                isNumeric: true),
                            const SizedBox(height: 15),
                          ],
                        )),
                  ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: updateProduct,
                  child: isLoading ? const CircularProgressIndicator(
                      color: Colors.white) : const Text("Update Product"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          const Divider(color: Colors.blue),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label, border: OutlineInputBorder()),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}

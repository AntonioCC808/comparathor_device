import 'dart:convert';
import 'dart:io';
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
  final TextEditingController totalScoreController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  String? selectedProductType;
  List<Map<String, dynamic>> productTypes = [];
  List<Map<String, dynamic>> attributes = [];

  bool isLoading = false;
  String? errorMessage;
  String? imageBase64;
  File? _selectedImage;


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
      final String base64String = base64Encode(bytes);

      setState(() {
        _selectedImage = File(image.path);
        imageBase64 = "data:image/png;base64,$base64String";  // ✅ Add prefix
      });

      print("Base64 Encoded Image: $imageBase64");  // Debugging output
    }
  }


  void addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final double? price = double.tryParse(priceController.text);
      final double? totalScore = double.tryParse(totalScoreController.text);

      if (price == null) {
        setState(() {
          errorMessage = "Invalid price format";
          isLoading = false;
        });
        return;
      }

      // Ensure `score` is sent as a float and within valid range
      List<Map<String, dynamic>> formattedAttributes = attributes.map((attr) {
        return {
          "attribute": attr["attribute"],
          "value": attr["value"] ?? "",
          "score": double.tryParse(attr["score"] ?? "0") ?? 0.0, // 🔥 Ensure it's a float
        };
      }).toList();

      final Map<String, dynamic> productData = {
        "name": nameController.text,
        "brand": brandController.text,
        "price": price,
        "score": totalScore,
        "image_base64": imageBase64,
        "product_type_id": selectedProductType,
        "product_metadata": formattedAttributes,
      };

      Response response = await apiService.addProduct(productData);

      Navigator.pop(context, true);
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
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.blue, // Primary blue color
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
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),

                // General Data Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Light blue background
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("General Data",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const Divider(color: Colors.blue),

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
                            final selectedType = productTypes.firstWhere(
                                  (type) => type["id"].toString() == value,
                              orElse: () => {},
                            );

                            if (selectedType.isNotEmpty &&
                                selectedType["metadata_schema"] != null) {
                              attributes = (selectedType["metadata_schema"]
                              as Map<String, dynamic>)
                                  .entries
                                  .map((entry) {
                                return {
                                  "attribute": entry.key.toString(),
                                  "value": "",
                                  "score": "",
                                };
                              }).toList();
                            } else {
                              attributes = [];
                            }
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
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter price" : null,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      // Total Score Field
                      TextFormField(
                        controller: totalScoreController,
                        decoration: const InputDecoration(
                          labelText: "Total Score (0-5)",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final double? score = double.tryParse(value!);
                          if (score == null || score < 0 || score > 5) {
                            return "Enter a valid score (0-5)";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Attributes Section
                if (attributes.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Attributes",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const Divider(color: Colors.blue),

                        ...attributes.map((attr) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(attr["attribute"] ?? "Unknown Attribute",
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue)),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: "Value",
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        attr["value"] = value;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: "Score (0-5)",
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        final double? score = double.tryParse(value);
                                        if (score != null && score >= 0 && score <= 5) {
                                          attr["score"] = value;
                                        } else {
                                          attr["score"] = "";
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Score must be between 0 and 5"),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                // PHOTO UPLOAD SECTION
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Upload Product Image",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const Divider(color: Colors.blue),

                      _selectedImage != null
                          ? Image.file(_selectedImage!, height: 200)
                          : (imageBase64 != null && imageBase64!.isNotEmpty)
                          ? Image.memory(base64Decode(imageBase64!.split(',').last), height: 200)  // ✅ Extracts actual base64 data
                          : const Text("No image selected", style: TextStyle(color: Colors.blue)),


                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Take Photo"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              onPressed: () => pickImage(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.photo_library),
                              label: const Text("Upload Image"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              onPressed: () => pickImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add Product"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

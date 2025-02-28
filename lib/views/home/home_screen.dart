import 'package:flutter/material.dart';
import 'package:comparathor_device/views/product/product_list_screen.dart';
import 'package:comparathor_device/views/product/add_product_screen.dart';
import 'package:comparathor_device/views/comparison/comparison_list_screen.dart';
import 'package:comparathor_device/views/comparison/select_products_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGridItem(context, Icons.list, "List Products", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductListScreen(),
              ),
            );
          }),
          _buildGridItem(context, Icons.add, "Add Product", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProductScreen(),
              ),
            );
          }),
          _buildGridItem(context, Icons.compare, "List Comparisons", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ComparisonListScreen(),
              ),
            );
          }),
          _buildGridItem(context, Icons.add_chart, "Add Comparison", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectProductsScreen(selectedProductIds: []), // ✅ Ensuring required parameter
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

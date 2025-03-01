import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ Import for SVG logo
import 'package:comparathor_device/views/product/product_list_screen.dart';
import 'package:comparathor_device/views/product/add_product_screen.dart';
import 'package:comparathor_device/views/comparison/comparison_list_screen.dart';
import 'package:comparathor_device/views/comparison/select_products_screen.dart';
import 'package:comparathor_device/views/auth/login_screen.dart';
import 'package:comparathor_device/views/home/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Welcome Section with Logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Adds depth effect
                ),
              ],
            ),
            child: Column(
              children: [
                // App Logo
                SvgPicture.asset(
                  "assets/images/app-logo.svg", // ✅ Ensure this path is correct
                  height: 80,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome to Comparathor!",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Compare and manage your products with ease!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Grid Layout for Features
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              childAspectRatio: 1.1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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
                      builder: (context) => SelectProductsScreen(selectedProductIds: []),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Custom Grid Item with Styling
  Widget _buildGridItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6, // Adds depth
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadowColor: Colors.blue.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white, // Background color
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

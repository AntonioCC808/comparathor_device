import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Import Riverpod
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:comparathor_device/core/api_service.dart';
import 'package:comparathor_device/views/auth/login_screen.dart';
import 'package:comparathor_device/views/auth/register_screen.dart';
import 'package:comparathor_device/views/home/home_screen.dart';
import 'package:comparathor_device/views/product/product_list_screen.dart';
import 'package:comparathor_device/views/product/product_detail_screen.dart';
import 'package:comparathor_device/views/product/add_product_screen.dart';
import 'package:comparathor_device/views/product/edit_product_screen.dart';
import 'package:comparathor_device/views/comparison/comparison_list_screen.dart';
import 'package:comparathor_device/views/comparison/comparison_detail_screen.dart';
import 'package:comparathor_device/views/comparison/select_products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkIfLoggedIn() async {
    String? token = await ApiService().getToken();
    return token != null; // Returns true if logged in, false otherwise
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparathor Device',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: checkIfLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()), // Show loading spinner while checking
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
            return const LoginScreen(); // If error or not logged in, show login
          }

          return const HomeScreen(); // If token exists, go to home
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/products': (context) => const ProductListScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/comparisons': (context) => const ComparisonListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product-detail' && settings.arguments is int) {
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: settings.arguments as int),
          );
        }
        if (settings.name == '/edit-product' && settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditProductScreen(
              productId: args['productId'],
              initialProductData: args['initialProductData'],
            ),
          );
        }
        if (settings.name == '/comparison-detail' && settings.arguments is int) {
          return MaterialPageRoute(
            builder: (context) => ComparisonDetailScreen(comparisonId: settings.arguments as int),
          );
        }
        if (settings.name == '/select-products' && settings.arguments is List<int>) {
          return MaterialPageRoute(
            builder: (context) => SelectProductsScreen(selectedProductIds: settings.arguments as List<int>),
          );
        }
        return null;
      },
    );
  }
}

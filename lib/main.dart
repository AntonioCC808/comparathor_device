import 'package:flutter/material.dart';
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

  String? token = await ApiService().getToken();
  runApp(MyApp(startingScreen: token != null ? HomeScreen() : LoginScreen()));
}

class MyApp extends StatelessWidget {
  final Widget startingScreen;
  MyApp({required this.startingScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparathor Device',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => startingScreen,
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/products': (context) => ProductListScreen(),
        '/add-product': (context) => AddProductScreen(),
        '/comparisons': (context) => ComparisonListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product-detail') {
          final int productId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
          );
        }
        if (settings.name == '/edit-product') {
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => EditProductScreen(
              productId: args['productId'],
              initialProductData: args['initialProductData'],
            ),
          );
        }
        if (settings.name == '/comparison-detail') {
          final int comparisonId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) =>
                ComparisonDetailScreen(comparisonId: comparisonId),
          );
        }
        if (settings.name == '/select-products') {
          final List<int> selectedProductIds = settings.arguments as List<int>;
          return MaterialPageRoute(
            builder: (context) =>
                SelectProductsScreen(selectedProductIds: selectedProductIds),
          );
        }
        return null;
      },
    );
  }
}

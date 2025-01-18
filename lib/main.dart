import 'package:flutter/material.dart';
import 'screens/main_dashboard.dart';
import 'screens/sign_in.dart';
import 'screens/my_products.dart';
import 'screens/my_comparisons.dart';
import 'screens/add_products.dart';
import 'screens/add_comparison.dart';
import 'screens/settings.dart';

void main() {
  runApp(ComparathorApp());
}

class ComparathorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparathor',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Colors.indigo),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
          labelLarge: TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.indigo,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
        cardTheme: CardTheme(
          margin: EdgeInsets.all(10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.grey[100],
          labelStyle:
              TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
          prefixIconColor: Colors.indigo,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainDashboard(),
        '/signin': (context) => SignInScreen(),
        '/myproducts': (context) => MyProductsScreen(),
        '/mycomparisons': (context) => MyComparisonsScreen(),
        '/addproduct': (context) => AddProductScreen(),
        '/addcomparison': (context) => AddComparisonScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

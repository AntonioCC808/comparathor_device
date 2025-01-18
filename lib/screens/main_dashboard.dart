import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class MainDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Comparathor Dashboard'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/signin'),
              child: Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/myproducts'),
              child: Text('My Products'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/mycomparisons'),
              child: Text('My Comparisons'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/addproduct'),
              child: Text('Add New Product'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/addcomparison'),
              child: Text('Add New Comparison'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

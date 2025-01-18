import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MainDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and Title
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/app-logo.svg',
                        height: 60.0,
                        semanticsLabel: 'App Logo',
                      ),
                      SizedBox(width: 10),
                      Text(
                        'COMPARATHOR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome, cuadradot',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),

              // Navigation Buttons
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDashboardButton(
                        context,
                        title: 'My Comparisons',
                        onPressed: () {
                          Navigator.pushNamed(context, '/mycomparisons');
                        },
                      ),
                      _buildDashboardButton(
                        context,
                        title: 'My Products',
                        onPressed: () {
                          Navigator.pushNamed(context, '/myproducts');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDashboardButton(
                        context,
                        title: 'New Comparison',
                        onPressed: () {
                          Navigator.pushNamed(context, '/addcomparison');
                        },
                      ),
                      _buildDashboardButton(
                        context,
                        title: 'New Product',
                        onPressed: () {
                          Navigator.pushNamed(context, '/addproduct');
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Settings Button
              IconButton(
                icon: Icon(Icons.settings, size: 40.0, color: Colors.indigo),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Button Builder
  Widget _buildDashboardButton(BuildContext context,
      {required String title, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.indigo,
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

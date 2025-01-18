import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignInScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                SvgPicture.asset(
                  'assets/images/app-logo.svg',
                  height: 80.0,
                  semanticsLabel: 'App Logo',
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome to Comparathor',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    // Basic validation (can be improved later)
                    if (_emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      Navigator.pushReplacementNamed(context, '/');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all fields')),
                      );
                    }
                  },
                  child: Text('Log In'),
                ),

                // Optional: Forgot Password or Sign Up Links
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Navigate to a Forgot Password Screen (if implemented)
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class MyProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My Products'),
      body: ListView.builder(
        itemCount: 5, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.devices, color: Colors.indigo),
              title: Text('Product ${index + 1}'),
              subtitle: Text('Description of Product ${index + 1}'),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.indigo),
            ),
          );
        },
      ),
    );
  }
}

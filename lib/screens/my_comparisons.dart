import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class MyComparisonsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My Comparisons'),
      body: ListView.builder(
        itemCount: 3, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.compare_arrows, color: Colors.indigo),
              title: Text('Comparison ${index + 1}'),
              subtitle: Text('Details of Comparison ${index + 1}'),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.indigo),
            ),
          );
        },
      ),
    );
  }
}

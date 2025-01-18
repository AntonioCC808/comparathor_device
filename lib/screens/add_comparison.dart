import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class AddComparisonScreen extends StatefulWidget {
  @override
  _AddComparisonScreenState createState() => _AddComparisonScreenState();
}

class _AddComparisonScreenState extends State<AddComparisonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _comparisonNameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Add New Comparison'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _comparisonNameController,
                decoration: InputDecoration(
                  labelText: 'Comparison Name',
                  prefixIcon: Icon(Icons.text_fields),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a comparison name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _comparisonNameController.text;
                    print('Comparison Saved: Name=$name');
                  }
                },
                child: Text('Save Comparison'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

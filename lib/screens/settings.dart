import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              title: Text('Update Email'),
              trailing: Icon(Icons.email, color: Colors.indigo),
              onTap: () {},
            ),
            ListTile(
              title: Text('Change Password'),
              trailing: Icon(Icons.lock, color: Colors.indigo),
              onTap: () {},
            ),
            ListTile(
              title: Text('Change Username'),
              trailing: Icon(Icons.person, color: Colors.indigo),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

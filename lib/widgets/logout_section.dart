import 'package:flutter/material.dart';
import '../pages/login_page.dart';

class LogoutSection extends StatelessWidget {
  const LogoutSection({super.key});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
      ),
    );
  }
}

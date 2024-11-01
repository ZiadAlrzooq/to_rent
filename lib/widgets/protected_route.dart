import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Check if the user is logged in
    if (authProvider.user == null) {
      // If not logged in, redirect to the login page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Container(); // Return an empty container while redirecting
    }

    // If logged in, return the child widget
    return child;
  }
}

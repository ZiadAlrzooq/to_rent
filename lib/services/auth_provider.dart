import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      print('User is logging !!!!: $_user');
      notifyListeners();
    });
  }

  User? get user => _user;
}

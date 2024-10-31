import 'package:flutter/material.dart';
import 'package:to_rent/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget{
  final Auth auth = Auth();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

}
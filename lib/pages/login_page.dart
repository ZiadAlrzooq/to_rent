// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:to_rent/services/auth_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoggingIn = false;

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoggingIn = true;
      });

      final String email = emailController.text;
      final String password = passwordController.text;
      await AuthService().signInWithEmailAndPassword(email, password);
      setState(() {
        isLoggingIn = false;
      });

      // Handle login action
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, authProvider, child) {
      if (authProvider.user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/posts');
        });
        return Container(); // Return an empty container while redirecting
      }
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: GradientBackground(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    InputField(
                      controller: emailController,
                      label: 'البريد الإلكتروني',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'الرجاء إدخال بريد إلكتروني صالح';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    InputField(
                      controller: passwordController,
                      label: 'كلمة المرور',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال كلمة المرور';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: 'تسجيل الدخول',
                      onPressed: login,
                      color: Colors.orange[700]!,
                      isLoading: isLoggingIn,
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: 'إنشاء حساب',
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      color: Colors.teal[600]!,
                      isLoading: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

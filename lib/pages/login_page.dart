// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:to_rent/services/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
/* invalid-email:
Thrown if the email address is not valid.
user-disabled:
Thrown if the user corresponding to the given email has been disabled.
user-not-found:
Thrown if there is no user corresponding to the given email.
wrong-password:
Thrown if the password is invalid for the given email, or the account corresponding to the email does not have a password set. */

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoggingIn = false;
  bool isInvalidEmail = false;
  bool isUserDisabled = false;
  bool isUserNotFound = false;
  bool isWrongPassword = false;
  void login() async {
    setState(() {
      isInvalidEmail = false;
      isUserDisabled = false;
      isUserNotFound = false;
      isWrongPassword = false;
    });
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoggingIn = true;
      });

      final String email = emailController.text;
      final String password = passwordController.text;
      try {
        await AuthService().signInWithEmailAndPassword(email, password);
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'invalid-email') {
            setState(() {
              isInvalidEmail = true;
            });
          } else if (e.code == 'user-disabled') {
            setState(() {
              isUserDisabled = true;
            });
          } else if (e.code == 'user-not-found') {
            setState(() {
              isUserNotFound = true;
            });
          } else if (e.code == 'wrong-password') {
            setState(() {
              isWrongPassword = true;
            });
          }
        }
        _formKey.currentState!.validate(); // Trigger validation to show error
      }
      setState(() {
        isLoggingIn = false;
      });
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
                        if (isInvalidEmail) {
                          return 'البريد الإلكتروني غير صحيح';
                        }
                        if (isUserDisabled) {
                          return 'المستخدم معطل';
                        }
                        if (isUserNotFound) {
                          return 'المستخدم غير موجود';
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
                        if (isWrongPassword) {
                          return 'كلمة المرور غير صحيحة';
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
                      text: 'العودة',
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      color: Colors.teal[600]!,
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

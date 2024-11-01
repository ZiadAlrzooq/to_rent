// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'إنشاء حساب',
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    InputField(
                      controller: usernameController,
                      label: 'اسم المستخدم',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم المستخدم';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    InputField(
                      controller: emailController,
                      label: 'البريد الإلكتروني',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
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
                    SizedBox(height: 10),
                    InputField(
                      controller: confirmPasswordController,
                      label: 'تأكيد كلمة المرور',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال تأكيد كلمة المرور';
                        }
                        if (value != passwordController.text) {
                          return 'كلمة المرور غير متطابقة';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: 'تسجيل الحساب',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle registration action
                        }
                      },
                      color: Colors.orange[700]!,
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: 'العودة',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.teal[600]!,
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

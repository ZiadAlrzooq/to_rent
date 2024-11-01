// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تسجيل الدخول',
                  style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle login action
                    }
                  },
                  color: Colors.orange[700]!,
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: 'إنشاء حساب',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  color: Colors.teal[600]!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

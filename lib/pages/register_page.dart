import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import 'package:to_rent/services/auth_service.dart';
import 'package:to_rent/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:to_rent/services/firestore_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isRegistering = false;
  bool _isUsernameTaken = false;
  bool _isEmailTaken = false;
  bool _isWeakPassword = false;
  bool _isInvalidEmail = false;
  void register() async {
    setState(() {
      _isUsernameTaken = false;
      _isEmailTaken = false;
      _isWeakPassword = false;
      _isInvalidEmail = false;
    });
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });
      final String username = usernameController.text;
      final String email = emailController.text;
      final String password = passwordController.text;
      // Check if the username is taken
      bool isTaken = await FirestoreService().isUsernameTaken(username);
      setState(() {
        _isUsernameTaken = isTaken;
        _isRegistering = false;
      });
      if (_isUsernameTaken) {
        _formKey.currentState!.validate(); // Trigger validation to show error
        return;
      }
      try {
        await AuthService().registerWithEmailAndPassword(username, email, password);
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'email-already-in-use') {
            setState(() {
              _isEmailTaken = true;
            });
          } else if (e.code == 'unknown') { // Firebase error code for weak password
            setState(() {
              _isWeakPassword = true;
            });
          } else if (e.code == 'invalid-email') {
            setState(() {
              _isInvalidEmail = true;
            });
          } else {
            print('Error: ' + e.toString());
          }
        } else {
          print('Error: ' + e.toString());
        }
        _formKey.currentState!.validate(); // Trigger validation to show error
      }
      setState(() {
        _isRegistering = false;
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
                          if (value.length < 3) {
                            return 'يجب أن يحتوي اسم المستخدم على 3 أحرف على الأقل';
                          }
                          if (value.length > 20) {
                            return 'يجب أن يحتوي اسم المستخدم على 20 حرف على الأكثر';
                          }
                          if (_isUsernameTaken) {
                            return 'الاسم مستخدم من قبل. الرجاء اختيار اسم آخر';
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
                          if (_isEmailTaken) {
                            return 'البريد الإلكتروني مستخدم من قبل';
                          }
                          if (_isInvalidEmail) {
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
                          if (_isWeakPassword) {
                            return 'كلمة المرور ضعيفة. يجب أن تحتوي على 8 أحرف على الأقل، حرف كبير، حرف صغير، ورمز خاص';
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
                          onPressed: register,
                          color: Colors.orange[700]!,
                          isLoading: _isRegistering),
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
    });
  }
}

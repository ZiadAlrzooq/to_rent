import 'package:flutter/material.dart';
import '../widgets/background_widget.dart';
import '../widgets/custom_button.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'تسجيل الدخول',
              style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
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
    );
  }
}

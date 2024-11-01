// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/background_widget.dart';
import '../widgets/custom_button.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'مرحبا بك بـ',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            SizedBox(
                width: 160.0,
                child: TextAnimator(
                  'ToRent',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  incomingEffect: WidgetTransitionEffects.incomingOffsetThenScale(delay: Duration(milliseconds: 500), duration: Duration(milliseconds: 1000)),
                )),
            SizedBox(height: 60),
            CustomButton(
              text: 'تسجيل الدخول',
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              color: Colors.teal[600]!,
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'إنشاء حساب',
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              color: Colors.orange[700]!,
            ),
          ],
        ),
      ),
    );
  }
}

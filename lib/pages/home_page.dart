import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal[300]!,
                  Colors.teal[600]!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          CustomPaint(
            painter: CurvePainter(),
            child: Container(),
          ),
          Center(
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
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 150.0,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'ToRent',
                          speed: Duration(milliseconds: 400),
                          curve: Curves.decelerate,
                        ),
                      ],
                      repeatForever: true,
                      onTap: () {
                        print("Welcome to ToRent!");
                      },
                    ),
                  ),
                ),
                SizedBox(height: 60),
                SizedBox(
                  width: 200, // Set a fixed width for both buttons
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle login action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal[600],
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 200, // Set the same fixed width
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle register action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'إنشاء حساب',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.teal[500]!
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..lineTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.75, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.25, size.width, size.height * 0.5)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

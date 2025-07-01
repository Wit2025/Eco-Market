import 'package:flutter/material.dart';

class FirstPages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Gradient Circle
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purpleAccent, Colors.deepPurple],
                  ),
                ),
              ),
            ),

            // Optional Second Gradient Circle
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Center(
                    child: Icon(
                      Icons.star_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 100,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    "ຍິນດີຕ້ອນຮັບ",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "ແອພພ້ອມໃຊ້ງານແລ້ວ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

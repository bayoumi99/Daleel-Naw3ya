import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'Intro_Screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "splashScreen";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) Navigator.pushReplacementNamed(context, IntroScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B8E), // اللون الكحلي العميق
              Color(0xFF1B4B91), // درجة وسيطة لضمان نعومة التدرج
              Color(0xFF5BAED4), // تم تغميق اللون الفاتح قليلاً (بدلاً من 75C8F1)
            ],
            // ضبط الـ stops لتوزيع اللون الغامق على مساحة أكبر
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // اللوجو الرئيسي في المنتصف
            FadeInDown(
              duration: const Duration(milliseconds: 1500),
              child: Image.asset(
                "lib/assets/images/logo1.png",
                width: size.width * 0.7,
              ),
            ),

            // صورة المطور في الأسفل
            Positioned(
              bottom: size.height * 0.04,
              child: FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Image.asset(
                  "lib/assets/images/codeare.png",
                  width: size.width * 0.42,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
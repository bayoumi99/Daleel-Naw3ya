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
    // إزالة السبلش سكرين الأصلية الخاصة بالنظام
    FlutterNativeSplash.remove();

    // الانتقال لصفحة الانترو بعد 6 ثواني
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, IntroScreen.routeName);
      }
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
              Color(0xFFD6E6F3), // ICE BLUE
              Color(0xFFA6C5D7), // POWDER BLUE
              Color(0xFF0F52BA), // SAPPHIRE
              Color(0xFF000926), // DARK NAVY
            ],
            // توزيع الألوان بالتساوي على طول الصفحة
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // اللوجو الرئيسي مع حركة دخول من الأعلى
            FadeInDown(
              duration: const Duration(milliseconds: 1500),
              child: Image.asset(
                "lib/assets/images/logo1.png",
                width: size.width * 0.7,
              ),
            ),

            // صورة المطور/الشركة في الأسفل مع حركة دخول من الأسفل
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
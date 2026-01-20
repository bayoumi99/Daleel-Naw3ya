import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// ملاحظة: لا حاجة لعمل استيراد لصفحة الـ Intro هنا لأننا سنستخدم Routes
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

    // التعديل الجوهري: التوجه لـ auth_check بدلاً من IntroScreen
    Future.delayed(const Duration(seconds: 4), () { // قللنا الوقت قليلاً لـ 4 ثواني لتجربة مستخدم أسرع
      if (mounted) {
        // ننتقل للمسار الوسيط الذي فحص حالة المستخدم في ملف main.dart
        Navigator.pushReplacementNamed(context, 'auth_check');
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
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // اللوجو الرئيسي
            FadeInDown(
              duration: const Duration(milliseconds: 1500),
              child: Image.asset(
                "lib/assets/images/logo1.png",
                width: size.width * 0.7,
              ),
            ),

            // مؤشر تحميل بسيط ليعرف المستخدم أن التطبيق يفحص البيانات
            Positioned(
              bottom: size.height * 0.15,
              child: FadeIn(
                delay: const Duration(milliseconds: 2000),
                child: const CircularProgressIndicator(
                  color: Colors.white70,
                  strokeWidth: 2,
                ),
              ),
            ),

            // صورة المطور/الشركة
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
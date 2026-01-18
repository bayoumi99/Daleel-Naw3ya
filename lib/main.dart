import 'package:daleel_naw3ya/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // السطر الصحيح لتهيئة التاريخ
// استيراد الصفحات
import 'package:daleel_naw3ya/screens/splash_screen.dart';
import 'package:daleel_naw3ya/screens/Intro_Screen.dart';
import 'package:daleel_naw3ya/screens/student_home_screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_home_screen.dart';

import 'firebase_options.dart'; // تأكد من استيراد صفحة الدكتور

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة التاريخ العربي بشكل صحيح لمنع الـ PathNotFoundException
  await initializeDateFormatting('ar', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دليل نوعية',
      themeMode: _themeMode,

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF292F91),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF292F91),
      ),

      initialRoute: SplashScreen.routeName,

      onGenerateRoute: (settings) {
        // إدارة المسارات (Navigation Management)
        if (settings.name == SplashScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        }
        if (settings.name == IntroScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const IntroScreen());
        }
        if (settings.name == DynamicSignupScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const DynamicSignupScreen());
        }

        // مسار الطالب
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => StudentHomeScreen(
              isDarkMode: _themeMode == ThemeMode.dark,
              onThemeChanged: _toggleTheme,
            ),
          );
        }

        // إضافة مسار الدكتور هنا ليعمل زر الـ Signup بشكل صحيح
        if (settings.name == StaffHomeScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => StaffHomeScreen(
              doctorName: args?['doctorName'] ?? "دكتور",
              department: args?['department'] ?? "عام",
            ),
          );
        }

        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}
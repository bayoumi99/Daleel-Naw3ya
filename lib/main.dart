import 'package:daleel_naw3ya/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:daleel_naw3ya/screens/splash_screen.dart';
import 'package:daleel_naw3ya/screens/Intro_Screen.dart';
import 'package:daleel_naw3ya/screens/student_home_screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  // جعل الوضع الافتراضي متوافق مع ثيم الجهاز أو فاتح
  ThemeMode _themeMode = ThemeMode.light;

  // الدالة الأساسية لتغيير الثيم
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

      // إعدادات الثيم الفاتح
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF292F91),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF292F91)),
      ),

      // إعدادات الثيم الغامق
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF292F91),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
      ),

      initialRoute: SplashScreen.routeName,

      onGenerateRoute: (settings) {
        bool isDark = _themeMode == ThemeMode.dark;

        if (settings.name == SplashScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        }
        if (settings.name == IntroScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const IntroScreen());
        }

        // مسار تسجيل الدخول (مهم لعمل زر الخروج)
        if (settings.name == '/login' || settings.name == DynamicSignupScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const DynamicSignupScreen());
        }

        // مسار الطالب المحدث
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => StudentHomeScreen(
              isDarkMode: isDark,
              onThemeChanged: _toggleTheme,
            ),
          );
        }

        // مسار الدكتور المحدث (تم ربط الدالة هنا)
        if (settings.name == StaffHomeScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => StaffHomeScreen(
              doctorName: args?['doctorName'] ?? "دكتور",
              department: args?['department'] ?? "عام",
              isDarkMode: isDark,
              onThemeChanged: _toggleTheme, // تم التعديل: ربط الدالة الحقيقية
            ),
          );
        }

        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}
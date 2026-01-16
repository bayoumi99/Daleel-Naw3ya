
import 'package:daleel_naw3ya/lib/screens/Intro_Screen.dart';
import 'package:daleel_naw3ya/lib/screens/login_screen.dart';
import 'package:daleel_naw3ya/lib/screens/splash_screen.dart';
import 'package:daleel_naw3ya/lib/screens/student_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';

import 'core/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', 'en');
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
        scaffoldBackgroundColor: AppColors.lightBackground,
        primaryColor: AppColors.primaryNavy,
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.primaryNavy,
      ),

      initialRoute: SplashScreen.routeName,

      onGenerateRoute: (settings) {
        if (settings.name == IntroScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const IntroScreen());
        }
        if (settings.name == DynamicSignupScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const DynamicSignupScreen());
        }

        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => StudentHomeScreen(
              isDarkMode: _themeMode == ThemeMode.dark,
              onThemeChanged: _toggleTheme,
            ),
          );
        }
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}
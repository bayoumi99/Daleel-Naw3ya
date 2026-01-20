import 'package:cloud_firestore/cloud_firestore.dart'; // نحتاجها لجلب بيانات المستخدم
import 'package:firebase_auth/firebase_auth.dart'; // نحتاجها لفحص الجلسة
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
  ThemeMode _themeMode = ThemeMode.light;

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
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF292F91)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF292F91),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
      ),

      // نبدأ بـ SplashScreen كالعادة
      initialRoute: SplashScreen.routeName,

      onGenerateRoute: (settings) {
        bool isDark = _themeMode == ThemeMode.dark;

        if (settings.name == SplashScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        }

        // الشاشة الوسيطة بعد السبلاتش لتقرير أين يذهب المستخدم
        if (settings.name == 'auth_check') {
          return MaterialPageRoute(builder: (context) => AuthWrapper(onThemeChanged: _toggleTheme, isDark: isDark));
        }

        if (settings.name == IntroScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const IntroScreen());
        }

        if (settings.name == '/login' || settings.name == "DynamicSignupScreen") {
          return MaterialPageRoute(builder: (context) => const DynamicSignupScreen());
        }

        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => StudentHomeScreen(
              isDarkMode: isDark,
              onThemeChanged: _toggleTheme,
            ),
          );
        }

        if (settings.name == StaffHomeScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => StaffHomeScreen(
              doctorName: args?['doctorName'] ?? "دكتور",
              department: args?['department'] ?? "عام",
              isDarkMode: isDark,
              onThemeChanged: _toggleTheme,
            ),
          );
        }

        return MaterialPageRoute(builder: (context) => const SplashScreen());
      },
    );
  }
}

// الكلاس المسؤول عن فحص تسجيل الدخول وتوجيه المستخدم تلقائياً
class AuthWrapper extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final bool isDark;
  const AuthWrapper({super.key, required this.onThemeChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة المستخدم (هل هو مسجل دخول أم لا؟)
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // إذا كان الاتصال مازال جارياً
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // إذا وجدنا مستخدم مسجل (يتم التوجه لجلب بياناته من Firestore)
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('Users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                var data = userSnapshot.data!.data() as Map<String, dynamic>;
                String role = data['role'] ?? 'student';

                if (role == 'student') {
                  return StudentHomeScreen(isDarkMode: isDark, onThemeChanged: onThemeChanged);
                } else {
                  return StaffHomeScreen(
                    doctorName: data['name'] ?? 'دكتور',
                    department: data['department'] ?? 'عام',
                    isDarkMode: isDark,
                    onThemeChanged: onThemeChanged,
                  );
                }
              }
              // إذا لم نجد بيانات المستخدم في Firestore نرجعه للتسجيل
              return const DynamicSignupScreen();
            },
          );
        }

        // إذا لم يكن مسجلاً، يذهب لشاشة الإنترو أو التسجيل
        return const IntroScreen();
      },
    );
  }
}
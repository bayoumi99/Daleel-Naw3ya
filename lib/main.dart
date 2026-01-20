import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daleel_naw3ya/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:daleel_naw3ya/screens/splash_screen.dart';
import 'package:daleel_naw3ya/screens/Intro_Screen.dart';
import 'package:daleel_naw3ya/screens/student_home_screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

// 1. معالج إشعارات الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Background Message: ${message.notification?.title}");
}

// 2. قناة أندرويد للإشعارات المنبثقة
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'إشعارات هامة',
  description: 'هذه القناة تستخدم لإشعارات الكلية الهامة',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('ar', null);

  // إعداد الإشعارات
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // طلب الإذن (أندرويد 13+)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
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

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  // تهيئة الاستماع للإشعارات والتطبيق مفتوح
  void _initFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

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
        primaryColor: const Color(0xFF292F91),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF292F91), foregroundColor: Colors.white, centerTitle: true),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF292F91),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), foregroundColor: Colors.white, centerTitle: true),
      ),
      initialRoute: SplashScreen.routeName,
      onGenerateRoute: (settings) {
        bool isDark = _themeMode == ThemeMode.dark;

        if (settings.name == SplashScreen.routeName) {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        }
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
          return MaterialPageRoute(builder: (context) => StudentHomeScreen(isDarkMode: isDark, onThemeChanged: _toggleTheme));
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

class AuthWrapper extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final bool isDark;
  const AuthWrapper({super.key, required this.onThemeChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

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

                // تم تعديل Topic ليكون اسم إنجليزي بدون مسافات لتجنب الخطأ
                if (role == 'student') {
                  FirebaseMessaging.instance.subscribeToTopic("all_students");
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
              return const DynamicSignupScreen();
            },
          );
        }
        return const IntroScreen();
      },
    );
  }
}
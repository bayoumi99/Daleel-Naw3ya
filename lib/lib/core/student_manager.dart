import 'package:intl/intl.dart';
import 'dart:convert'; // ضروري لتحويل الجدول لنص وحفظه
import 'package:shared_preferences/shared_preferences.dart';

class StudentManager {
  static final StudentManager _instance = StudentManager._internal();
  factory StudentManager() => _instance;
  StudentManager._internal();

  String name = "";
  String code = "";
  String dept = "";
  String level = "";
  int levelIndex = 1;
  String specialty = "";

  Map<String, List<Map<String, String>>> weeklySchedule = {
    "السبت": [],
    "الأحد": [],
    "الاثنين": [], // وحدنا الهمزات هنا للأمان
    "الثلاثاء": [],
    "الأربعاء": [],
    "الخميس": [],
  };

  // --- دالة الحفظ التلقائي ---
  Future<void> saveScheduleToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(weeklySchedule);
    await prefs.setString('user_schedule', jsonString);
  }

  // --- دالة استعادة البيانات عند فتح التطبيق ---
  Future<void> loadScheduleFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('user_schedule');
    if (jsonString != null) {
      Map<String, dynamic> decoded = jsonDecode(jsonString);
      weeklySchedule = decoded.map((key, value) => MapEntry(
          key, List<Map<String, String>>.from(value.map((item) => Map<String, String>.from(item)))));
    }
  }

  List<Map<String, String>> getTodayLectures() {
    // استخدمنا خريطة (Map) بدل الـ Index لسرعة ودقة أكبر
    Map<String, String> dayMapping = {
      "Monday": "الاثنين",
      "Tuesday": "الثلاثاء",
      "Wednesday": "الأربعاء",
      "Thursday": "الخميس",
      "Saturday": "السبت",
      "Sunday": "الأحد",
    };

    String dayNameEn = DateFormat('EEEE').format(DateTime.now());
    String? dayNameAr = dayMapping[dayNameEn];

    return (dayNameAr != null) ? (weeklySchedule[dayNameAr] ?? []) : [];
  }

  void updateData({String? n, String? c, String? d, String? l, int? li, String? s}) {
    if (n != null) name = n;
    if (c != null) code = c;
    if (d != null) dept = d;
    if (l != null) level = l;
    if (li != null) levelIndex = li;
    if (s != null) specialty = s;
  }
}
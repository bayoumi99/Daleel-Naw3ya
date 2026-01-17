import 'package:daleel_naw3ya/screens/staff/staff_Create_Quiz_Screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_Profile_Screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaffHomeScreen extends StatelessWidget {
  static const routeName = '/Staff_Home';

  final String doctorName;
  final String department;

  const StaffHomeScreen({
    super.key,
    this.doctorName = "د. أحمد علي",
    this.department = "تكنولوجيا التعليم"
  });

  @override
  Widget build(BuildContext context) {
    // تنسيق التاريخ الحالي تلقائياً باللغة العربية
    String currentDate = DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now());

    final Color primaryColor = const Color(0xFF292F91);
    final Color accentColor = const Color(0xFF4CA8DD);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: Column(
        children: [
          // الجزء العلوي (Header) يحتوي على بيانات الدكتور والتاريخ
          Container(
            padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryColor, accentColor]),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        currentDate,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffProfileScreen(
                              doctorName: doctorName,
                              department: department,
                              onThemeChanged: (bool val) { /* يمكن ربطها بالثيم هنا */ },
                              isDarkMode: false,
                              onDataChanged: () { },
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.person_outline, size: 30, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "مرحباً دكتور 👋",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  doctorName,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "قسم $department",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // قائمة الأزرار العريضة تحت بعضها
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              children: [
                _buildWideMenuCard(context, "نشر واجب", Icons.assignment_outlined, Colors.blue, () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const PublishAssignmentPage()));
                }),
                _buildWideMenuCard(context, "إنشاء اختبار", Icons.checklist_rtl_outlined, Colors.indigo, () {
                  // استخدم push بدلاً من pushReplacement لتمكين زر الرجوع
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateQuizScreen()),
                  );
                }),
                _buildWideMenuCard(context, "إرسال إشعار", Icons.notifications_active_outlined, Colors.orange, () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const SendNotificationPage()));
                }),
              ],
            ),
          ),        ],
      ),
    );
  }

  // دالة بناء الزر العريض الذي يأخذ عرض الصفحة
  Widget _buildWideMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF292F91),
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// صفحة تجريبية لنشر خبر
class PostNewsScreen extends StatelessWidget {
  const PostNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("نشر خبر جديد"),
        backgroundColor: const Color(0xFF292F91),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text("واجهة نشر الأخبار")),
    );
  }
}
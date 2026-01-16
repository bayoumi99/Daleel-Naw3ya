import 'package:daleel_naw3ya/screens/staff/staff_Profile_Screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ستحتاج لإضافة حزمة intl في pubspec.yaml للتاريخ التلقائي

class StaffHomeScreen extends StatelessWidget {
  static const routeName = '/Staff_Home';

  // هذه البيانات سيتم تمريرها من صفحة اللوجن أو استدعاؤها من الـ Manager
  final String doctorName;
  final String department;

  const StaffHomeScreen({
    super.key,
    this.doctorName = "د. أحمد علي", // قيم افتراضية للتجربة
    this.department = "تكنولوجيا التعليم"
  });

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now());

    final Color primaryColor = const Color(0xFF292F91);
    final Color accentColor = const Color(0xFF4CA8DD);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: Column(
        children: [
          // الجزء العلوي (Header)
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
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
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
                              onThemeChanged: (bool p1) {  },
                              isDarkMode: false,
                              onDataChanged: () {  },
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.person_outline, size: 30, color: Colors.white),
                    ),                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "مرحباً دكتور 👋",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
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

          // شبكة الأزرار (Grid View) تغطي باقي الصفحة
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2, // زرين في كل صف
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildMenuCard(context, "نشر واجب", Icons.assignment_outlined, Colors.blue, () {
                    // Navigator.pushNamed(context, '/publish_assignment');
                  }),
                  _buildMenuCard(context, "إنشاء اختبار", Icons.checklist_rtl_outlined, Colors.indigo, () {
                    // Navigator.pushNamed(context, '/create_quiz');
                  }),
                  _buildMenuCard(context, "إرسال إشعار", Icons.notifications_active_outlined, Colors.orange, () {
                    // Navigator.pushNamed(context, '/send_notification');
                  }),
                  _buildMenuCard(context, "نشر خبر", Icons.newspaper_outlined, Colors.green, () {
                    // Navigator.pushNamed(context, '/post_news');
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292F91),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
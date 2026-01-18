import 'package:cloud_firestore/cloud_firestore.dart'; // إضافة مكتبة Firestore
import 'package:daleel_naw3ya/screens/staff/staff_Create_Quiz_Screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_Profile_Screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_Publish_Assignment_Screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_Send_Notification_Screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StaffHomeScreen extends StatelessWidget {
  static const routeName = '/Staff_Home';

  const StaffHomeScreen({super.key, required String doctorName, required String department});

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now());
    final Color primaryColor = const Color(0xFF292F91);
    final Color accentColor = const Color(0xFF4CA8DD);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      // استخدمنا StreamBuilder لجعل البيانات تتحدث تلقائياً إذا غيرتها في Firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('role', isEqualTo: 'doctor') // جلب المستخدم اللي رتبته دكتور
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          // حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // جلب البيانات من أول مستند موجود في المجموعة
          var doctorData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          // استخراج القيم من الخانات (Value) التي ملأتها في Firebase
          String nameFromDb = doctorData['name'] ?? "غير معرف";
          String deptFromDb = doctorData['department'] ?? "غير معرف";

          return Column(
            children: [
              // الهيدر المحدث ببيانات Firebase
              Container(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 35),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اليسار: الأيقونة والتاريخ
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StaffProfileScreen(
                                doctorName: nameFromDb,
                                department: deptFromDb,
                                onThemeChanged: (bool val) {},
                                isDarkMode: false,
                                onDataChanged: () {},
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                            ),
                            child: const Icon(Icons.person_rounded, size: 38, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentDate,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    // اليمين: الترحيب + الاسم والقسم من Firebase
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("مرحباً دكتور 👋", style: TextStyle(color: Colors.white70, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            nameFromDb, // القيمة من Firebase
                            textAlign: Radius.zero == null ? TextAlign.right : TextAlign.right,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "قسم $deptFromDb", // القيمة من Firebase
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // قائمة الأزرار
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    _buildWideMenuCard(
                      context,
                      "نشر واجب دراسي",
                      Icons.assignment_add,
                      Colors.blue.shade700,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentsManagementScreen(isDarkMode: false))),
                    ),
                    _buildWideMenuCard(
                      context,
                      "إنشاء اختبار إلكتروني",
                      Icons.quiz_outlined,
                      Colors.indigo.shade700,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateQuizScreen())),
                    ),
                    _buildWideMenuCard(
                      context,
                      "إرسال إشعار للطلاب",
                      Icons.campaign_outlined,
                      Colors.orange.shade800,
                          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsManagementScreen(isDarkMode: false))),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWideMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(width: 18),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF292F91))),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}
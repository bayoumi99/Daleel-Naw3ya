import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daleel_naw3ya/screens/staff/staff_Create_Quiz_Screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_Profile_Screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_Publish_Assignment_Screen.dart';
import 'package:daleel_naw3ya/screens/staff/staff_Send_Notification_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class StaffHomeScreen extends StatefulWidget {
  static const routeName = '/Staff_Home';

  final bool isDarkMode;
  final Function(bool) onThemeChanged;


  const StaffHomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged, required String doctorName, required String department,
  });

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  Map<String, dynamic>? doctorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  // دالة جلب البيانات مع حماية من التحميل اللانهائي
  Future<void> _fetchDoctorData() async {
    if (!mounted) return;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          if (mounted) {
            setState(() {
              doctorData = doc.data() as Map<String, dynamic>;
              _isLoading = false;
            });
          }
        } else {
          debugPrint("وثيقة الدكتور غير موجودة");
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("خطأ في جلب بيانات الدكتور: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now());
    final Color primaryColor = const Color(0xFF292F91);
    final Color accentColor = const Color(0xFF4CA8DD);

    // الألوان بناءً على الوضع (ليلي/فاتح)
    final scaffoldBg = widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF);
    final cardBg = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : const Color(0xFF292F91);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchDoctorData,
        child: Column(
          children: [
            // الهيدر (الجزء العلوي)
            _buildHeader(currentDate, primaryColor, accentColor),

            // قائمة المهام
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  _buildWideMenuCard(
                    "نشر واجب دراسي",
                    Icons.assignment_add,
                    Colors.blue.shade700,
                    cardBg,
                    textColor,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AssignmentsManagementScreen(isDarkMode: widget.isDarkMode)),
                    ),
                  ),
                  _buildWideMenuCard(
                    "إنشاء اختبار إلكتروني",
                    Icons.quiz_outlined,
                    Colors.indigo.shade700,
                    cardBg,
                    textColor,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateQuizScreen())),
                  ),
                  _buildWideMenuCard(
                    "إرسال إشعار للطلاب",
                    Icons.campaign_outlined,
                    Colors.orange.shade800,
                    cardBg,
                    textColor,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationsManagementScreen(isDarkMode: widget.isDarkMode)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String currentDate, Color primaryColor, Color accentColor) {
    return Container(
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
        children: [
          // أيقونة البروفايل والتاريخ
          Column(
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffProfileScreen(
                      doctorName: doctorData?['name'] ?? "",
                      department: doctorData?['department'] ?? "",
                      onThemeChanged: widget.onThemeChanged,
                      isDarkMode: widget.isDarkMode,
                        onDataChanged: () {
                          _fetchDoctorData();
                        }
                        ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, size: 38, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentDate,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // بيانات الدكتور
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("مرحباً دكتور 👋", style: TextStyle(color: Colors.white70, fontSize: 15)),
                Text(
                  doctorData?['name'] ?? "جاري التحميل...",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                Text(
                  "قسم ${doctorData?['department'] ?? ''}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideMenuCard(String title, IconData icon, Color iconColor, Color cardBg, Color textColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(widget.isDarkMode ? 0.2 : 0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(width: 18),
              Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class StaffProfileScreen extends StatefulWidget {
  static const routeName = '/Staff_Profile';

  final Function(bool) onThemeChanged;
  final bool isDarkMode;
  final String doctorName;
  final String department;
  final VoidCallback onDataChanged; // تم تغيير النوع من Null Function إلى VoidCallback

  const StaffProfileScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.doctorName,
    required this.department,
    required this.onDataChanged,
  });

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  Map<String, dynamic>? doctorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  // جلب بيانات الدكتور من Firebase
  Future<void> _fetchDoctorData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          if (mounted) {
            setState(() {
              doctorData = doc.data() as Map<String, dynamic>;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("خطأ في جلب بيانات البروفايل: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        title: const Text("الملف الشخصي", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildThemeSwitchTile(),
                  const SizedBox(height: 10),
                  _buildSettingTile(
                      "القسم العلمي",
                      doctorData?['department'] ?? widget.department,
                      Icons.account_tree_outlined,
                      Colors.blue),
                  _buildSettingTile(
                      "الدرجة العلمية",
                      "عضو هيئة تدريس",
                      Icons.workspace_premium_outlined,
                      Colors.amber),
                  _buildSettingTile(
                      "البريد الإلكتروني",
                      doctorData?['email'] ?? "غير متوفر",
                      Icons.email_outlined,
                      Colors.green),
                  const SizedBox(height: 30),
                  _buildLogoutTile(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 40),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      doctorData?['name'] ?? widget.doctorName,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "كود الموظف: ${doctorData?['code'] ?? 'N/A'}",
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "قسم ${doctorData?['department'] ?? widget.department}",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSwitchTile() {
    return Card(
      elevation: 0,
      color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)),
      child: ListTile(
        title: Text("المظهر", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDarkMode ? Colors.white : Colors.black)),
        subtitle: Text(widget.isDarkMode ? "الوضع الليلي" : "الوضع الفاتح", textAlign: TextAlign.right, style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54)),
        trailing: Icon(widget.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined, color: Colors.blue),
        leading: Switch(
            activeColor: Colors.blue,
            value: widget.isDarkMode,
            onChanged: (val) {
              widget.onThemeChanged(val); // تفعيل تغيير الثيم
            }),
      ),
    );
  }

  Widget _buildSettingTile(String t, String s, IconData i, Color c) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      elevation: 0,
      color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)),
      child: ListTile(
        title: Text(t, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDarkMode ? Colors.white : Colors.black)),
        subtitle: Text(s, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: widget.isDarkMode ? Colors.white54 : Colors.black54)),
        trailing: Icon(i, color: c),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return InkWell(
      onTap: () {
        _showLogoutDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.1))),
        child: const ListTile(
          title: Text("تسجيل الخروج", textAlign: TextAlign.right, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          trailing: Icon(Icons.logout, color: Colors.red),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الخروج", textAlign: TextAlign.right),
        content: const Text("هل أنت متأكد من رغبتك في تسجيل الخروج؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // تأكد من أن اسم المسار مطابق لصفحة الدخول عندك في main.dart
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text("خروج", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
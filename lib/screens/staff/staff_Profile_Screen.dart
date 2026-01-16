import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class StaffProfileScreen extends StatefulWidget {
  static const routeName = '/Staff_Profile';

  final Function(bool) onThemeChanged;
  final bool isDarkMode;
  final String doctorName;
  final String department;
  final String staffCode; // الكود الوظيفي

  const StaffProfileScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.doctorName,
    required this.department,
    this.staffCode = "123456", required Null Function() onDataChanged, // قيمة افتراضية
  });

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        title: const Text("الملف الشخصي", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
                      widget.department,
                      Icons.account_tree_outlined,
                      Colors.blue
                  ),

                  _buildSettingTile(
                      "الدرجة العلمية",
                      "عضو هيئة تدريس",
                      Icons.workspace_premium_outlined,
                      Colors.amber
                  ),

                  _buildSettingTile(
                      "البريد الجامعي",
                      "doctor@minia.edu.eg",
                      Icons.email_outlined,
                      Colors.green
                  ),

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
                      widget.doctorName,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "الكود الوظيفي: ${widget.staffCode}",
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "قسم ${widget.department}",
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
          side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)
      ),
      child: ListTile(
        title: Text("المظهر", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDarkMode ? Colors.white : Colors.black)),
        subtitle: Text(widget.isDarkMode ? "الوضع الليلي" : "الوضع الفاتح", textAlign: TextAlign.right, style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54)),
        trailing: Icon(widget.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_outlined, color: Colors.blue),
        leading: Switch(
            activeColor: Colors.blue,
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged
        ),
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
          side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)
      ),
      child: ListTile(
        title: Text(t, textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: widget.isDarkMode ? Colors.white : Colors.black)),
        subtitle: Text(s, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: widget.isDarkMode ? Colors.white54 : Colors.black54)),
        trailing: Icon(i, color: c),
        leading: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return InkWell(
      onTap: () {
        // العودة لصفحة البداية وتصفير المسارات
        Navigator.pushNamedAndRemoveUntil(context, 'DynamicSignupScreen', (route) => false);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.1))
        ),
        child: const ListTile(
          title: Text("تسجيل الخروج", textAlign: TextAlign.right, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          trailing: Icon(Icons.logout, color: Colors.red),
        ),
      ),
    );
  }
}
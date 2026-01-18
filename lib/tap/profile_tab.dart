import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/student_manager.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;
  final VoidCallback onDataChanged;

  const ProfileScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.onDataChanged
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // جلب البيانات من Firebase
  Future<void> _fetchUserData() async {
    if (!mounted) return;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        if (mounted) {
          setState(() {
            userData = doc.data() as Map<String, dynamic>;

            // تحديث بيانات المنيجر لضمان مزامنة التطبيق
            StudentManager().name = userData!['name'] ?? "طالب";
            StudentManager().code = userData!['code'] ?? "000000";
            StudentManager().level = userData!['year'] ?? "";
            StudentManager().dept = userData!['department'] ?? "";
            StudentManager().specialty = userData!['specialty'] ?? "";

            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("خطأ في جلب البيانات: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // دالة الترفيع
  Future<void> _upgradeLevelInFirebase() async {
    String currentLevel = userData?['year'] ?? "";
    String nextLevel = "";

    if (currentLevel == "السنة الأولى") nextLevel = "السنة الثانية";
    else if (currentLevel == "السنة الثانية") nextLevel = "السنة الثالثة";
    else if (currentLevel == "السنة الثالثة") nextLevel = "السنة الرابعة";
    else return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'year': nextLevel,
      });

      if (nextLevel == "السنة الثالثة") {
        _showSpecialtyDialog(user.uid);
      } else {
        await _fetchUserData();
        widget.onDataChanged();
      }
    } catch (e) {
      debugPrint("خطأ في الترفيع: $e");
    }
  }

  // حوار اختيار التخصص (معدل لمنع التعليق)
  void _showSpecialtyDialog(String uid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("اختيار التخصص الدراسي", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("يرجى اختيار تخصصك لاستكمال الدراسة في السنة الثالثة:", textAlign: TextAlign.right),
            const SizedBox(height: 20),
            _buildSpecialtyOption(uid, "معلم حاسب آلي"),
            const Divider(),
            _buildSpecialtyOption(uid, "تكنولوجيا تعليم"),
          ],
        ),
      ),
    );
  }

  // زر اختيار التخصص داخل الحوار (معدل)
  Widget _buildSpecialtyOption(String uid, String specialtyName) {
    return ListTile(
      title: Text(specialtyName, textAlign: TextAlign.right),
      onTap: () async {
        // 1. إغلاق الحوار أولاً
        Navigator.of(context, rootNavigator: true).pop();

        try {
          setState(() => _isLoading = true);

          // 2. تحديث التخصص
          await FirebaseFirestore.instance.collection('Users').doc(uid).update({
            'specialty': specialtyName,
          });

          // 3. تحديث البيانات محلياً
          await _fetchUserData();
          widget.onDataChanged();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("تم اختيار تخصص $specialtyName بنجاح"), backgroundColor: Colors.green),
            );
          }
        } catch (e) {
          debugPrint("خطأ: $e");
          if (mounted) setState(() => _isLoading = false);
        }
      },
    );
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تسجيل الخروج", textAlign: TextAlign.right),
        content: const Text("هل أنت متأكد؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // تأكد من وجود مسار باسم /login في ملف main.dart
                Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text("خروج", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    _buildUpgradeSection(),
                    const SizedBox(height: 20),
                    _buildThemeSwitchTile(),
                    _buildSettingTile(
                        "المعلومات الأكاديمية",
                        "${userData?['department'] ?? ''}${userData?['specialty'] != null && userData?['specialty'] != '' && userData?['specialty'] != 'عام' ? ' - ${userData?['specialty']}' : ''}",
                        Icons.school_outlined,
                        Colors.green
                    ),
                    const SizedBox(height: 10),
                    _buildLogoutTile(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String specialty = userData?['specialty'] ?? "";
    bool hasSpecialty = specialty.isNotEmpty && specialty != "عام";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
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
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 35),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(userData?['name'] ?? "طالب", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("كود: ${userData?['code'] ?? '0000'}", style: const TextStyle(color: Colors.amberAccent, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (hasSpecialty)
                          Text("($specialty) ", style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
                        Text(userData?['year'] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
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

  Widget _buildUpgradeSection() {
    bool canUpgrade = userData?['year'] != "السنة الرابعة";
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: canUpgrade ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: canUpgrade ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
              onPressed: canUpgrade ? _upgradeLevelInFirebase : null,
              style: ElevatedButton.styleFrom(backgroundColor: canUpgrade ? Colors.green : Colors.grey),
              child: Text(canUpgrade ? "ترفيع" : "تم التخرج", style: const TextStyle(color: Colors.white))
          ),
          Text(
            canUpgrade ? "نظام ترفيع المستوى" : "أنت في الفرقة النهائية",
            style: TextStyle(fontSize: 11, color: widget.isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitchTile() {
    return Card(
      elevation: 0,
      // تغيير لون الكارت بناءً على الوضع
      color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200,
          )),
      child: ListTile(
        // النصوص
        title: Text(
          "المظهر",
          textAlign: TextAlign.right,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          widget.isDarkMode ? "الوضع الليلي" : "الوضع الفاتح",
          textAlign: TextAlign.right,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white54 : Colors.black54,
            fontSize: 12,
          ),
        ),
        // المفتاح (Switch) جهة اليسار
        leading: Switch(
          value: widget.isDarkMode,
          activeColor: Colors.blue,
          onChanged: (v) {
            // استدعاء الدالة الممرة لتغيير الثيم في التطبيق كله
            widget.onThemeChanged(v);
          },
        ),
        // الأيقونة جهة اليمين
        trailing: Icon(
          widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Colors.blue,
        ),
      ),
    );
  }
  Widget _buildSettingTile(String t, String s, IconData i, Color c) {
    return Card(
      elevation: 0,
      color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)
      ),
      child: ListTile(
        title: Text(t, textAlign: TextAlign.right, style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Text(s, textAlign: TextAlign.right, style: TextStyle(color: widget.isDarkMode ? Colors.white54 : Colors.black54)),
        trailing: Icon(i, color: c),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return InkWell(
      onTap: _handleLogout,
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
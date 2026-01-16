
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

  // دالة ترفيع المستوى الدراسي مع معالجة الانتقال للسنة الثالثة
  void _upgradeLevel() {
    if (StudentManager().levelIndex < 4) {
      int next = StudentManager().levelIndex + 1;
      String levelName = next == 2 ? "الثانية" : next == 3 ? "الثالثة" : "الرابعة";

      setState(() {
        StudentManager().updateData(li: next, l: "الفرقة $levelName");
      });

      // إشعار باقي الصفحات بتحديث البيانات (مثل الهوم)
      widget.onDataChanged();

      // إذا أصبح الطالب في سنة ثالثة، نظهر حوار التخصص
      if (next == 3) {
        Future.delayed(Duration.zero, () => _showSpecialtyDialog());
      }
    }
  }

  // حوار اختيار التخصص المصلح لمنع الشاشة الحمراء
  void _showSpecialtyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // لا يمكن إغلاقه بالضغط خارجه لضمان الاختيار
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("اختيار التخصص", textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSpecialtyOption(dialogContext, "معلم حاسب آلي"),
              const Divider(),
              _buildSpecialtyOption(dialogContext, "تكنولوجيا تعليم"),
            ],
          ),
        );
      },
    );
  }

  // عنصر خيار التخصص داخل الـ Dialog
  Widget _buildSpecialtyOption(BuildContext dialogContext, String specName) {
    return ListTile(
      title: Text(specName, textAlign: TextAlign.right),
      onTap: () {
        // 1. إغلاق الحوار أولاً باستخدام الـ context الخاص به
        Navigator.of(dialogContext).pop();

        // 2. تحديث البيانات في الـ Manager وفي واجهة البروفايل
        setState(() {
          StudentManager().updateData(s: specName);
        });

        // 3. تحديث الهوم ليعكس التخصص الجديد
        widget.onDataChanged();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
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
                      "${StudentManager().dept}${StudentManager().specialty.isNotEmpty ? ' - ${StudentManager().specialty}' : ''}",
                      Icons.school_outlined,
                      Colors.green
                  ),

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
    bool isThirdOrFourthYear = StudentManager().levelIndex >= 3;
    String studentCode = StudentManager().code.isEmpty ? "000000" : StudentManager().code;

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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 35),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      StudentManager().name,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "كود الطالب: $studentCode",
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      StudentManager().level,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text("القسم العلمي والتخصص", style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isThirdOrFourthYear && StudentManager().specialty.isNotEmpty) ...[
                          Text(
                            StudentManager().specialty,
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text(" - ", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                        Text(
                          StudentManager().dept,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
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

  Widget _buildUpgradeSection() {
    bool canUpgrade = StudentManager().levelIndex < 4;
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
              onPressed: canUpgrade ? _upgradeLevel : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: canUpgrade ? Colors.green : Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: Text(canUpgrade ? "ترفيع" : "تم التخرج", style: const TextStyle(color: Colors.white))
          ),
          Text(
              canUpgrade ? "نهاية العام؟ انتقل للسنة التالية" : "أنت الآن في الفرقة النهائية",
              style: TextStyle(color: canUpgrade ? Colors.green : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)
          ),
        ],
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
        leading: Icon(Icons.arrow_back_ios, size: 14, color: widget.isDarkMode ? Colors.white24 : Colors.grey),
      ),
    );
  }

  Widget _buildLogoutTile() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12)
      ),
      child: const ListTile(
        title: Text("تسجيل الخروج", textAlign: TextAlign.right, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.logout, color: Colors.red),
      ),
    );
  }
}
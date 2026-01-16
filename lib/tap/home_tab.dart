import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';

class HomeTab extends StatelessWidget {
  final String studentName;
  final String studentDept;

  const HomeTab({
    super.key,
    required this.studentName,
    required this.studentDept,
  });

  @override
  Widget build(BuildContext context) {
    // جلب التاريخ الحقيقي بتنسيق عربي
    String formattedDate = DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(formattedDate),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionHeader("جدول اليوم", Icons.calendar_month_outlined),
                  const SizedBox(height: 12),
                  _buildCardExample(
                    title: "برمجة الويب",
                    subtitle: "د. أحمد محمود",
                    trailing: "09:00 - 11:00",
                    tag: "معمل 201",
                  ),
                  _buildCardExample(
                    title: "قواعد البيانات",
                    subtitle: "د. سارة علي",
                    trailing: "11:30 - 13:30",
                    tag: "قاعة 305",
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("الواجبات المعلقة", Icons.description_outlined),
                  const SizedBox(height: 12),
                  _buildCardExample(
                    title: "مشروع نهائي - تطبيق ويب",
                    subtitle: "برمجة الويب",
                    trailing: "باقي 3 أيام",
                    tag: "هام",
                    isTask: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String date) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(date, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              Row(
                children: [
                  Text(studentName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text(" ،مرحباً بك 👋", style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(studentDept, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("المحاضرات\nاليوم", "4"),
              _buildStatItem("الواجبات\nالمعلقة", "3"),
              _buildStatItem("الاختبارات\nالقادمة", "2"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("عرض الكل >", style: TextStyle(color: AppColors.accentBlue, fontSize: 12)),
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.orangeAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildCardExample({
    required String title,
    required String subtitle,
    required String trailing,
    required String tag,
    bool isTask = false,
  }) {
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trailing, style: TextStyle(color: isTask ? Colors.red : Colors.grey, fontSize: 12, fontWeight: isTask ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 12),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag, style: const TextStyle(color: AppColors.primaryNavy, fontSize: 11, fontWeight: FontWeight.bold))),
          ],
        ));
  }
}
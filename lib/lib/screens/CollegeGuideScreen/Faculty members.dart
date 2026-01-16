import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class FacultyMembersScreen extends StatefulWidget {
  final bool isDarkMode;


  FacultyMembersScreen({super.key, required this.isDarkMode});
  static const routeName = '/Faculty_Members';



  @override
  State<FacultyMembersScreen> createState() => _FacultyMembersScreenState();
}

class _FacultyMembersScreenState extends State<FacultyMembersScreen> {
  // قائمة بيانات تجريبية لأعضاء هيئة التدريس
  final List<Map<String, String>> staffList = [
    {
      "name": "د. أحمد محمد علي",
      "title": "أستاذ دكتور",
      "degree": "دكتوراه في تكنولوجيا التعليم",
      "image": "https://via.placeholder.com/150", // استبدلها بروابط الصور الحقيقية
    },
    {
      "name": "د. سارة محمود حسن",
      "title": "أستاذ مساعد",
      "degree": "دكتوراه في التربية الفنية",
      "image": "https://via.placeholder.com/150",
    },
    {
      "name": "د. محمود إبراهيم كمال",
      "title": "مدرس",
      "degree": "دكتوراه في الاقتصاد المنزلي",
      "image": "https://via.placeholder.com/150",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("أعضاء هيئة التدريس", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          return _buildStaffCard(staffList[index]);
        },
      ),
    );
  }

  Widget _buildStaffCard(Map<String, String> staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      width: double.infinity, // عرض الصفحة بالكامل
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // لترتيب العناصر من اليمين لليسار
        children: [
          // البيانات الوظيفية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  staff['name']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.blueAccent : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  staff['title']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  staff['degree']!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDarkMode ? Colors.grey : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // الصورة الشخصية المصغرة
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryNavy.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: NetworkImage(staff['image']!),
            ),
          ),
        ],
      ),
    );
  }
}
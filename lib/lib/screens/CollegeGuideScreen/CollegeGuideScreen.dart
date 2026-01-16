import 'package:daleel_naw3ya/lib/screens/CollegeGuideScreen/teaching%20halls.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import 'College achievements.dart';
import 'Faculty members.dart';
import 'Vision and Mission of the College.dart';

class CollegeGuideScreen extends StatelessWidget {
  final bool isDarkMode;
  static const routeName = '/college_guide';


  const CollegeGuideScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("دليل نوعية", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildGuideItem(
              context,
              title: "الرؤية والرسالة",
              icon: Icons.visibility_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisionMissionScreen(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),
            _buildGuideItem(
              context,
              title: "أعضاء هيئة التدريس",
              icon: Icons.groups_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FacultyMembersScreen(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),
            _buildGuideItem(
              context,
              title: "القاعات التدريسية",
              icon: Icons.meeting_room_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrainingRoomsScreen(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),
            _buildGuideItem(
              context,
              title: "إنجازات الكلية",
              icon: Icons.emoji_events_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollegeAchievementsScreen(isDarkMode: isDarkMode),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity, // يأخذ عرض الشاشة بالكامل
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20), // زوايا دائرية (كرف)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDarkMode ? Colors.white10 : AppColors.primaryNavy.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // السهم لليسار
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDarkMode ? Colors.grey : AppColors.primaryNavy.withOpacity(0.5),
              ),
              // النص والأيقونة جهة اليمين
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Icon(
                    icon,
                    color: isDarkMode ? Colors.blueAccent : AppColors.primaryNavy,
                    size: 28,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class VisionMissionScreen extends StatelessWidget {
  final bool isDarkMode;

  const VisionMissionScreen({super.key, required this.isDarkMode});
  static const routeName = '/vision_mission';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("الرؤية والرسالة",
            style: TextStyle(fontWeight: FontWeight.bold)),
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

            // كارت الرؤية
            _buildVisionMissionCard(
              title: "الرؤية",
              content: "تسعى الكلية لأن تكون لها مكانة علمية وبحثية ومجتمعية متميزة في المجالات النوعية، لإعداد خريج يتمتع بالانتماء للوطن، والقدرة على المنافسة محليًا وإقليمياً.",
              icon: Icons.lightbulb_outline_rounded,
              accentColor: Colors.amber.shade700,
            ),

            const SizedBox(height: 25),

            // كارت الرسالة
            _buildVisionMissionCard(
              title: "الرسالة",
              content: "تلتزم الكلية بتحقيق رؤيتها من خلال تهيئة بيئة علمية وبحثية بمستوى جودة يضمن خريج نوعي قادر على خدمة المجتمع وتلبية متطلبات سوق العمل.",
              icon: Icons.track_changes_rounded, // أيقونة الهدف
              accentColor: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisionMissionCard({
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // الجزء العلوي من الكارت (العنوان والأيقونة)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, color: accentColor, size: 30),
              ],
            ),
          ),

          // محتوى النص
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.8, // تباعد الأسطر لراحة القراءة
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
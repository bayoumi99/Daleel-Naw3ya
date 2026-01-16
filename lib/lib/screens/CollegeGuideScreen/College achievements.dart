import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class CollegeAchievementsScreen extends StatefulWidget {
  final bool isDarkMode;


  CollegeAchievementsScreen({super.key, required this.isDarkMode});
  static const routeName = '/College_Achievements';


  @override
  State<CollegeAchievementsScreen> createState() => _CollegeAchievementsScreenState();
}

class _CollegeAchievementsScreenState extends State<CollegeAchievementsScreen> {
  // قائمة بيانات الإنجازات (يمكنك إضافة الصور والبيانات الفعلية هنا)
  final List<Map<String, String>> achievements = [
    {
      "title": "الحصول على المركز الأول في مسابقة الابتكار",
      "date": "15 ديسمبر 2023",
      "description": "حققت الكلية المركز الأول على مستوى الجامعة في مسابقة الابتكار العلمي السنوية عن مشروع تدوير المخلفات الإلكترونية.",
      "image": "https://via.placeholder.com/600x300", // استبدلها برابط الصورة الفعلي
    },
    {
      "title": "افتتاح معامل الحاسب الآلي المطورة",
      "date": "10 نوفمبر 2023",
      "description": "تم تجهيز وافتتاح 5 معامل جديدة بأحدث الأجهزة والتقنيات لدعم العملية التعليمية والبحث العلمي بالكلية.",
      "image": "https://via.placeholder.com/600x300",
    },
    {
      "title": "المؤتمر العلمي الدولي للتربية النوعية",
      "date": "5 أكتوبر 2023",
      "description": "استضافة الكلية لنخبة من الباحثين الدوليين في المؤتمر السنوي لمناقشة مستقبل التعليم النوعي في ظل التحول الرقمي.",
      "image": "https://via.placeholder.com/600x300",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("إنجازات الكلية", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          return _buildAchievementCard(achievements[index]);
        },
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, String> achievement) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // لترتيب النص من اليمين
        children: [
          // جزء الصورة في الأعلى
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              achievement['image']!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              // في حالة فشل تحميل الصورة يظهر شكل بديل
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),
          ),

          // تفاصيل الإنجاز في الأسفل
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      achievement['date']!,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    Icon(Icons.stars, color: Colors.amber.shade700, size: 24),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  achievement['title']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  achievement['description']!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';

class TrainingRoomsScreen extends StatefulWidget {
  final bool isDarkMode;

  const TrainingRoomsScreen({super.key, required this.isDarkMode});
  static const routeName = '/training_rooms';

  @override
  State<TrainingRoomsScreen> createState() => _TrainingRoomsScreenState();
}

class _TrainingRoomsScreenState extends State<TrainingRoomsScreen> {
  // البيانات: المدرجات تحتوي على Plus Code لاستخدامه في تكوين اللينك
  final List<Map<String, String>> rooms = [
    {
      "name": "مدرج (أ) - مبنى دماريس",
      "type": "مدرج",
      "loc": "المنيا - دماريس",
      "plus_code": "4PGJ+79X",
    },
    {
      "name": "معمل الحاسب الآلي (1)",
      "type": "معمل",
      "loc": "الطابق الثاني",
      "address": "المبنى الرئيسي - خلف قسم تكنولوجيا التعليم - الدور الثاني",
    },
  ];

  // دالة لفتح الرابط عند الضغط عليه
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تعذر فتح الرابط")),
      );
    }
  }

  // نافذة المدرج التي تعرض "اللينك"
  void _showLocationLinkDialog(String name, String plusCode) {
    // تكوين رابط جوجل ماب باستخدام الـ Plus Code
    final String mapLink = "https://maps.app.goo.gl/tnkMXBYn65JDWm4u5?g_st=aw=${Uri.encodeComponent(plusCode)}";

    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Icon(Icons.map_outlined, size: 50, color: Colors.blue.shade700),
              const SizedBox(height: 15),
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("اضغط على الرابط للموقع الجغرافي:", style: TextStyle(fontSize: 14, color: Colors.grey)),
              ),
              const SizedBox(height: 10),

              // تصميم الرابط (Link)
              InkWell(
                onTap: () => _launchURL(mapLink),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mapLink,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // نافذة المعمل (وصف نصي)
  void _showLabDetails(String name, String address) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.biotech, size: 50, color: AppColors.primaryNavy),
              const SizedBox(height: 15),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text(address, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("قاعات التدريس والمعامل"),
        centerTitle: true,
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          final bool isLab = room['type'] == "معمل";

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Icon(
                  isLab ? Icons.biotech : Icons.location_on,
                  color: widget.isDarkMode ? Colors.blueAccent : AppColors.primaryNavy
              ),
              title: Text(
                  room['name']!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : AppColors.primaryNavy
                  )
              ),
              subtitle: Text(room['loc']!, textAlign: TextAlign.right),
              onTap: () {
                if (isLab) {
                  _showLabDetails(room['name']!, room['address']!);
                } else {
                  _showLocationLinkDialog(room['name']!, room['plus_code']!);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/app_colors.dart';
import '../core/student_manager.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  int _selectedDayIndex = 0;
  bool _isLoading = false;
  final List<String> _days = ["السبت", "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس"];

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();

  Future<String?> _askForSection() async {
    String section = "";
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تحديد السيكشن", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: "مثال: A4", border: OutlineInputBorder()),
          onChanged: (value) => section = value,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("إلغاء", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, section),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
            child: const Text("ابدأ التحليل", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSmartSchedule() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    String? userSection = await _askForSection();
    if (userSection == null || userSection.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-8b', // نسخة سريعة جداً ومجانية
        apiKey: 'AIzaSyAPhhxehmMg-QE5LxnUkSkOtbVwjCXz0MM',
        httpClient: http.Client(), // يساعد في تخطي بعض قيود الشبكة
      );

      final imageBytes = await image.readAsBytes();

      final prompt = "أنت مساعد أكاديمي. استخرج جدول سكشن $userSection من الصورة. "
          "أريد النتيجة بصيغة JSON فقط كقائمة مصفوفات للأيام. "
          "التنسيق: {'اليوم': [{'subject': '..', 'doctor': '..', 'room': '..', 'time': '..'}]}";

      final response = await model.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)])
      ]);

      if (response.text == null) throw Exception("رد فارغ");

      String cleanJson = response.text!.trim();
      if (cleanJson.contains("```json")) {
        cleanJson = cleanJson.split("```json")[1].split("```")[0];
      }

      Map<String, dynamic> decodedData = jsonDecode(cleanJson.trim());

      setState(() {
        decodedData.forEach((day, lectures) {
          String normalizedDay = day.trim().replaceAll("أ", "ا");
          for (String d in _days) {
            if (d.replaceAll("أ", "ا") == normalizedDay) {
              for (var lec in lectures) {
                StudentManager().weeklySchedule[d]!.add(Map<String, String>.from(lec));
              }
            }
          }
        });
        _isLoading = false;
      });

      await StudentManager();
      _showSnackBar("تم تحليل الجدول بنجاح!", Colors.green);

    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("فشل التحليل: تأكد من الإنترنت وجودة الصورة", Colors.red);
      print("❌ Error: $e");
    }
  }

  // --- دوال الواجهة (UI) ---
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String currentDay = _days[_selectedDayIndex];
    List<Map<String, String>> currentDayLectures = StudentManager().weeklySchedule[currentDay] ?? [];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      body: Column(
        children: [
          _buildHeaderWithDays(isDark),
          _buildActionButtons(isDark),
          if (_isLoading) const LinearProgressIndicator(color: AppColors.primaryNavy),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: currentDayLectures.length,
              itemBuilder: (context, index) => _buildScheduleItem(currentDayLectures[index], index, currentDay, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithDays(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text("الجدول الدراسي", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: List.generate(_days.length, (index) {
                bool isSelected = _selectedDayIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(_days[index], style: TextStyle(color: isSelected ? AppColors.primaryNavy : Colors.white)),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generateSmartSchedule,
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              label: const Text("جدول ذكي AI", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {}, // إضافة يدوية
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("إضافة يدوية", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, String> item, int index, String day, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(item['subject'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
        subtitle: Text("${item['doctor']} - ${item['room']}"),
        trailing: Text(item['time'] ?? "", style: const TextStyle(color: Colors.grey)),
        leading: const Icon(Icons.book, color: AppColors.primaryNavy),
      ),
    );
  }
}
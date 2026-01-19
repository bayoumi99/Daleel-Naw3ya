import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/student_manager.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  int _selectedDayIndex = 0;
  final List<String> _days = ["السبت", "الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس"];

  // متحكمات النصوص لإدخال البيانات يدوياً
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // دالة لإظهار واجهة إضافة محاضرة جديدة
  void _showAddManualDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl, // لضمان ظهور المحتوى من اليمين لليسار
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "إضافة محاضرة جديدة",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_subjectController, "اسم المادة", Icons.book),
                _buildTextField(_doctorController, "اسم الدكتور", Icons.person),
                _buildTextField(_roomController, "القاعة / المدرج", Icons.location_on),
                _buildTextField(_timeController, "الوقت (مثلاً: 10 ص)", Icons.access_time),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearControllers();
                Navigator.pop(context);
              },
              child: const Text("إلغاء", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: _addLecture,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("حفظ المحاضرة", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء حقل النص في الـ Dialog
  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryNavy),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // دالة حفظ البيانات المضافة
  void _addLecture() {
    if (_subjectController.text.isNotEmpty) {
      String currentDay = _days[_selectedDayIndex];
      setState(() {
        StudentManager().weeklySchedule[currentDay]!.add({
          'subject': _subjectController.text,
          'doctor': _doctorController.text,
          'room': _roomController.text,
          'time': _timeController.text,
        });
      });
      _clearControllers();
      Navigator.pop(context);
      _showSnackBar("تمت الإضافة بنجاح لجدول يوم $currentDay", Colors.green);
    } else {
      _showSnackBar("يرجى إدخال اسم المادة على الأقل", Colors.orange);
    }
  }

  void _clearControllers() {
    _subjectController.clear();
    _doctorController.clear();
    _roomController.clear();
    _timeController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: color),
    );
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
          _buildActionButtons(),
          Expanded(
            child: currentDayLectures.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: currentDayLectures.length,
              itemBuilder: (context, index) => _buildScheduleItem(currentDayLectures[index], index, isDark),
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
            reverse: true, // لتبدأ القائمة من اليمين
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
                    child: Text(
                      _days[index],
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryNavy : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showAddManualDialog,
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text("إضافة محاضرة يدوياً", style: TextStyle(color: Colors.white, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "لا توجد محاضرات في هذا اليوم",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, String> item, int index, bool isDark) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          item['subject'] ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 17),
          textAlign: TextAlign.right,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "${item['doctor']} • ${item['room']}",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            textAlign: TextAlign.right,
          ),
        ),
        leading: Text(
          item['time'] ?? "",
          style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.book, color: AppColors.primaryNavy),
        ),
      ),
    );
  }
}
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

  // متحكمات النصوص
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // --- 1. دالة إضافة محاضرة جديدة ---
  void _showAddManualDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "إضافة محاضرة جديدة",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontFamily: 'Cairo'),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearControllers();
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء", style: TextStyle(color: Colors.red, fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () => _addLecture(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("حفظ", style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  void _addLecture(BuildContext dialogContext) {
    if (_subjectController.text.trim().isNotEmpty) {
      String currentDay = _days[_selectedDayIndex];
      setState(() {
        if (StudentManager().weeklySchedule[currentDay] == null) {
          StudentManager().weeklySchedule[currentDay] = [];
        }
        StudentManager().weeklySchedule[currentDay]!.add({
          'subject': _subjectController.text.trim(),
          'doctor': _doctorController.text.trim().isEmpty ? "غير محدد" : _doctorController.text.trim(),
          'room': _roomController.text.trim().isEmpty ? "غير محدد" : _roomController.text.trim(),
          'time': _timeController.text.trim().isEmpty ? "--:--" : _timeController.text.trim(),
        });
      });
      _clearControllers();
      Navigator.of(dialogContext).pop();
      _showSnackBar("تمت الإضافة بنجاح", Colors.green);
    } else {
      _showSnackBar("يرجى إدخال اسم المادة", Colors.orange);
    }
  }

  // --- 2. دالة حذف محاضرة ---
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("تأكيد الحذف", style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: const Text("هل أنت متأكد من حذف هذه المحاضرة من الجدول؟", style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("تراجع"),
            ),
            TextButton(
              onPressed: () {
                String currentDay = _days[_selectedDayIndex];
                setState(() {
                  StudentManager().weeklySchedule[currentDay]?.removeAt(index);
                });
                Navigator.pop(context);
                _showSnackBar("تم حذف المحاضرة بنجاح", Colors.redAccent);
              },
              child: const Text("حذف الآن", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _clearControllers() {
    _subjectController.clear();
    _doctorController.clear();
    _roomController.clear();
    _timeController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
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
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text("الجدول الدراسي", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
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
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _days[index],
                      style: TextStyle(
                          color: isSelected ? AppColors.primaryNavy : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'Cairo'
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
          label: const Text("إضافة محاضرة جديدة", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Cairo')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, String> item, int index, bool isDark) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item['subject'] ?? "",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy, fontSize: 16, fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          "${item['doctor']} • ${item['room']}",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, size: 14, color: Colors.blueGrey),
            Text(item['time'] ?? "", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
          onPressed: () => _confirmDelete(index), // استدعاء دالة الحذف
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 70, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text("لا توجد محاضرات مضافة", style: TextStyle(color: Colors.grey, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryNavy),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
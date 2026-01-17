import 'package:flutter/material.dart';

class AssignmentsManagementScreen extends StatefulWidget {
  final bool isDarkMode;
  const AssignmentsManagementScreen({super.key, required this.isDarkMode});

  static const routeName = '/Assignments_Management';

  @override
  State<AssignmentsManagementScreen> createState() => _AssignmentsManagementScreenState();
}

class _AssignmentsManagementScreenState extends State<AssignmentsManagementScreen> {

  // دالة فتح نافذة "نشر واجب جديد" (التي تظهر في الصورة)
  void _showNewAssignmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FD),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SingleChildScrollView( // لضمان عدم حدوث Overflow عند ظهور لوحة المفاتيح
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // الرأس: عنوان النافذة وزر إلغاء
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("إلغاء", style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                  Text("نشر واجب جديد",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors.black
                      )),
                  const SizedBox(width: 40),
                ],
              ),
              const Divider(),
              const SizedBox(height: 20),

              // حقل عنوان الواجب
              const Text("عنوان الواجب", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "مثال: مشروع نهائي - تطبيق ويب",
                  filled: true,
                  fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // حقل الوصف
              const Text("الوصف", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                textAlign: TextAlign.right,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "وصف تفصيلي للواجب...",
                  filled: true,
                  fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // اختيار السنة الدراسية
              const Text("السنة الدراسية المستهدفة", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                alignment: Alignment.centerRight,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                value: "السنة الأولى",
                items: ["السنة الأولى", "السنة الثانية", "السنة الثالثة", "السنة الرابعة"]
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),

              // رابط الواجب (اختياري)
              const Text("رابط الواجب (اختياري)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                textAlign: TextAlign.left, // الروابط تكتب بالإنجليزية
                decoration: InputDecoration(
                  hintText: "https://...",
                  filled: true,
                  fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // تاريخ التسليم
              const Text("تاريخ التسليم", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "mm/dd/yyyy",
                  prefixIcon: const Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                },
              ),
              const SizedBox(height: 30),

              // زر النشر النهائي
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("نشر الواجب",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("إدارة الواجبات", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: widget.isDarkMode ? Colors.white : Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // زر "نشر واجب جديد" الرئيسي
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _showNewAssignmentSheet(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("نشر واجب جديد",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),

          // قائمة الواجبات المنشورة (أمثلة)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildAssignmentCard(
                  title: "مشروع نهائي - تطبيق ويب تفاعلي",
                  description: "تطوير تطبيق ويب كامل باستخدام React و Node.js",
                  level: "السنة الثالثة",
                  date: "2026/8/5",
                ),
                _buildAssignmentCard(
                  title: "تقرير عن أنظمة التشغيل",
                  description: "كتابة تقرير شامل عن مقارنة أنظمة التشغيل الحديثة",
                  level: "السنة الثانية",
                  date: "2026/8/7",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard({
    required String title,
    required String description,
    required String level,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF292F91))),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.right, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(date, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const Text(" :التسليم", style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(15)),
                child: Text(level, style: const TextStyle(color: Color(0xFF4285F4), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(child: _buildActionBtn("حذف", Icons.delete_outline, Colors.red.shade50, Colors.red)),
              const SizedBox(width: 15),
              Expanded(child: _buildActionBtn("تعديل", Icons.edit_outlined, Colors.blue.shade50, Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, color: text, size: 18),
        ],
      ),
    );
  }
}
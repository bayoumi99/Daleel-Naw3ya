import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AssignmentsManagementScreen extends StatefulWidget {
  final bool isDarkMode;
  const AssignmentsManagementScreen({super.key, required this.isDarkMode});
  static const routeName = '/Assignments_Management';

  @override
  State<AssignmentsManagementScreen> createState() => _AssignmentsManagementScreenState();
}

class _AssignmentsManagementScreenState extends State<AssignmentsManagementScreen> {
  // تعريف وحدات التحكم لجلب البيانات من الحقول
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String _selectedLevel = "السنة الأولى";
  DateTime? _selectedDate;
  bool _isUploading = false;

  // دالة النشر الفعلي إلى Firebase
  Future<void> _publishAssignment() async {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("برجاء إكمال البيانات الأساسية")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. رفع البيانات إلى مجموعة Assignments
      await FirebaseFirestore.instance.collection('Assignments').add({
        'title': _titleController.text,
        'description': _descController.text,
        'level': _selectedLevel,
        'link': _linkController.text,
        'dueDate': _selectedDate,
        'createdAt': FieldValue.serverTimestamp(),
        'doctorId': FirebaseAuth.instance.currentUser?.uid,
      });

      // 2. محاكاة إرسال إشعار (Notification Logic)
      // هنا يمكنك استدعاء دالة Firebase Messaging لإرسال تنبيه للطلاب
      print("Sending Notification to students of $_selectedLevel...");

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم نشر التكليف وإخطار الطلاب بنجاح ✅")));
        _clearForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _linkController.clear();
    _selectedDate = null;
  }

  // --- تحديث الـ BottomSheet ليدعم الإدخال الحقيقي ---
  void _showNewAssignmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder( // لاستخدام setState داخل الـ Sheet
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FD),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSheetHeader(context),
                const Divider(),
                const SizedBox(height: 20),
                _buildLabel("عنوان الواجب"),
                _buildTextField(_titleController, "مثال: مشروع نهائي", false),
                const SizedBox(height: 20),
                _buildLabel("الوصف"),
                _buildTextField(_descController, "وصف تفصيلي...", false, maxLines: 3),
                const SizedBox(height: 20),
                _buildLabel("السنة الدراسية المستهدفة"),
                _buildLevelDropdown(setSheetState),
                const SizedBox(height: 20),
                _buildLabel("رابط الواجب (اختياري)"),
                _buildTextField(_linkController, "https://...", true),
                const SizedBox(height: 20),
                _buildLabel("تاريخ التسليم"),
                _buildDatePicker(context, setSheetState),
                const SizedBox(height: 30),
                _buildPublishButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- الأجزاء المساعدة للـ UI ---

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

  Widget _buildTextField(TextEditingController controller, String hint, bool isLeft, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      textAlign: isLeft ? TextAlign.left : TextAlign.right,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLevelDropdown(Function setSheetState) {
    return DropdownButtonFormField<String>(
      alignment: Alignment.centerRight,
      value: _selectedLevel,
      items: ["السنة الأولى", "السنة الثانية", "السنة الثالثة", "السنة الرابعة"]
          .map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
      onChanged: (v) => setSheetState(() => _selectedLevel = v!),
      decoration: InputDecoration(filled: true, fillColor: widget.isDarkMode ? Colors.black26 : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }

  Widget _buildDatePicker(BuildContext context, Function setSheetState) {
    return TextField(
      readOnly: true,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: _selectedDate == null ? "اختر التاريخ" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
        prefixIcon: const Icon(Icons.calendar_today),
        filled: true,
        fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
        if (picked != null) setSheetState(() => _selectedDate = picked);
      },
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _publishAssignment,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("نشر الواجب وإرسال إشعار", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء", style: TextStyle(color: Colors.red, fontSize: 16))),
        Text("نشر واجب جديد", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black)),
        const SizedBox(width: 40),
      ],
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
          _buildAddMainButton(),
          Expanded(child: _buildAssignmentsStream()),
        ],
      ),
    );
  }

  Widget _buildAddMainButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: () => _showNewAssignmentSheet(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("نشر واجب جديد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        ),
      ),
    );
  }

  // جلب البيانات لحظياً من Firebase لعرضها في القائمة
  Widget _buildAssignmentsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Assignments').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            return _buildAssignmentCard(
              docId: docs[index].id,
              title: data['title'] ?? "",
              description: data['description'] ?? "",
              level: data['level'] ?? "",
              date: (data['dueDate'] as Timestamp).toDate().toString().split(' ')[0],
            );
          },
        );
      },
    );
  }

  Widget _buildAssignmentCard({required String docId, required String title, required String description, required String level, required String date}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
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
              _buildLevelBadge(level),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(child: InkWell(onTap: () => _deleteAssignment(docId), child: _buildActionBtn("حذف", Icons.delete_outline, Colors.red.shade50, Colors.red))),
              const SizedBox(width: 15),
              Expanded(child: _buildActionBtn("تعديل", Icons.edit_outlined, Colors.blue.shade50, Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAssignment(String id) async {
    await FirebaseFirestore.instance.collection('Assignments').doc(id).delete();
  }

  Widget _buildLevelBadge(String level) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(15)), child: Text(level, style: const TextStyle(color: Color(0xFF4285F4), fontSize: 11, fontWeight: FontWeight.bold)));

  Widget _buildActionBtn(String label, IconData icon, Color bg, Color text) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Icon(icon, color: text, size: 18)]));
  }
}
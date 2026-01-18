import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لتنسيق الوقت

class NotificationsManagementScreen extends StatefulWidget {
  final bool isDarkMode;
  const NotificationsManagementScreen({super.key, required this.isDarkMode});
  static const routeName = '/Notifications_Management';

  @override
  State<NotificationsManagementScreen> createState() => _NotificationsManagementScreenState();
}

class _NotificationsManagementScreenState extends State<NotificationsManagementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String _selectedTarget = "جميع السنوات";
  bool _isUrgent = false;
  bool _isSending = false;

  // دالة إرسال الإشعار لـ Firebase
  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("برجاء إكمال بيانات الإشعار")));
      return;
    }

    setState(() => _isSending = true);

    try {
      await FirebaseFirestore.instance.collection('Notifications').add({
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'target': _selectedTarget,
        'isUrgent': _isUrgent,
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': FirebaseAuth.instance.currentUser?.uid,
        'senderName': "د/ إيناس الحسيني", // يمكن جلبها من ملف المستخدم
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم إرسال الإشعار بنجاح ✅")));
        _titleController.clear();
        _bodyController.clear();
        _isUrgent = false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ في الإرسال: $e")));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showNewNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: widget.isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FD),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSheetHeader(context),
              const Divider(),
              const SizedBox(height: 20),

              _buildLabel("عنوان الإشعار"),
              _buildTextField(_titleController, "مثال: تأجيل محاضرة الغد"),

              const SizedBox(height: 20),
              _buildLabel("نص الإشعار"),
              _buildTextField(_bodyController, "اكتب محتوى الإشعار هنا...", maxLines: 4),

              const SizedBox(height: 20),
              _buildLabel("السنة الدراسية المستهدفة"),
              _buildTargetDropdown(setSheetState),

              const SizedBox(height: 20),
              _buildUrgentToggle(setSheetState),

              const Spacer(),
              _buildSubmitButton(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- دوال بناء الواجهة الصغيرة ---

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) => TextField(
    controller: controller,
    textAlign: TextAlign.right,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    ),
  );

  Widget _buildTargetDropdown(Function setSheetState) => DropdownButtonFormField<String>(
    value: _selectedTarget,
    alignment: Alignment.centerRight,
    decoration: InputDecoration(
      filled: true,
      fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    ),
    items: ["جميع السنوات", "السنة الأولى", "السنة الثانية", "السنة الثالثة", "السنة الرابعة"]
        .map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
    onChanged: (v) => setSheetState(() => _selectedTarget = v!),
  );

  Widget _buildUrgentToggle(Function setSheetState) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: widget.isDarkMode ? Colors.black26 : Colors.white, borderRadius: BorderRadius.circular(15)),
    child: Row(
      children: [
        Checkbox(
          value: _isUrgent,
          onChanged: (val) => setSheetState(() => _isUrgent = val!),
          activeColor: Colors.red,
        ),
        const Spacer(),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(children: [Icon(Icons.error_outline, color: Colors.red, size: 20), SizedBox(width: 5), Text("إشعار عاجل", style: TextStyle(fontWeight: FontWeight.bold))]),
            Text("سيظهر هذا الإشعار بشكل بارز للطلاب", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    ),
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton.icon(
      onPressed: _isSending ? null : _sendNotification,
      icon: _isSending ? const SizedBox.shrink() : const Icon(Icons.send_rounded, color: Colors.white),
      label: _isSending
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("إرسال الإشعار الآن", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
    ),
  );

  Widget _buildSheetHeader(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء", style: TextStyle(color: Colors.red, fontSize: 16))),
      Text("إرسال إشعار جديد", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black)),
      const SizedBox(width: 40),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("إدارة الإشعارات", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: widget.isDarkMode ? Colors.white : Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopActionButton(),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("الإشعارات المرسلة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 15),
          Expanded(child: _buildNotificationsStream()),
        ],
      ),
    );
  }

  Widget _buildTopActionButton() => Padding(
    padding: const EdgeInsets.all(20.0),
    child: SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () => _showNewNotificationSheet(context),
        icon: const Icon(Icons.send_rounded, color: Colors.white),
        label: const Text("إرسال إشعار جديد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4285F4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      ),
    ),
  );

  Widget _buildNotificationsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Notifications').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            DateTime? date = (data['timestamp'] as Timestamp?)?.toDate();
            String timeAgo = date != null ? DateFormat('jm', 'ar').format(date) : "الآن";

            return _buildNotificationCard(
              title: data['title'] ?? "",
              body: data['body'] ?? "",
              time: timeAgo,
              target: data['target'] ?? "الجميع",
              isUrgent: data['isUrgent'] ?? false,
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationCard({required String title, required String body, required String time, required String target, required bool isUrgent}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isUrgent) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)), child: const Text("عاجل", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))),
              const Spacer(),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Icon(Icons.notifications_active, color: isUrgent ? Colors.red : Colors.blue),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade600, height: 1.4)),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)), child: Text(target, style: const TextStyle(color: Color(0xFF4285F4), fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }
}
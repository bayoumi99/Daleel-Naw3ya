import 'package:flutter/material.dart';

class NotificationsManagementScreen extends StatefulWidget {
  final bool isDarkMode;
  const NotificationsManagementScreen({super.key, required this.isDarkMode});

  static const routeName = '/Notifications_Management';

  @override
  State<NotificationsManagementScreen> createState() => _NotificationsManagementScreenState();
}

class _NotificationsManagementScreenState extends State<NotificationsManagementScreen> {

  // دالة فتح نافذة "إرسال إشعار جديد" (التي طلبتها مؤخراً)
  void _showNewNotificationSheet(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // العنوان وزر الإلغاء
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء", style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
                Text("إرسال إشعار جديد",
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

            // عنوان الإشعار
            const Text("عنوان الإشعار", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "مثال: تأجيل محاضرة الغد",
                filled: true,
                fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),

            // نص الإشعار
            const Text("نص الإشعار", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              textAlign: TextAlign.right,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "اكتب محتوى الإشعار هنا...",
                filled: true,
                fillColor: widget.isDarkMode ? Colors.black26 : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              hint: const Text("جميع السنوات"),
              items: ["جميع السنوات", "السنة الأولى", "السنة الثانية", "السنة الثالثة", "السنة الرابعة"]
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),

            // خيار إشعار عاجل
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.black26 : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Checkbox(value: false, onChanged: (val) {}),
                  const Spacer(),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 20),
                          SizedBox(width: 5),
                          Text("إشعار عاجل", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text("سيظهر هذا الإشعار بشكل بارز للطلاب", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),

            // زر الإرسال
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // هنا يتم الربط مع Firebase مستقبلاً
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text("إرسال الإشعار", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

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
          // زر فتح النافذة المنبثقة
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _showNewNotificationSheet(context),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text("إرسال إشعار جديد",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("الإشعارات المرسلة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 15),

          // عرض الإشعارات السابقة
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildNotificationCard(
                  title: "تأجيل محاضرة الغد",
                  body: "تم تأجيل محاضرة برمجة الويب من الساعة 9 صباحاً إلى 11 صباحاً",
                  time: "منذ 2 ساعة",
                  target: "السنة الثالثة",
                  isUrgent: true,
                ),
                _buildNotificationCard(
                  title: "تنبيه من د/ إيناس الحسيني",
                  body: "الرجاء مراجعة جدول الأحمال التدريسية المحدث للفصل الدراسي الأول [cite: 9, 59]",
                  time: "منذ 5 ساعات",
                  target: "جميع الفرق",
                  isUrgent: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String body,
    required String time,
    required String target,
    required bool isUrgent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                  child: const Text("عاجل", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
                child: Text(target, style: const TextStyle(color: Color(0xFF4285F4), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  // قائمة تجريبية للإشعارات مع تحديد الأهمية (High, Medium, Normal)
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "title": "تنبيه محاضرة قادمة",
      "body": "محاضرة تكنولوجيا التعليم ستبدأ بعد 15 دقيقة في مدرج 2.",
      "time": DateTime.now().add(const Duration(minutes: 15)),
      "priority": "High", // أهمية قصوى
      "type": "schedule", // نوع الإشعار (جدول)
    },
    {
      "id": 2,
      "title": "إشعار من د. أحمد علي",
      "body": "تم تأجيل موعد تسليم التكليف الأول إلى يوم الخميس القادم.",
      "time": DateTime.now().subtract(const Duration(hours: 2)),
      "priority": "Medium", // أهمية متوسطة
      "type": "doctor", // من الدكتور
    },
    {
      "id": 3,
      "title": "تنبيه سكشن",
      "body": "لديك سكشن حاسب آلي غداً الساعة 10 صباحاً.",
      "time": DateTime.now().add(const Duration(days: 1)),
      "priority": "Normal",
      "type": "schedule",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ترتيب الإشعارات: الأهمية القصوى (High) تظهر أولاً
    _notifications.sort((a, b) {
      Map<String, int> priorityMap = {"High": 0, "Medium": 1, "Normal": 2};
      return priorityMap[a['priority']]!.compareTo(priorityMap[b['priority']]!);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("الإشعارات والتنبيهات"),
        backgroundColor: const Color(0xFF292F91),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // يمكن إضافة فلترة هنا
            },
          )
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(_notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    Color priorityColor;
    IconData iconData;

    // تحديد اللون والأيقونة بناءً على نوع وأهمية الإشعار
    switch (notification['priority']) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    iconData = notification['type'] == 'schedule'
        ? Icons.alarm_on
        : Icons.notifications_active;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: notification['priority'] == 'High'
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: priorityColor.withOpacity(0.1),
          child: Icon(iconData, color: priorityColor),
        ),
        title: Text(
          notification['title'],
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 5),
            Text(notification['body'], textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat('hh:mm a  |  yyyy/MM/dd', 'ar').format(notification['time']),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.access_time, size: 12, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text("لا توجد إشعارات جديدة حالياً", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}
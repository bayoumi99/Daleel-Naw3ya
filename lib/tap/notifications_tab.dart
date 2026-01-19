import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("الإشعارات والتنبيهات"),
        centerTitle: true,
        backgroundColor: const Color(0xFF292F91),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // استخدام StreamBuilder للاتصال الحي بـ Firebase
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications') // تأكد أن الاسم مطابق في Firebase
            .orderBy('time', descending: true) // الأحدث يظهر في الأعلى
            .snapshots(),
        builder: (context, snapshot) {
          // حالة التحميل
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // حالة الخطأ
          if (snapshot.hasError) {
            return const Center(child: Text("حدث خطأ في جلب البيانات"));
          }

          // حالة عدم وجود إشعارات
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var notificationsList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: notificationsList.length,
            itemBuilder: (context, index) {
              var data = notificationsList[index].data() as Map<String, dynamic>;
              return _buildNotificationCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    Color priorityColor;
    IconData iconData;

    // معالجة الوقت القادم من Firebase
    DateTime notificationTime = DateTime.now();
    if (notification['time'] != null) {
      notificationTime = (notification['time'] as Timestamp).toDate();
    }

    // تحديد اللون بناءً على الأهمية
    switch (notification['priority']) {
      case 'High':
        priorityColor = Colors.red;
        iconData = Icons.priority_high;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        iconData = Icons.notification_important;
        break;
      default:
        priorityColor = Colors.blue;
        iconData = Icons.notifications_active;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: notification['priority'] == 'High'
            ? Border.all(color: Colors.red.withOpacity(0.2), width: 1.5)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: priorityColor.withOpacity(0.1),
          child: Icon(iconData, color: priorityColor),
        ),
        title: Text(
          notification['title'] ?? "إشعار جديد",
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF292F91),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 8),
            Text(
              notification['body'] ?? "",
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey.shade800, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat('yyyy/MM/dd | hh:mm a', 'ar').format(notificationTime),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            "لا توجد تنبيهات من الدكاترة حالياً",
            style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
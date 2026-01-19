import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  // 1. تعريف الـ Stream كمتغير ثابت لمنع الاختفاء المفاجئ
  late Stream<QuerySnapshot> _notificationsStream;

  @override
  void initState() {
    super.initState();
    // 2. تهيئة الاتصال بـ Firebase مرة واحدة فقط عند فتح الصفحة
    _notificationsStream = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('time', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("الإشعارات والتنبيهات", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF292F91),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          // حالة وجود خطأ (مثل Permission Denied)
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          // حالة التحميل (تظهر لأول مرة فقط)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF292F91)));
          }

          // حالة عدم وجود بيانات
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var notificationsList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: notificationsList.length,
            itemBuilder: (context, index) {
              var doc = notificationsList[index];
              var data = doc.data() as Map<String, dynamic>;
              // استخدام documentID كـ Key لضمان ثبات العنصر في الذاكرة
              return _buildNotificationCard(data, ValueKey(doc.id));
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, Key key) {
    Color priorityColor;
    IconData iconData;

    // معالجة آمنة للوقت القادم من السيرفر
    DateTime notificationTime = DateTime.now();
    if (notification['time'] != null && notification['time'] is Timestamp) {
      notificationTime = (notification['time'] as Timestamp).toDate();
    }

    // تحديد اللون والأيقونة بناءً على الأهمية
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
      key: key, // مهم جداً لمنع اختفاء العنصر
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
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1.5)
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
              style: TextStyle(color: Colors.grey.shade800, height: 1.4, fontSize: 14),
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
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            "لا توجد تنبيهات حالياً",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text("خطأ في جلب الإشعارات: $error", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
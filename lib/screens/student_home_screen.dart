import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../core/app_colors.dart';
import '../core/student_manager.dart';
import '../tap/profile_tab.dart';
import '../tap/schedule_tab.dart';
import '../tap/tasks_tab.dart';
import 'CollegeGuideScreen/CollegeGuideScreen.dart';

class StudentHomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const StudentHomeScreen({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 3);
  }

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: [
        _buildNotificationsTab(), // الكود الجديد للإشعارات
        _buildQuizzesTab(),       // الكود الجديد للاختبارات
        const AssignmentsTab(),
        _buildDashboard(),
        const ScheduleTab(),
        ProfileScreen(isDarkMode: widget.isDarkMode, onThemeChanged: widget.onThemeChanged, onDataChanged: refresh),
      ],
      items: _navBarsItems(),
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      navBarStyle: NavBarStyle.style7,
      onItemSelected: (index) {
        if (index == 3) setState(() {});
      },
    );
  }

  // --- 1. شاشة التنبيهات المرتبطة بـ Firebase ---
  Widget _buildNotificationsTab() {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("التنبيهات", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: widget.isDarkMode ? Colors.white : Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .where('target', whereIn: [StudentManager().level, 'جميع السنوات'])
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return _buildEmptyStateCustom("لا توShort الإشعارات حالياً");

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Icon(Icons.notifications_active, color: data['isUrgent'] == true ? Colors.red : Colors.blue),
                  title: Text(data['title'], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['body'], textAlign: TextAlign.right),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- 2. شاشة الاختبارات المرتبطة بـ Firebase ---
  Widget _buildQuizzesTab() {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("الاختبارات المتاحة", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: widget.isDarkMode ? Colors.white : Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Quizzes')
            .where('level', isEqualTo: StudentManager().level)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) return _buildEmptyStateCustom("لا توجد اختبارات لفرقتك حالياً");

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var quiz = docs[index].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: const Border(right: BorderSide(color: Colors.orange, width: 6)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {}, // سيتم برمجة صفحة الحل لاحقاً
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text("دخول", style: TextStyle(color: Colors.white)),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(quiz['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("مدة الاختبار: ${quiz['duration'] ?? '30'} دقيقة", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- 3. تعديل الـ Dashboard لجلب أرقام حقيقية ---
  Widget _buildDashboard() {
    String formattedDate = DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now());
    List<Map<String, String>> todayLectures = StudentManager().getTodayLectures();

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
              decoration: const BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                        child: Text(formattedDate, style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("مرحباً👋", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          Text(StudentManager().name, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                          Text("${StudentManager().level} - ${StudentManager().dept}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard("محاضرات اليوم", todayLectures.length.toString()),
                      // سنترك هذه ثابتة حالياً أو نربطها بـ StreamBuilder لاحقاً
                      _buildStatCard("الواجبات", "3"),
                      _buildStatCard("الاختبارات", "2"),
                    ],
                  ),
                ],
              ),
            ),
            _buildGuideButton(),
            _buildSectionHeader("جدول اليوم"),
            if (todayLectures.isEmpty)
              _buildEmptyState()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: todayLectures.map((lecture) => _buildInfoCard(
                    lecture['subject'] ?? "",
                    lecture['time'] ?? "",
                    lecture['room'] ?? "",
                    lecture['doctor'] ?? "",
                  )).toList(),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- الدوال المساعدة (UI Helpers) ---

  Widget _buildEmptyStateCustom(String message) {
    return Center(child: Text(message, style: const TextStyle(color: Colors.grey)));
  }

  // بقية الدوال (navBarsItems, _item, _buildGuideButton, _buildEmptyState, _buildInfoCard, _buildStatCard, _buildSectionHeader)
  // تبقى كما هي في كودك الأصلي...

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      _item(Icons.notifications_none, "تنبيهات"),
      _item(Icons.quiz_outlined, "اختبارات"),
      _item(Icons.assignment_outlined, "تكاليف"),
      _item(Icons.home, "الرئيسية"),
      _item(Icons.calendar_month_outlined, "جدول"),
      _item(Icons.person_outline, "شخصي"),
    ];
  }

  PersistentBottomNavBarItem _item(IconData icon, String title) {
    return PersistentBottomNavBarItem(
      icon: Icon(icon),
      title: title,
      activeColorPrimary: AppColors.primaryNavy,
      activeColorSecondary: Colors.white,
      inactiveColorPrimary: Colors.grey.shade400,
    );
  }

  Widget _buildGuideButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CollegeGuideScreen(isDarkMode: widget.isDarkMode)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border.all(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.menu_book_rounded, color: widget.isDarkMode ? Colors.blueAccent : AppColors.primaryNavy),
              Text("دليل نوعية", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : AppColors.primaryNavy)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)),
      child: Column(children: [Icon(Icons.event_available, size: 50, color: Colors.grey.withOpacity(0.5)), const SizedBox(height: 10), const Text("لا توجد محاضرات مجدولة لهذا اليوم", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))]),
    );
  }

  Widget _buildInfoCard(String title, String time, String room, String doctor) {
    bool isDark = widget.isDarkMode;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border(right: BorderSide(color: isDark ? AppColors.primaryNavy.withOpacity(0.5) : AppColors.primaryNavy, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Column(children: [Icon(Icons.access_time, size: 20, color: isDark ? Colors.blueAccent : AppColors.primaryNavy), Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : Colors.black87))]),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.blueAccent : AppColors.primaryNavy)),
              if(doctor.isNotEmpty) Text("دكتور: $doctor", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
              Text("المكان: $room", style: TextStyle(color: isDark ? Colors.blue.shade200 : AppColors.primaryNavy, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count) {
    return Container(
      width: 95, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 9)),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("عرض الكل", style: TextStyle(color: Colors.blue, fontSize: 12)),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkMode? Colors.white : AppColors.primaryNavy)),
      ]),
    );
  }
}
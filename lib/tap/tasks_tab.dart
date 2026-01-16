import 'package:flutter/material.dart';

import '../core/app_colors.dart';
class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({super.key});

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["الكل", "الحالية", "قيد التنفيذ", "تم التسليم"];

  final List<Map<String, dynamic>> _assignments = [
    {
      "id": 1,
      "title": "مشروع نهائي - تطبيق ويب تفاعلي",
      "subject": "برمجة الويب",
      "desc": "تطوير تطبيق ويب كامل باستخدام React و Node.js",
      "timeLeft": "باقي 4 أيام",
      "status": "الحالية",
    },
    {
      "id": 2,
      "title": "تصميم قاعدة بيانات",
      "subject": "قواعد البيانات",
      "desc": "تصميم قاعدة بيانات لنظام إدارة مكتبة شامل",
      "timeLeft": "باقي 9 أيام",
      "status": "قيد التنفيذ",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // تحديد هل الوضع ليلي أم لا بناءً على ثيم الجهاز/التطبيق
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    List<Map<String, dynamic>> filteredList = _assignments.where((item) {
      if (_selectedFilterIndex == 0) return true;
      return item['status'] == _filters[_selectedFilterIndex];
    }).toList();

    return Scaffold(
      // تغيير خلفية السكافولد
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 25, right: 20, left: 20),
            decoration: const BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "التكاليف الدراسية",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.assignment_outlined, color: Colors.white, size: 28),
                  ],
                ),
                const SizedBox(height: 35),
                _buildFilterRow(isDark),
              ],
            ),
          ),

          Expanded(
            child: filteredList.isEmpty
                ? Center(
              child: Text(
                "لا توجد تكاليف حالياً",
                style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: filteredList.length,
              itemBuilder: (context, index) => _buildAssignmentCard(filteredList[index], isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            bool isSelected = _selectedFilterIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryNavy : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> item, bool isDark) {
    bool isPending = item['status'] == "قيد التنفيذ";
    bool isDone = item['status'] == "تم التسليم";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // لون الكارت يتغير للرمادي الغامق في الـ Dark Mode
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  // لون التاج (باقي x يوم)
                  color: isDark ? Colors.blue.withOpacity(0.1) : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                    item['timeLeft'],
                    style: TextStyle(
                        color: isDark ? Colors.blue.shade200 : Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      item['title'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.primaryNavy
                      )
                  ),
                  Text(
                      item['subject'],
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12)
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              item['desc'],
              textAlign: TextAlign.right,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)
          ),
          const SizedBox(height: 20),
          if (isDone)
            _buildStatusStatic(
                "تم التسليم بنجاح",
                Icons.check_circle,
                isDark ? Colors.green.withOpacity(0.1) : const Color(0xFFE8F5E9),
                Colors.green
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                      "تم التسليم",
                      Icons.check_circle_outline,
                      const Color(0xFF2D62ED),
                      Colors.white,
                          () => _updateStatus(item['id'], "تم التسليم")
                  ),
                ),
                const SizedBox(width: 10),
                if (!isPending)
                  Expanded(
                    child: _buildButton(
                        "قيد التنفيذ",
                        Icons.radio_button_unchecked,
                        isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                        isDark ? Colors.blue.shade200 : const Color(0xFF2D62ED),
                            () => _updateStatus(item['id'], "قيد التنفيذ")
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "رابط الواجب ←",
                style: TextStyle(
                    color: isDark ? Colors.blue.shade300 : const Color(0xFF2D62ED),
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, IconData icon, Color bg, Color text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 6),
            Icon(icon, color: text, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStatic(String text, IconData icon, Color bg, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, color: color, size: 20),
        ],
      ),
    );
  }

  void _updateStatus(int id, String newStatus) {
    setState(() {
      _assignments.firstWhere((e) => e['id'] == id)['status'] = newStatus;
    });
  }
}
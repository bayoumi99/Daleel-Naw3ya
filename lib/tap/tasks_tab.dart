import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentsTab extends StatefulWidget {
  const AssignmentsTab({super.key});

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ["الكل", "الحالية", "قيد التنفيذ", "تم التسليم"];

  // الألوان الأربعة المطلوبة للخلفية
  final List<Color> _brandColors = [
    const Color(0xFFD6E6F3), // ICE BLUE
    const Color(0xFFA6C5D7), // POWDER BLUE
    const Color(0xFF0F52BA), // SAPPHIRE
    const Color(0xFF000926), // DEEP NAVY
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      body: Column(
        children: [
          // الـ Header مع التدرج اللوني الرباعي
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 25, right: 20, left: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _brandColors,
              ),
              borderRadius: const BorderRadius.only(
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
                _buildFilterRow(),
              ],
            ),
          ),

          // عرض البيانات مع معالجة خطأ Permission Denied
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('assignments').snapshots(),
              builder: (context, snapshot) {
                // 1. حالة التحميل
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. معالجة الخطأ (حل مشكلة الصورة الأخيرة Permission Denied)
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_clock, size: 60, color: Colors.amber),
                          const SizedBox(height: 15),
                          const Text(
                            "خطأ في صلاحيات الوصول",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "تأكد من تعديل الـ Rules في Firebase Console لتسمح بالقراءة",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () => setState(() {}),
                            child: const Text("إعادة المحاولة"),
                          )
                        ],
                      ),
                    ),
                  );
                }

                // 3. حالة عدم وجود بيانات
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                // فلترة البيانات بناءً على التبويب المختار
                var filteredList = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String status = data['status']?.toString() ?? "الحالية";
                  if (_selectedFilterIndex == 0) return true;
                  return status == _filters[_selectedFilterIndex];
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(child: Text("لا توجد تكاليف ${_filters[_selectedFilterIndex]}"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    var data = filteredList[index].data() as Map<String, dynamic>;
                    String docId = filteredList[index].id;
                    return _buildAssignmentCard(data, docId, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
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
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0F52BA) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> item, String docId, bool isDark) {
    String status = item['status']?.toString() ?? "الحالية";
    bool isDone = status == "تم التسليم";
    bool isPending = status == "قيد التنفيذ";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge(item['timeLeft']?.toString() ?? "غير محدد"),
              Text(
                item['title']?.toString() ?? "بدون عنوان",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF000926)
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item['subject']?.toString() ?? "مادة دراسية", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 12),
          Text(
            item['desc']?.toString() ?? "لا يوجد وصف لهذا التكليف",
            textAlign: TextAlign.right,
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          if (isDone)
            _buildStaticStatus("تم تسليم هذا التكليف", Icons.check_circle, Colors.green)
          else
            Row(
              children: [
                Expanded(
                  child: _buildButton("تسليم الآن", Icons.upload_file, const Color(0xFF0F52BA), Colors.white,
                          () => _updateStatus(docId, "تم التسليم")),
                ),
                if (!isPending) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildButton("بدء العمل", Icons.play_arrow_outlined, Colors.grey.shade100, Colors.black87,
                            () => _updateStatus(docId, "قيد التنفيذ")),
                  ),
                ]
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF0F52BA).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Color(0xFF0F52BA), fontSize: 11, fontWeight: FontWeight.bold)),
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
            Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Icon(icon, color: text, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticStatus(String text, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 70, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text("لا يوجد تكاليف في هذا القسم", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
        ],
      ),
    );
  }

  void _updateStatus(String docId, String newStatus) {
    FirebaseFirestore.instance.collection('assignments').doc(docId).update({'status': newStatus});
  }
}
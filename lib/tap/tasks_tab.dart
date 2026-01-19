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

  // اللون الأزرق الأساسي للهيدر
  final Color _primaryBlue = const Color(0xFF0F52BA);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      body: Column(
        children: [
          // الـ Header بلون أزرق سادة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 25, right: 20, left: 20),
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "التكاليف الدراسية",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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

          // عرض البيانات من Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('assignments').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState();
                }

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
                  return Center(
                    child: Text(
                      "لا توجد تكاليف ${_filters[_selectedFilterIndex]}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
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
                    color: isSelected ? _primaryBlue : Colors.white,
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
                  color: isDark ? Colors.white : const Color(0xFF000926),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['subject']?.toString() ?? "مادة دراسية",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            item['desc']?.toString() ?? "لا يوجد وصف لهذا التكليف",
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          if (isDone)
            _buildStaticStatus("تم تسليم هذا التكليف", Icons.check_circle, Colors.green)
          else
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    "تسليم الآن",
                    Icons.upload_file,
                    _primaryBlue,
                    Colors.white,
                        () => _updateStatus(docId, "تم التسليم"),
                  ),
                ),
                if (!isPending) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildButton(
                      "بدء العمل",
                      Icons.play_arrow_outlined,
                      isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      isDark ? Colors.white : Colors.black87,
                          () => _updateStatus(docId, "قيد التنفيذ"),
                    ),
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
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _primaryBlue,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_clock, size: 60, color: Colors.amber),
          const SizedBox(height: 15),
          const Text("خطأ في صلاحيات الوصول", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () => setState(() {}), child: const Text("إعادة المحاولة")),
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
          Text("لا يوجد تكاليف حالياً", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
        ],
      ),
    );
  }

  void _updateStatus(String docId, String newStatus) {
    FirebaseFirestore.instance
        .collection('assignments')
        .doc(docId)
        .update({'status': newStatus});
  }
}
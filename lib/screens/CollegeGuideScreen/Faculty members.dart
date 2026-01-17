import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class FacultyMembersScreen extends StatefulWidget {
  final bool isDarkMode;

  const FacultyMembersScreen({super.key, required this.isDarkMode});
  static const routeName = '/Faculty_Members';

  @override
  State<FacultyMembersScreen> createState() => _FacultyMembersScreenState();
}

class _FacultyMembersScreenState extends State<FacultyMembersScreen> {

// القائمة مرتبة حسب الدرجات العلمية مع مسارات الصور المحلية
// القائمة النهائية مرتبة حسب الدرجات العلمية من ملف الأحمال التدريسية
  final List<Map<String, String>> staffList = [
    // الدرجة: أستاذ دكتور (أ.د)
    {
      "name": "أ.د/ زينب محمد أمين",
      "title": "أستاذ تكنولوجيا التعليم",
      "degree": "عميد الكلية الأسبق ورئيس القسم الأسبق",
      "image": "lib/assets/images/زينب.png",
    },
    {
      "name": "أ.د/ وفاء صلاح الدين الدسوقي",
      "title": "أستاذ تكنولوجيا التعليم",
      "degree": "رئيس قسم تكنولوجيا التعليم الأسبق",
      "image": "lib/assets/images/وفاء.png",
    },
    {
      "name": "أ.د/ إيمان زكي موسى",
      "title": "أستاذ تكنولوجيا التعليم",
      "degree": "عميد كلية التربية النوعية",
      "image": "lib/assets/images/ايمان زكي .png",
    },
    {
      "name": "أ.د/ إيناس محمد الحسيني",
      "title": "أستاذ ورئيس قسم تكنولوجيا التعليم",
      "degree": "رئيس القسم الحالي",
      "image": "lib/assets/images/ايناس.png",
    },
    {
      "name": "أ.د/ شيماء سمير محمد",
      "title": "أستاذ تكنولوجيا التعليم",
      "degree": "أستاذ بالقسم - جامعة المنيا",
      "image": "lib/assets/images/شيماء.png",
    },
    {
      "name": "أ.د/ محمد عبد الرحمن مرسي",
      "title": "أستاذ تكنولوجيا التعليم",
      "degree": "أستاذ بالقسم - جامعة المنيا",
      "image": "lib/assets/images/محمد عبد الرحمن.png",
    },

    // الدرجة: أستاذ مساعد دكتور (أ.م.د)
    {
      "name": "أ.م.د/ ممدوح عبد الحميد إبراهيم",
      "title": "أستاذ مساعد تكنولوجيا التعليم",
      "degree": "أستاذ مساعد بالقسم",
      "image": "lib/assets/images/ممدوح.png",
    },
    {
      "name": "أ.م.د/ سعودي صالح عبد العليم",
      "title": "أستاذ مساعد تكنولوجيا التعليم",
      "degree": "أستاذ مساعد بالقسم",
      "image": "lib/assets/images/سعودي.png",
    },
    {
      "name": "أ.م.د/ محمد أبو الليل عبد الوكيل",
      "title": "أستاذ مساعد تكنولوجيا التعليم",
      "degree": "أستاذ مساعد بالقسم",
      "image": "lib/assets/images/محمد أبو الليل.png",
    },
    {
      "name": "أ.م.د/ محمد يوسف أحمد",
      "title": "أستاذ مساعد تكنولوجيا التعليم",
      "degree": "أستاذ مساعد بالقسم",
      "image": "lib/assets/images/محمد يوسف.png",
    },
    {
      "name": "أ.م.د/ نهى علي سيد",
      "title": "أستاذ مساعد تكنولوجيا التعليم",
      "degree": "أستاذ مساعد بالقسم",
      "image": "lib/assets/images/نهى.png",
    },

    // الدرجة: مدرس (د)
    {
      "name": "د/ عماد أحمد سيد",
      "title": "مدرس تكنولوجيا التعليم",
      "degree": "مدرس بالقسم",
      "image": "lib/assets/images/عماد.png",
    },
    {
      "name": "د/ أدهم كامل نصر",
      "title": "مدرس تكنولوجيا التعليم",
      "degree": "مدرس بالقسم",
      "image": "lib/assets/images/ادهم.png",
    },
    {
      "name": "د/ رزق علي أحمد",
      "title": "مدرس تكنولوجيا التعليم",
      "degree": "مدرس بالقسم",
      "image": "lib/assets/images/رزق.png",
    },
    {
      "name": "د/ نسرين عزت ذكي",
      "title": "مدرس تكنولوجيا التعليم",
      "degree": "مدرس بالقسم",
      "image": "lib/assets/images/نسرين.png",
    },
    {
      "name": "د/ هبة أحمد عبد الجواد",
      "title": "مدرس تكنولوجيا التعليم",
      "degree": "مدرس بالقسم",
      "image": "lib/assets/images/هبة.png",
    },
    {
      "name": "د/ نورا عادل خليفة",
      "title": "مدرس تكنولوجيا التعليم",
      "degree": "مدرس بالقسم",
      "image": "lib/assets/images/نورا.png",
    },
    {
      "name": "د/ إسراء عبد العظيم الفرجاني",
      "title": "مدرس تكنولوجيا التعليم",
      "degree": "مدرس بالقسم",
      "image": "lib/assets/images/اسراء.png",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text(
          "أعضاء هيئة التدريس",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          return _buildStaffCard(staffList[index]);
        },
      ),
    );
  }

  Widget _buildStaffCard(Map<String, String> staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDarkMode ? 0.4 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // البيانات الوظيفية (تأخذ المساحة المتبقية)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  staff['name']!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.blueAccent : AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  staff['title']!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  staff['degree']!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: widget.isDarkMode ? Colors.grey : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // الصورة الشخصية
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryNavy.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.grey.shade200,
              // يفضل استبدالها بـ AssetImage عند توفر الصور محلياً
              backgroundImage: NetworkImage(staff['image']!),
              child: staff['image']!.contains("placeholder")
                  ? Icon(Icons.person, color: Colors.grey.shade400, size: 40)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
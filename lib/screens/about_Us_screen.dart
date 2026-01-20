import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AboutUsScreen extends StatefulWidget {
  static const String routeName = "AboutUsScreen";

  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("عن فريق التطوير", style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
        centerTitle: true,
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          // 1. الهيدر مع اللوجو بحجم كبير جداً
          SliverToBoxAdapter(
            child: _buildTeamHeader(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 25)),

          // 2. عنوان المطورين
          const SliverToBoxAdapter(
            child: Center(
              child: Text(
                "مطوروا النظام",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // 3. شبكة المطورين (GridView) مع رجوع مكان الصور
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // تم تعديله ليناسب وجود الصورة والنص
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
              ),
              delegate: SliverChildListDelegate([
                _buildMemberCard("محمد بيومي مصطفى", "Lead Developer", "lib/assets/images/member1.png"),
                _buildMemberCard("مصطفى محمد حسن الفكري", "Mobile Developer", "lib/assets/images/member2.png"),
                _buildMemberCard("مصطفى علي سيد", "UI/UX Designer", "lib/assets/images/member3.png"),
                _buildMemberCard("يوسف سيد رشدي", "Backend Developer", "lib/assets/images/member4.png"),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 10, left: 10, right: 10),
      decoration: const BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // تم تكبير اللوجو ليأخذ 80% من عرض الشاشة ليكون ضخم
          Image.asset(
            "lib/assets/images/codeare.png",
            width: MediaQuery.of(context).size.width * 0.8,
            height: 200, // ارتفاع ثابت لضمان الوضوح
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          const Text(
            "CodeAre Team",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2
            ),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "نحن فريق متخصص في حلول البرمجيات وتطوير تطبيقات الموبايل. نسعى لتقديم تجربة مستخدم فريدة وحلول تقنية مبتكرة تلبي احتياجات المستخدمين بأعلى معايير الجودة.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.6,
                  fontFamily: 'Cairo'
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(String name, String role, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8)
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // رجوع مكان الصورة (بإمكانك تغيير AssetImage بالمسار الصحيح)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              // افصل السطر القادم لو الصور مش جاهزة واستخدم Icon
              backgroundImage: AssetImage(imagePath),
              child: Icon(Icons.person, size: 40, color: AppColors.primaryNavy), // لو مفيش صورة
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            role,
            style: const TextStyle(
                fontSize: 10,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}
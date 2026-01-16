import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'login_screen.dart';

class IntroScreen extends StatelessWidget {
  static const String routeName = "/intro";

  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF292F91);
    const Color accentColor = Color(0xFF4C55C4);

    return Scaffold(
      backgroundColor: Colors.white,
      body: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        pages: [
          _buildPremiumPage(
            image: "lib/assets/images/welcom2.png",
            title: "مرحبًا بك في دليل نوعية ",
            body: "اكتشف تجربة  فريدة مصممة خصيصاً لتبسيط حياتك اليومية. نحن هنا لنكون رفيقك الدائم في كل خطوة.",
          ),
          _buildPremiumPage(
            image: "lib/assets/images/need2.png",
            title: "كل ما تحتاجه في متناول يدك",
            body: "من القاعات الدراسية إلى الجداول؛ وفرنا لك قاعدة بيانات شاملة تغنيك عن البحث العشوائي وتوفر وقتك.",
          ),
          _buildPremiumPage(
            image: "lib/assets/images/easy2.png",
            title: "بساطة، سرعة، وأمان مطلق",
            body: "استمتع بواجهة مستخدم سلسة وتقنيات حماية متطورة. بياناتك في أمان تام بينما تبحر في خدماتنا الذكية.",
          ),
        ],
        onDone: () => Navigator.pushReplacementNamed(context, DynamicSignupScreen.routeName),

        showSkipButton: true,
        skip: const Text(
          "تخطي",
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w600),
        ),

        // 1. زر السهم (تم تصغير الحجم ليكون أرق)
        next: Container(
          height: 50, // تم التصغير من 60 لـ 50
          width: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryColor, accentColor]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28), // أيقونة أصغر
        ),

        // 2. زر ابدأ (تم تصغير الحجم ليكون ملموماً أكثر)
        done: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // تقليل الحشو الداخلي
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryColor, accentColor]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            "ابدأ الآن",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
          ),
        ),

        // 3. نقاط التنقل (تم تكبير الحجم لتكون مميزة)
        dotsDecorator: const DotsDecorator(
          size: Size(12, 12), // تكبير النقطة العادية من 10 لـ 12
          activeSize: Size(35, 12), // تكبير النقطة النشطة لتكون أوضح
          activeColor: primaryColor,
          color: Color(0xFFE5E7EB),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          spacing: EdgeInsets.symmetric(horizontal: 5), // زيادة المسافة بين النقاط
        ),

        controlsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
      ),
    );
  }

  PageViewModel _buildPremiumPage({
    required String image,
    required String title,
    required String body,
  }) {
    return PageViewModel(
      title: title,
      body: body,
      image: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(75),
            bottomRight: Radius.circular(75),
          ),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
      ),
      decoration: PageDecoration(
        imageFlex: 65,
        bodyFlex: 35,
        fullScreen: false,
        contentMargin: EdgeInsets.zero,
        imagePadding: EdgeInsets.zero,
        titlePadding: const EdgeInsets.only(top: 25, bottom: 5),
        titleTextStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Color(0xFF111827),
          height: 1.2,
        ),
        bodyTextStyle: TextStyle(
          fontSize: 22,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
        bodyPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      ),
    );
  }
}
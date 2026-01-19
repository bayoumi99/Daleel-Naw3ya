import 'package:flutter/material.dart';
import 'dart:async';

class StudentQuizScreen extends StatefulWidget {
  final List<dynamic> quizData;
  final int durationMinutes;

  const StudentQuizScreen({
    super.key,
    required this.quizData,
    required this.durationMinutes
  });

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedOption;
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        _showResultDialog();
      }
    });
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedOption = selectedIndex;

      var currentQuestion = widget.quizData[_currentIndex];
      var correctIdxValue = currentQuestion['correctIndex'];

      int correctIdx = int.tryParse(correctIdxValue.toString()) ?? 0;

      if (selectedIndex == correctIdx) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.quizData.length - 1) {
      setState(() {
        _currentIndex++;
        _isAnswered = false;
        _selectedOption = null;
      });
    } else {
      _timer.cancel();
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("انتهى الاختبار", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 15),
            Text("درجتك المستحقة", style: TextStyle(color: Colors.grey.shade600)),
            Text("$_score من ${widget.quizData.length}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF292F91))),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF292F91),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () {
                // الحل النهائي لمشكلة الشاشة السوداء:
                // يرجع لأول صفحة (الرئيسية) ويمسح كل اللي فوقها
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("العودة للرئيسية", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // التأكد من إيقاف التايمر عند الخروج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizData.isEmpty) {
      return const Scaffold(body: Center(child: Text("لا توجد أسئلة حالياً")));
    }

    var currentQ = widget.quizData[_currentIndex];
    String timeStr = "${(_remainingSeconds ~/ 60)}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}";

    return PopScope(
      canPop: false, // يمنع الرجوع بزر الموبايل أثناء الاختبار
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FF),
        appBar: AppBar(
          title: Text("الوقت المتبقي: $timeStr"),
          centerTitle: true,
          backgroundColor: const Color(0xFF292F91),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // شريط التقدم
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.quizData.length,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "السؤال ${_currentIndex + 1} من ${widget.quizData.length}",
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(currentQ['question'] ?? "بدون عنوان",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF292F91))),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: (currentQ['options'] as List?)?.length ?? 0,
                    itemBuilder: (context, index) {
                      return _buildOptionBtn(index, currentQ);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                if (_isAnswered)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF292F91),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      onPressed: _nextQuestion,
                      child: Text(
                        _currentIndex == widget.quizData.length - 1 ? "عرض النتيجة النهائية" : "السؤال التالي",
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionBtn(int index, dynamic q) {
    int correctIdx = int.tryParse(q['correctIndex']?.toString() ?? "0") ?? 0;

    Color btnColor = Colors.white;
    Color textColor = Colors.black87;

    if (_isAnswered) {
      if (index == correctIdx) {
        btnColor = Colors.green.shade400; // الإجابة الصحيحة
        textColor = Colors.white;
      } else if (_selectedOption == index) {
        btnColor = Colors.red.shade400; // إجابة المستخدم الخاطئة
        textColor = Colors.white;
      }
    }

    return Card(
      elevation: _isAnswered ? 0 : 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
              color: _selectedOption == index ? const Color(0xFF292F91) : Colors.transparent,
              width: 2
          )
      ),
      child: ListTile(
        enabled: !_isAnswered, // يمنع تغيير الإجابة بعد الضغط
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          q['options'][index] ?? "",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor
          ),
        ),
        tileColor: btnColor,
        leading: CircleAvatar(
          backgroundColor: _isAnswered ? Colors.white24 : Colors.grey.shade100,
          child: Text("${index + 1}", style: TextStyle(color: textColor)),
        ),
        onTap: () => _checkAnswer(index),
      ),
    );
  }
}
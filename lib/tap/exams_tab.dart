import 'package:flutter/material.dart';
import 'dart:async';

class StudentQuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> quizData; // الأسئلة القادمة من الدكتور
  final int durationMinutes; // الوقت المحدد

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
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        _showResultDialog(); // إنهاء الاختبار عند انتهاء الوقت
      }
    });
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedOption = selectedIndex;
      bool isCorrect = selectedIndex == widget.quizData[_currentIndex]['correctIndex'];

      if (isCorrect) {
        _score++;
        _showFeedback("أحسنت، إجابتك صحيحة ✅", Colors.green);
      } else {
        _showFeedback("إجابتك غير صحيحة ❌", Colors.red);
      }
    });
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
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
        title: const Text("انتهى الاختبار", textAlign: TextAlign.center),
        content: Text("درجتك النهائية هي: $_score من ${widget.quizData.length}",
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الحوار
              Navigator.pop(context); // العودة للهوم
            },
            child: const Text("العودة للرئيسية"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentQ = widget.quizData[_currentIndex];
    String timeStr = "${(_remainingSeconds ~/ 60)}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: Text("الوقت المتبقي: $timeStr"),
        centerTitle: true,
        backgroundColor: const Color(0xFF292F91),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.quizData.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
            ),
            const SizedBox(height: 30),
            Text("سؤال ${(_currentIndex + 1)} من ${widget.quizData.length}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(currentQ['question'],
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF292F91))),
            const SizedBox(height: 30),
            ...List.generate(currentQ['options'].length, (index) => _buildOptionBtn(index, currentQ)),
            const Spacer(),
            if (_isAnswered)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF292F91)),
                  child: Text(_currentIndex == widget.quizData.length - 1 ? "عرض النتيجة" : "السؤال التالي",
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBtn(int index, Map<String, dynamic> q) {
    Color btnColor = Colors.white;
    if (_isAnswered) {
      if (index == q['correctIndex']) btnColor = Colors.green.shade400; // الإجابة الصح دائماً أخضر
      else if (_selectedOption == index) btnColor = Colors.red.shade400; // لو اختار غلط يظهر أحمر
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _checkAnswer(index),
        style: OutlinedButton.styleFrom(
          backgroundColor: btnColor,
          padding: const EdgeInsets.all(18),
          side: BorderSide(color: _isAnswered && _selectedOption == index ? Colors.transparent : Colors.blue.shade100),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          q['options'][index],
          style: TextStyle(
            fontSize: 18,
            color: _isAnswered && (index == q['correctIndex'] || _selectedOption == index) ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
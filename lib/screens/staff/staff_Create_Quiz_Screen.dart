import 'package:flutter/material.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});
  static const routeName = '/staffCreateQuizScreen';


  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  double _duration = 30; // الوقت الافتراضي 30 دقيقة
  List<Map<String, dynamic>> _questions = [];

  // دالة لإضافة سؤال جديد بناءً على النوع
  void _addQuestion(String type) {
    setState(() {
      if (type == 'mcq') {
        _questions.add({
          'type': 'mcq',
          'question': '',
          'options': ['', '', '', ''],
          'answer': 0
        });
      } else if (type == 'true_false') {
        _questions.add({
          'type': 'true_false',
          'question': '',
          'answer': true
        });
      } else {
        _questions.add({
          'type': 'essay',
          'question': '',
          'answer': ''
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("إنشاء اختبار جديد"),
        backgroundColor: const Color(0xFF292F91),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // جزء تحديد الوقت
            _buildTimePicker(),

            // قائمة الأسئلة
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _questions.length,
                itemBuilder: (context, index) => _buildQuestionCard(index),
              ),
            ),

            // أزرار إضافة الأسئلة
            _buildActionButtons(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_duration.toInt()} دقيقة", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const Text("وقت الاختبار", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _duration,
            min: 5,
            max: 60,
            divisions: 11,
            label: _duration.round().toString(),
            onChanged: (double value) => setState(() => _duration = value),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    var q = _questions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => setState(() => _questions.removeAt(index))),
                Text("سؤال رقم ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            TextFormField(
              textAlign: TextAlign.right,
              decoration: const InputDecoration(hintText: "اكتب نص السؤال هنا"),
              onChanged: (val) => q['question'] = val,
            ),
            if (q['type'] == 'mcq') ..._buildMCQFields(index),
            if (q['type'] == 'true_false') _buildTrueFalseFields(index),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMCQFields(int index) {
    return List.generate(4, (i) => TextFormField(
      textAlign: TextAlign.right,
      decoration: InputDecoration(hintText: "الخيار ${i + 1}"),
      onChanged: (val) => _questions[index]['options'][i] = val,
    ));
  }

  Widget _buildTrueFalseFields(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(label: const Text("خطأ"), selected: !_questions[index]['answer'], onSelected: (v) => setState(() => _questions[index]['answer'] = false)),
        const SizedBox(width: 20),
        ChoiceChip(label: const Text("صح"), selected: _questions[index]['answer'], onSelected: (v) => setState(() => _questions[index]['answer'] = true)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _addBtn("اختياري", Icons.list, 'mcq'),
          _addBtn("صح/خطأ", Icons.check_circle_outline, 'true_false'),
          _addBtn("مقالي", Icons.text_fields, 'essay'),
        ],
      ),
    );
  }

  Widget _addBtn(String label, IconData icon, String type) {
    return ElevatedButton.icon(
      onPressed: () => _addQuestion(type),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CA8DD), foregroundColor: Colors.white),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          // هنا يتم حفظ الاختبار والانتقال
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ الاختبار بنجاح")));
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF292F91),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("نشر الاختبار للطلاب", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
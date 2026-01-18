import 'package:flutter/material.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});
  static const routeName = '/staffCreateQuizScreen';

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();

  // إعدادات الاختبار
  double _duration = 30;
  String? _selectedDepartment = "تكنولوجيا التعليم";
  String? _selectedLevel = "السنة الأولى";
  String? _selectedSpecialization = "عام";

  final List<String> _departments = ["تكنولوجيا التعليم", "حاسب آلي", "إعلام تربوي"];
  final List<String> _levels = ["السنة الأولى", "السنة الثانية", "السنة الثالثة", "السنة الرابعة"];
  final List<String> _specializations = ["إعداد معلم", "تكنولوجيا تعليم"];

  // قائمة الأسئلة
  List<Map<String, dynamic>> _questions = [];

  void _addQuestion(String type) {
    setState(() {
      if (type == 'mcq') {
        _questions.add({
          'type': 'mcq',
          'question': '',
          'options': ['', '', '', ''],
          'answer': 0 // مؤشر الإجابة الصحيحة (0-3)
        });
      } else if (type == 'true_false') {
        _questions.add({
          'type': 'true_false',
          'question': '',
          'answer': true // الإجابة الصحيحة (true/false)
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        title: const Text("إنشاء اختبار جديد", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF292F91),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // قسم اختيار الفئة المستهدفة والوقت
            _buildHeaderSettings(),

            // قائمة الأسئلة
            Expanded(
              child: _questions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _questions.length,
                itemBuilder: (context, index) => _buildQuestionCard(index),
              ),
            ),

            // أزرار إضافة سؤال جديد
            _buildActionButtons(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildHeaderSettings() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(labelText: "الدفعة", border: OutlineInputBorder()),
                  items: _levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setState(() {
                    _selectedLevel = val;
                    if (val != "السنة الثالثة" && val != "السنة الرابعة") _selectedSpecialization = "عام";
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: const InputDecoration(labelText: "القسم", border: OutlineInputBorder()),
                  items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => setState(() => _selectedDepartment = val),
                ),
              ),
            ],
          ),
          if (_selectedLevel == "السنة الثالثة" || _selectedLevel == "السنة الرابعة")
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: DropdownButtonFormField<String>(
                value: _selectedSpecialization == "عام" ? _specializations[0] : _selectedSpecialization,
                decoration: const InputDecoration(labelText: "التخصص", border: OutlineInputBorder(), prefixIcon: Icon(Icons.school)),
                items: _specializations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedSpecialization = val),
              ),
            ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_duration.toInt()} دقيقة", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const Text("مدة الاختبار", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _duration,
            min: 5,
            max: 120,
            divisions: 23,
            onChanged: (val) => setState(() => _duration = val),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    var q = _questions[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.red), onPressed: () => setState(() => _questions.removeAt(index))),
                Text("سؤال ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            TextFormField(
              textAlign: TextAlign.right,
              decoration: const InputDecoration(hintText: "اكتب نص السؤال هنا..."),
              onChanged: (val) => q['question'] = val,
            ),
            const SizedBox(height: 15),
            if (q['type'] == 'mcq') ..._buildMCQOptions(index),
            if (q['type'] == 'true_false') _buildTrueFalseOptions(index),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMCQOptions(int index) {
    return [
      const Text("اختر الإجابة الصحيحة:", style: TextStyle(fontSize: 12, color: Colors.grey)),
      ...List.generate(4, (i) => Row(
        children: [
          Radio<int>(
            value: i,
            groupValue: _questions[index]['answer'],
            onChanged: (val) => setState(() => _questions[index]['answer'] = val),
          ),
          Expanded(
            child: TextFormField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(hintText: "الخيار ${i + 1}"),
              onChanged: (val) => _questions[index]['options'][i] = val,
            ),
          ),
        ],
      ))
    ];
  }

  Widget _buildTrueFalseOptions(int index) {
    bool correct = _questions[index]['answer'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text("خطأ"),
          selected: !correct,
          onSelected: (v) => setState(() => _questions[index]['answer'] = false),
          selectedColor: Colors.red.shade100,
        ),
        const SizedBox(width: 20),
        ChoiceChip(
          label: const Text("صح"),
          selected: correct,
          onSelected: (v) => setState(() => _questions[index]['answer'] = true),
          selectedColor: Colors.green.shade100,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text("لم يتم إضافة أسئلة بعد", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _addBtn("اختياري", Icons.format_list_bulleted, 'mcq'),
          _addBtn("صح / خطأ", Icons.check_circle_outline, 'true_false'),
        ],
      ),
    );
  }

  Widget _addBtn(String label, IconData icon, String type) {
    return ElevatedButton.icon(
      onPressed: () => _addQuestion(type),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CA8DD),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          // هنا يتم الربط مع Firebase
          String msg = "تم نشر الاختبار لـ $_selectedLevel";
          if (_selectedSpecialization != "عام") msg += " ($_selectedSpecialization)";
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF292F91),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("نشر الاختبار للطلاب", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
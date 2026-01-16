import 'package:daleel_naw3ya/screens/staff/staff_home_screen.dart';
import 'package:flutter/material.dart';

import '../core/student_manager.dart';

class DynamicSignupScreen extends StatefulWidget {
  const DynamicSignupScreen({super.key});
  static const String routeName = "DynamicSignupScreen";

  @override
  State<DynamicSignupScreen> createState() => _DynamicSignupScreenState();
}

class _DynamicSignupScreenState extends State<DynamicSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  final Color primaryColor = const Color(0xFF292F91);
  final Color accentColor = const Color(0xFF4CA8DD);

  String? _selectedRole;
  String? _selectedYear;
  String? _selectedDept;
  String? _selectedSubDept;

  final Map<String, String> _deptNames = {
    'edu': 'تكنولوجيا التعليم',
    'media': 'إعلام تربوي',
    'music': 'تربية موسيقية',
    'home': 'اقتصاد منزلي',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Column(
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'lib/assets/images/logo1.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.school, size: 100, color: Colors.white),
                ),
              ),
              const Text(
                "دليل نوعية",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 15,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_selectedRole == null) ...[
                            const Text("اختر فئة المستخدم",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            _buildLargeRoleBtn('student', 'تسجيل كطالب بالكلية', Icons.school),
                            const SizedBox(height: 15),
                            _buildLargeRoleBtn('staff', 'عضو هيئة تدريس', Icons.person_search),
                          ] else ...[
                            _buildHeaderWithReset(),
                            const Divider(),
                            const SizedBox(height: 10),

                            _buildField("الاسم الكامل", Icons.person_outline, _nameController),
                            const SizedBox(height: 15),

                            _buildField(
                                _selectedRole == 'student' ? "كود الطالب الموحد" : "الكود الوظيفي",
                                Icons.vpn_key_outlined,
                                _codeController,
                                isNumber: true),
                            const SizedBox(height: 15),

                            _buildDropdown("القسم العلمي", Icons.account_tree_outlined, _selectedDept, _deptNames, (v) {
                              setState(() {
                                _selectedDept = v;
                                _selectedSubDept = null;
                              });
                            }),

                            if (_selectedRole == 'student') ...[
                              const SizedBox(height: 15),
                              _buildDropdown("الفرقة الدراسية", Icons.calendar_month_outlined, _selectedYear,
                                  {'1': 'الأولى', '2': 'الثانية', '3': 'الثالثة', '4': 'الرابعة'}, (v) {
                                    setState(() {
                                      _selectedYear = v;
                                      _selectedSubDept = null;
                                    });
                                  }),
                              if ((_selectedYear == '3' || _selectedYear == '4') && _selectedDept != null) ...[
                                const SizedBox(height: 15),
                                _buildDropdown("التخصص (الشعبة)", Icons.workspace_premium_outlined,
                                    _selectedSubDept, _getSubDepts(), (v) => setState(() => _selectedSubDept = v)),
                              ],
                            ],

                            const SizedBox(height: 25),
                            _buildSubmitBtn(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _getSubDepts() {
    if (_selectedDept == 'edu') return {'cs': 'معلم حاسب آلي', 'it': 'تكنولوجيا تعليم'};
    if (_selectedDept == 'media') return {'press': 'صحافة', 'radio': 'إذاعة وتلفزيون'};
    return {'gen': 'عام'};
  }

  Widget _buildLargeRoleBtn(String role, String label, IconData icon) {
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 30),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      textAlign: TextAlign.right,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (val) => val!.isEmpty ? "هذا الحقل مطلوب" : null,
    );
  }

  Widget _buildDropdown(String label, IconData icon, String? val, Map<String, String> items, Function(String?) onChg) {
    return DropdownButtonFormField<String>(
      value: val,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
      onChanged: onChg,
      validator: (val) => val == null ? "مطلوب" : null,
    );
  }

  Widget _buildSubmitBtn() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), gradient: LinearGradient(colors: [primaryColor, accentColor])),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (_selectedRole == 'student') {
              // منطق الطالب وحفظ بياناته
              String finalSpecialty = _selectedSubDept != null ? (_getSubDepts()[_selectedSubDept] ?? _selectedSubDept!) : "عام";

              StudentManager().updateData(
                n: _nameController.text,
                c: _codeController.text,
                d: _deptNames[_selectedDept!] ?? "",
                l: "الفرقة " + (_selectedYear == '1' ? 'الأولى' : _selectedYear == '2' ? 'الثانية' : _selectedYear == '3' ? 'الثالثة' : 'الرابعة'),
                li: int.parse(_selectedYear!),
                s: finalSpecialty,
              );

              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            } else {
              // الانتقال لصفحة الدكتور وتمرير البيانات المكتوبة في الـ Signup
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => StaffHomeScreen(
                    doctorName: _nameController.text,
                    department: _deptNames[_selectedDept!] ?? "غير محدد",
                  ),
                ),
                    (route) => false,
              );
            }
          }
        },
        child: const Text("إنشاء الحساب",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildHeaderWithReset() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () => setState(() {
              _selectedRole = null;
              _selectedDept = null;
              _selectedYear = null;
              _selectedSubDept = null;
            }),
            icon: const Icon(Icons.arrow_back, color: Colors.red)),
        Text(_selectedRole == 'student' ? "حساب طالب جديد" : "حساب عضو هيئة تدريس",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daleel_naw3ya/screens/staff/staff_home_screen.dart';
import 'package:daleel_naw3ya/screens/student_home_screen.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF292F91);

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

  // دالة التخصصات (تأكد أنها داخل الكلاس)
  Map<String, String> _getSubDepts() {
    if (_selectedDept == 'edu') return {'cs': 'معلم حاسب آلي', 'it': 'تكنولوجيا تعليم'};
    if (_selectedDept == 'media') return {'press': 'صحافة', 'radio': 'إذاعة وتلفزيون'};
    return {'gen': 'عام'};
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'student' &&
        (_selectedYear == 'السنة الثالثة' || _selectedYear == 'السنة الرابعة') &&
        _selectedSubDept == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("برجاء اختيار التخصص الفرعي")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String finalSpecialty = "عام";
      if (_selectedRole == 'student') {
        if (_selectedSubDept != null) {
          finalSpecialty = _getSubDepts()[_selectedSubDept] ?? "عام";
        }
      } else {
        finalSpecialty = "N/A";
      }

      // حفظ البيانات في قاعدة البيانات (default)
      await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'email': _emailController.text.trim(),
        'department': _deptNames[_selectedDept!] ?? "",
        'role': _selectedRole,
        'year': _selectedYear ?? "N/A",
        'specialty': finalSpecialty,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        if (_selectedRole == 'student') {
          // حل مشكلة Invalid constant value بحذف كلمة const
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StudentHomeScreen(
                isDarkMode: false,
                onThemeChanged: (bool p1) { },
              ),
            ),
                (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => StaffHomeScreen(
                doctorName: _nameController.text.trim(),
                department: _deptNames[_selectedDept!] ?? '',
              ),
            ),
                (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "خطأ في التسجيل")));
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تأكد من إعدادات قاعدة البيانات")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Column(
            children: [
              const Text("دليل نوعية", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Card(
                elevation: 15,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_selectedRole == null) ...[
                          _buildLargeRoleBtn('student', 'تسجيل كطالب بالكلية', Icons.school),
                          const SizedBox(height: 15),
                          _buildLargeRoleBtn('staff', 'عضو هيئة تدريس', Icons.person_search),
                        ] else ...[
                          _buildHeaderWithReset(),
                          _buildField("الاسم الكامل", Icons.person_outline, _nameController),
                          const SizedBox(height: 10),
                          _buildField("البريد الإلكتروني", Icons.email_outlined, _emailController),
                          const SizedBox(height: 10),
                          _buildField("كلمة المرور", Icons.lock_outline, _passwordController, isPassword: true),
                          const SizedBox(height: 10),
                          _buildField(_selectedRole == 'student' ? "كود الطالب" : "الكود الوظيفي", Icons.vpn_key_outlined, _codeController, isNumber: true),
                          const SizedBox(height: 10),
                          _buildDropdown("القسم", Icons.account_tree_outlined, _selectedDept, _deptNames, (v) => setState(() => _selectedDept = v)),

                          if (_selectedRole == 'student') ...[
                            const SizedBox(height: 10),
                            _buildDropdown(
                                "الفرقة الدراسية",
                                Icons.layers_outlined,
                                _selectedYear,
                                {
                                  'السنة الأولى': 'السنة الأولى',
                                  'السنة الثانية': 'السنة الثانية',
                                  'السنة الثالثة': 'السنة الثالثة',
                                  'السنة الرابعة': 'السنة الرابعة',
                                },
                                    (v) => setState(() {
                                  _selectedYear = v;
                                  if (v == 'السنة الأولى' || v == 'السنة الثانية') _selectedSubDept = null;
                                })
                            ),

                            if (_selectedYear == 'السنة الثالثة' || _selectedYear == 'السنة الرابعة') ...[
                              const SizedBox(height: 10),
                              _buildDropdown("التخصص الفرعي", Icons.star_border, _selectedSubDept, _getSubDepts(), (v) => setState(() => _selectedSubDept = v)),
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
            ],
          ),
        ),
      ),
    );
  }

  // الدوال المساعدة (تأكد أنها داخل قوس الـ State)
  Widget _buildLargeRoleBtn(String role, String label, IconData icon) {
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [Icon(icon, color: primaryColor), const SizedBox(width: 15), Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.arrow_forward_ios, size: 14)]),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, {bool isNumber = false, bool isPassword = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword,
      textAlign: TextAlign.right,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: primaryColor), filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
      validator: (val) => val!.isEmpty ? "مطلوب" : null,
    );
  }

  Widget _buildDropdown(String label, IconData icon, String? val, Map<String, String> items, Function(String?) onChg) {
    return DropdownButtonFormField<String>(
      value: val,
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
      onChanged: onChg,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: primaryColor), filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
      validator: (val) => val == null ? "مطلوب" : null,
    );
  }

  Widget _buildHeaderWithReset() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(onPressed: () => setState(() => _selectedRole = null), icon: const Icon(Icons.arrow_back, color: Colors.red)),
      Text(_selectedRole == 'student' ? "حساب طالب" : "حساب دكتور", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildSubmitBtn() {
    return ElevatedButton(
      onPressed: _handleSignup,
      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: const Text("إنشاء الحساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
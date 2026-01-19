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

  // المتحكمات في النصوص
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true; // التحكم في وضع الدخول أو الإنشاء

  String? _selectedRole;
  String? _selectedYear;
  String? _selectedDept;
  String? _selectedSubDept;

  final Color primaryColor = const Color(0xFF292F91);

  final Map<String, String> _deptNames = {
    'edu': 'تكنولوجيا التعليم',
    'media': 'إعلام تربوي',
    'music': 'تربية موسيقية',
    'home': 'اقتصاد منزلي',
  };

  Map<String, String> _getSubDepts() {
    if (_selectedDept == 'edu') return {'cs': 'معلم حاسب آلي', 'it': 'تكنولوجيا تعليم'};
    if (_selectedDept == 'media') return {'press': 'صحافة', 'radio': 'إذاعة وتلفزيون'};
    return {'gen': 'عام'};
  }

  // الدالة الرئيسية (تسجيل دخول أو إنشاء حساب)
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من اختيار القسم عند إنشاء حساب
    if (!_isLoginMode && _selectedDept == null) {
      _showErrorSnackBar("يرجى اختيار القسم");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLoginMode) {
        // ------------------ وضع تسجيل الدخول ------------------
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // جلب البيانات من Firestore للتأكد من نوع المستخدم
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          _navigateToHome(
              userDoc['role'] ?? 'student',
              userDoc['name'] ?? 'مستخدم',
              userDoc['department'] ?? ""
          );
        } else {
          // إذا كان الحساب موجود في Auth ولكن بياناته غير موجودة في Firestore
          throw "بياناتك غير مسجلة في قاعدة البيانات. يرجى إنشاء حساب جديد.";
        }
      } else {
        // ------------------ وضع إنشاء حساب جديد ------------------
        if (_selectedRole == 'student' &&
            (_selectedYear == 'السنة الثالثة' || _selectedYear == 'السنة الرابعة') &&
            _selectedSubDept == null) {
          throw "يرجى اختيار التخصص الفرعي";
        }

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String finalSpecialty = "عام";
        if (_selectedRole == 'student' && _selectedSubDept != null) {
          finalSpecialty = _getSubDepts()[_selectedSubDept] ?? "عام";
        }

        // حفظ البيانات في Firestore
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

        _navigateToHome(_selectedRole!, _nameController.text.trim(), _deptNames[_selectedDept!] ?? "");
      }
    } on FirebaseAuthException catch (e) {
      // التعامل مع أخطاء Firebase الشهيرة
      String msg = "خطأ في الجلسة";
      if (e.code == 'user-not-found') msg = "هذا الحساب غير موجود";
      else if (e.code == 'wrong-password') msg = "كلمة المرور غير صحيحة";
      else if (e.code == 'invalid-email') msg = "صيغة البريد الإلكتروني غير صحيحة";
      else if (e.code == 'network-request-failed') msg = "لا يوجد اتصال بالإنترنت";
      else if (e.code == 'email-already-in-use') msg = "هذا البريد مسجل بالفعل";
      _showErrorSnackBar(msg);
    } catch (e) {
      // التعامل مع أي خطأ آخر (مثل أخطاء Firestore)
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.right), backgroundColor: Colors.red),
    );
  }

  void _navigateToHome(String role, String name, String dept) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => role == 'student'
            ? StudentHomeScreen(isDarkMode: false, onThemeChanged: (v) {})
            : StaffHomeScreen(doctorName: name, department: dept, isDarkMode: false, onThemeChanged: (v) {}),
      ),
          (route) => false,
    );
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
              const Text("دليل نوعية",
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
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
                          _buildLargeRoleBtn('student', 'دخول كطالب', Icons.school),
                          const SizedBox(height: 15),
                          _buildLargeRoleBtn('staff', 'دخول كدكتور', Icons.person_search),
                        ] else ...[
                          _buildHeaderWithReset(),
                          const SizedBox(height: 20),

                          if (!_isLoginMode) ...[
                            _buildField("الاسم الكامل", Icons.person_outline, _nameController),
                            const SizedBox(height: 10),
                          ],

                          _buildField("البريد الإلكتروني", Icons.email_outlined, _emailController),
                          const SizedBox(height: 10),
                          _buildField("كلمة المرور", Icons.lock_outline, _passwordController, isPassword: true),

                          if (!_isLoginMode) ...[
                            const SizedBox(height: 10),
                            _buildField(_selectedRole == 'student' ? "كود الطالب" : "الكود الوظيفي", Icons.vpn_key_outlined, _codeController, isNumber: true),
                            const SizedBox(height: 10),
                            _buildDropdown("القسم", Icons.account_tree_outlined, _selectedDept, _deptNames, (v) => setState(() => _selectedDept = v)),

                            if (_selectedRole == 'student') ...[
                              const SizedBox(height: 10),
                              _buildDropdown("الفرقة الدراسية", Icons.layers_outlined, _selectedYear,
                                  {'السنة الأولى': 'السنة الأولى', 'السنة الثانية': 'السنة الثانية', 'السنة الثالثة': 'السنة الثالثة', 'السنة الرابعة': 'السنة الرابعة'},
                                      (v) => setState(() { _selectedYear = v; if (v == 'السنة الأولى' || v == 'السنة الثانية') _selectedSubDept = null; })
                              ),
                              if (_selectedYear == 'السنة الثالثة' || _selectedYear == 'السنة الرابعة') ...[
                                const SizedBox(height: 10),
                                _buildDropdown("التخصص الفرعي", Icons.star_border, _selectedSubDept, _getSubDepts(), (v) => setState(() => _selectedSubDept = v)),
                              ],
                            ],
                          ],

                          const SizedBox(height: 20),

                          // زر التبديل بين الدخول والإنشاء
                          GestureDetector(
                            onTap: () => setState(() => _isLoginMode = !_isLoginMode),
                            child: Text(
                              _isLoginMode ? "إنشاء حساب جديد؟" : "لديك حساب بالفعل؟ سجل دخول",
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),

                          const SizedBox(height: 20),
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

  // --- دوال بناء الواجهة ---

  Widget _buildLargeRoleBtn(String role, String label, IconData icon) {
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Icon(icon, color: primaryColor, size: 30),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 14)
        ]),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, {bool isNumber = false, bool isPassword = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword,
      textAlign: TextAlign.right,
      keyboardType: isNumber ? TextInputType.number : (label.contains("البريد") ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "هذا الحقل مطلوب";
        if (isPassword && val.length < 6) return "كلمة المرور ضعيفة";
        return null;
      },
    );
  }

  Widget _buildDropdown(String label, IconData icon, String? val, Map<String, String> items, Function(String?) onChg) {
    return DropdownButtonFormField<String>(
      value: val,
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
      onChanged: onChg,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
      validator: (val) => val == null ? "مطلوب" : null,
    );
  }

  Widget _buildHeaderWithReset() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(onPressed: () => setState(() { _selectedRole = null; _isLoginMode = true; }), icon: const Icon(Icons.arrow_back, color: Colors.red)),
      Text(
        _isLoginMode
            ? (_selectedRole == 'student' ? "دخول طالب" : "دخول دكتور")
            : "إنشاء حساب جديد",
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ]);
  }

  Widget _buildSubmitBtn() {
    return ElevatedButton(
      onPressed: _handleSubmit,
      style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
      ),
      child: Text(
        _isLoginMode ? "تسجيل الدخول" : "تأكيد وإنشاء الحساب",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
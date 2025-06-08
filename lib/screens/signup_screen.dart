import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? selectedGender;

  void _handleGoToOtp() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final gender = selectedGender;

    // ✅ تحقق من الحقول
    if (name.isEmpty || phone.isEmpty || gender == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء جميع الحقول")),
      );
      return;
    }

    // ✅ تحقق من الرقم: لازم يكون 10 أرقام ويبدأ بـ 7 (بعد إزالة 0 أو +964)
    final normalized = _normalizePhone(phone);
    final pureNumber = normalized.replaceAll('+964', '');

    if (pureNumber.length != 10 || !pureNumber.startsWith('7')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إدخال رقم هاتف صحيح يبدأ بـ 7 ويتكون من 10 أرقام")),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/otp-register',
      arguments: {
        'name': name,
        'phone': normalized,
        'gender': gender,
      },
    );
  }

  String _normalizePhone(String input) {
    String phone = input.trim();

    if (phone.startsWith('+964')) return phone;
    if (phone.startsWith('0')) phone = phone.substring(1);
    return '+964$phone';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'loom',
                  style: TextStyle(
                    color: Color(0xFF546E7A),
                    fontSize: 40,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'خطوة وحدة... وتبدي رحلة أناقتك',
                  style: TextStyle(
                    color: Color(0xFF78909C),
                    fontSize: 20,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 40),
                _buildInputField(_nameController, 'أدخل اسمك الكامل'),
                const SizedBox(height: 20),
                _buildPhoneField(),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    ' : الجنس',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF999999),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                GenderSelector(
                  gender: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _handleGoToOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF546E7A),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Tajawal',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'بالتسجيل أنت توافق على شروط الاستخدام وسياسة الخصوصية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
                      children: [
                        TextSpan(
                          text: 'لديك حساب؟ ',
                          style: TextStyle(color: Color(0xFF757575)),
                        ),
                        TextSpan(
                          text: 'سجل دخول',
                          style: TextStyle(color: Color(0xFF546E7A)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDDDDD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Color(0xFF999999),
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDDDDD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const Text(
            '🇮🇶 +964',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '07XXXXXXXXX',
                hintStyle: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GenderSelector extends StatelessWidget {
  final String? gender;
  final void Function(String?) onChanged;

  const GenderSelector({
    super.key,
    required this.gender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Radio<String>(
              value: 'male',
              groupValue: gender,
              onChanged: onChanged,
            ),
            const Text('ذكر'),
          ],
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Radio<String>(
              value: 'female',
              groupValue: gender,
              onChanged: onChanged,
            ),
            const Text('أنثى'),
          ],
        ),
      ],
    );
  }
}

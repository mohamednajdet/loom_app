import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    if (name.isEmpty || phone.isEmpty || gender == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("يرجى ملء جميع الحقول")));
      return;
    }

    final normalized = _normalizePhone(phone);
    final pureNumber = normalized.replaceAll('+964', '');

    if (pureNumber.length != 10 || !pureNumber.startsWith('7')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "يرجى إدخال رقم هاتف صحيح يبدأ بـ 7 ويتكون من 10 أرقام",
          ),
        ),
      );
      return;
    }

    context.push(
      '/otp-register',
      extra: {'name': name, 'phone': normalized, 'gender': gender},
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = const Color(0xFF546E7A);
    final cardColor = theme.cardColor;
    final shadowColor =
        isDark
            ? Colors.black.withValues(alpha: 0.13 * 255)
            : const Color(0x19000000);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'loom',
                  style: TextStyle(
                    color: primary,
                    fontSize: 40,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'خطوة وحدة... وتبدي رحلة أناقتك',
                  style: TextStyle(
                    color: const Color(0xFF78909C),
                    fontSize: 20,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 40),
                _buildInputField(
                  _nameController,
                  'أدخل اسمك الكامل',
                  theme,
                  cardColor,
                  shadowColor,
                ),
                const SizedBox(height: 20),
                _buildPhoneField(theme, cardColor, shadowColor),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    ' : الجنس',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: theme.hintColor,
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
                  textColor: theme.textTheme.bodyLarge?.color,
                  activeColor: primary,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _handleGoToOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
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
                Text(
                  'بالتسجيل أنت توافق على شروط الاستخدام وسياسة الخصوصية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.hintColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Tajawal',
                      ),
                      children: [
                        TextSpan(
                          text: 'لديك حساب؟ ',
                          style: TextStyle(color: theme.hintColor),
                        ),
                        TextSpan(
                          text: 'سجل دخول',
                          style: TextStyle(color: primary),
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

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    ThemeData theme,
    Color cardColor,
    Color shadowColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'Cairo'),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 16,
            color: theme.hintColor,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(ThemeData theme, Color cardColor, Color shadowColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '🇮🇶 +964',
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'Poppins'),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '07XXXXXXXXX',
                hintStyle: TextStyle(
                  color: theme.hintColor,
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
  final Color? textColor;
  final Color? activeColor;

  const GenderSelector({
    super.key,
    required this.gender,
    required this.onChanged,
    this.textColor,
    this.activeColor,
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
              activeColor: activeColor,
            ),
            Text(
              'ذكر',
              style: TextStyle(color: textColor, fontFamily: 'Cairo'),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Radio<String>(
              value: 'female',
              groupValue: gender,
              onChanged: onChanged,
              activeColor: activeColor,
            ),
            Text(
              'أنثى',
              style: TextStyle(color: textColor, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ],
    );
  }
}

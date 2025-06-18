import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../services/api_service_dio.dart';
import '../widgets/back_button_custom.dart';
import 'otp_login_screen.dart';
import 'package:go_router/go_router.dart';

class ChangePhoneNumberScreen extends StatefulWidget {
  const ChangePhoneNumberScreen({super.key});

  @override
  State<ChangePhoneNumberScreen> createState() => _ChangePhoneNumberScreenState();
}

class _ChangePhoneNumberScreenState extends State<ChangePhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final Logger logger = Logger();
  int phoneLength = 0;

  void _submitPhoneNumber() async {
    final newPhone = _phoneController.text.trim();

    if (newPhone.length != 11 || !newPhone.startsWith('07')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم هاتف صالح يبدأ بـ 07')),
      );
      return;
    }

    try {
      logger.i('📤 إرسال رمز التحقق إلى $newPhone');
      await ApiServiceDio.sendOtp(newPhone);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpLoginScreen(
            phoneNumber: newPhone,
            isChangePhone: true,
          ),
        ),
      );
    } catch (e) {
      logger.e('❌ فشل إرسال OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إرسال رمز التحقق: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        phoneLength = _phoneController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final hintColor = isDark ? Colors.grey[600] : Colors.grey[400];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 8),
              const BackButtonCustom(title: 'تغيير الهاتف'),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'loom',
                  style: TextStyle(
                    fontSize: 70,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Poppins',
                    color: Color(0xFF546E7A),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Text(
                'ادخل رقم هاتفك الجديد',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Cairo',
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: 'رقم الهاتف',
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontFamily: 'Cairo',
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : const Color(0xFFDDDDDD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : const Color(0xFFDDDDDD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$phoneLength/11',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    color: hintColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF29434E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'الغاء',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitPhoneNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF546E7A), // لون الشعار الأساسي
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'التالي',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

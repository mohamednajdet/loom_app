import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service_dio.dart';
import '../widgets/back_button_custom.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 2,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    dateTimeFormat: (now) => DateFormat.Hms().format(now),
  ),
);

class OtpLoginScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isChangePhone;

  const OtpLoginScreen({
    super.key,
    required this.phoneNumber,
    this.isChangePhone = false,
  });

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  int seconds = 60;
  bool canResend = false;
  bool isVerifying = false;
  Timer? countdownTimer;
  TextEditingController otpController = TextEditingController();

  late final String formattedPhone;

  @override
  void initState() {
    super.initState();
    formattedPhone = _normalizePhone(widget.phoneNumber);
    _startTimer();
    _sendOtp();
  }

  String _normalizePhone(String raw) {
    String phone = raw.trim();
    if (phone.startsWith('+964')) return phone;
    if (phone.startsWith('0')) phone = phone.substring(1);
    return '+964$phone';
  }

  Future<void> _sendOtp() async {
    try {
      final response = await ApiServiceDio.sendOtp(formattedPhone);
      if (response['message'] == 'تم إرسال رمز التحقق بنجاح') {
        logger.i('OTP sent to $formattedPhone');
      } else {
        logger.w('خطأ أثناء الإرسال: ${response['message']}');
      }
    } catch (e) {
      logger.e("فشل في إرسال OTP: $e");
    }
  }

  void _startTimer() {
    setState(() {
      seconds = 60;
      canResend = false;
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
        setState(() => canResend = true);
      } else {
        setState(() => seconds--);
      }
    });
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = otpController.text.trim();

    if (enteredOtp.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الرجاء إدخال رمز مكون من 6 أرقام")),
        );
      }
      return;
    }

    setState(() => isVerifying = true);

    try {
      if (widget.isChangePhone) {
        await ApiServiceDio.verifyOtpChangePhone(
          phone: formattedPhone,
          code: enteredOtp,
        );
        await ApiServiceDio.updatePhone(formattedPhone);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userPhone', formattedPhone);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم تغيير رقم الهاتف بنجاح")),
          );
          context.go('/profile');
        }
      } else {
        final result = await ApiServiceDio.verifyOtp(
          phone: formattedPhone,
          code: enteredOtp,
        );

        final token = result['token'];
        if (token == null || token is! String) {
          throw Exception('فشل في استلام التوكن من السيرفر');
        }

        final user = result['user'];
        if (user == null || user is! Map<String, dynamic>) {
          throw Exception('بيانات المستخدم غير صالحة');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', user['_id']);
        await prefs.setString('userName', user['name']);
        await prefs.setString('userPhone', user['phone']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم التحقق من الرقم بنجاح")),
          );
          context.go('/');
        }
      }
    } catch (e) {
      logger.e('خطأ في التحقق: $e');
      if (!mounted) return;

      final errorMessage = e.toString();
      String displayMessage = 'فشل التحقق من الرمز';

      if (errorMessage.contains('رمز التحقق غير صحيح')) {
        displayMessage = 'رمز التحقق غير صحيح';
      } else if (errorMessage.contains('انتهت صلاحية الرمز')) {
        displayMessage = 'انتهت صلاحية الرمز أو غير موجود';
      } else if (errorMessage.contains('الحساب غير موجود')) {
        displayMessage = 'الحساب غير موجود، يرجى التسجيل أولاً';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(displayMessage)));
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF546E7A);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const BackButtonCustom(),
              const SizedBox(height: 16),
              Text(
                'loom',
                style: TextStyle(
                  fontSize: 80,
                  fontStyle: FontStyle.italic,
                  color: primaryColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 80),
              Text(
                'أدخل رمز التحقق المرسل إلى رقم هاتفك',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                formattedPhone,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 24),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: otpController,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                enabled: !isVerifying,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  inactiveColor:
                      isDark ? Colors.grey[700]! : Colors.grey.shade300,
                  activeColor: primaryColor,
                  selectedColor: primaryColor,
                  activeFillColor: cardColor,
                  inactiveFillColor: cardColor,
                  selectedFillColor: cardColor,
                ),
                onChanged: (_) {},
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
              ),
              const SizedBox(height: 16),
              canResend
                  ? TextButton(
                    onPressed: () {
                      _sendOtp();
                      _startTimer();
                    },
                    child: const Text(
                      'إعادة إرسال الرمز',
                      style: TextStyle(color: Colors.blue),
                    ),
                  )
                  : Text(
                    'إعادة إرسال الرمز خلال $seconds ثانية',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    isVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'تأكيد',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

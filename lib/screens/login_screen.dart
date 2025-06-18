import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service_dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      if (!mounted) return;
      context.go('/');
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    String phone = _phoneController.text.trim();

    if (phone.startsWith('0')) phone = phone.substring(1);
    if (!phone.startsWith('+964')) phone = '+964$phone';

    try {
      final exists = await ApiServiceDio.checkPhoneExists(phone);
      if (!exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرقم غير مسجل، يرجى إنشاء حساب')),
        );
        return;
      }

      await ApiServiceDio.sendOtp(phone);

      if (!mounted) return;
      context.push('/otp-login', extra: phone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color primary = Color(0xFF546E7A);
    final Color cardColor = theme.cardColor;
    final Color scaffoldBg = theme.scaffoldBackgroundColor;
    final Color borderColor =
        isDark ? Colors.grey[800]! : const Color(0xFFDDDDDD);
    final Color shadowColor =
        isDark
            ? Colors.black.withAlpha((0.18 * 255).toInt())
            : const Color(0x3F000000);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'En',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Cairo',
                      color: const Color(0xFF757575),
                    ),
                  ),
                  Text(
                    'Ar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Cairo',
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'loom',
                    style: TextStyle(
                      fontSize: 40,
                      color: primary,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'مَلبوس الهّنا من لووم',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Tajawal',
                      color:
                          isDark ? Colors.grey[400] : const Color(0xFF78909C),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
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
                            color: isDark ? Colors.white : Colors.black,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontFamily: 'Poppins',
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '7XXXXXXXXXX',
                              hintStyle: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[600]
                                        : const Color(0xFF999999),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _isLoading ? null : _handleLogin,
                    child: Container(
                      width: 300,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Cairo',
                        ),
                        children: [
                          TextSpan(
                            text: 'مستخدم جديد؟ ',
                            style: TextStyle(
                              color:
                                  isDark
                                      ? Colors.grey[400]
                                      : const Color(0xFF757575),
                            ),
                          ),
                          const TextSpan(
                            text: 'أنشئ حسابك',
                            style: TextStyle(color: primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

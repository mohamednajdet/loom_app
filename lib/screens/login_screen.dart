import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      Navigator.pushReplacementNamed(context, '/home');
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
      Navigator.pushNamed(context, '/otp-login', arguments: phone);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('En', style: TextStyle(fontSize: 14, fontFamily: 'Cairo', color: Color(0xFF757575))),
                  Text('Ar', style: TextStyle(fontSize: 14, fontFamily: 'Cairo', color: Color(0xFF757575))),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text('loom', style: TextStyle(fontSize: 40, color: Color(0xFF546E7A), fontStyle: FontStyle.italic, fontFamily: 'Poppins')),
                  const SizedBox(height: 8),
                  const Text('مَلبوس الهّنا من لووم', style: TextStyle(fontSize: 20, fontFamily: 'Tajawal', color: Color(0xFF78909C))),
                  const SizedBox(height: 60),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                      boxShadow: const [BoxShadow(color: Color(0x3F000000), blurRadius: 4, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        const Text('🇮🇶 +964', style: TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Tajawal')),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '7XXXXXXXXXX',
                              hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14, fontFamily: 'Poppins'),
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
                        color: const Color(0xFF546E7A),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Tajawal')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                        children: [
                          TextSpan(text: 'مستخدم جديد؟ ', style: TextStyle(color: Color(0xFF757575))),
                          TextSpan(text: 'أنشئ حسابك', style: TextStyle(color: Color(0xFF546E7A))),
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

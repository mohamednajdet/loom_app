import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _displayed = "";
  final String _fullText = "loom";
  int _charIndex = 0;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    _navigateAfterDelay();
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_charIndex < _fullText.length) {
        setState(() {
          _displayed += _fullText[_charIndex];
          _charIndex++;
        });
      } else {
        _typewriterTimer?.cancel();
      }
    });
  }

  Future<void> _navigateAfterDelay() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // وقت الانتقال: طول الأنميشن + انتظار إضافي بسيط
    await Future.delayed(Duration(milliseconds: 150 * _fullText.length + 600));
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF29434E), Color(0xFF546E7A)],
                ),
          color: isDark ? const Color(0xFF232F34) : null,
        ),
        child: Center(
          child: Text(
            _displayed,
            style: GoogleFonts.poppins(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF546E7A),
              letterSpacing: 3,
              shadows: [
                Shadow(
                  blurRadius: 24,
                  color: const Color.fromRGBO(0, 0, 0, 0.18),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

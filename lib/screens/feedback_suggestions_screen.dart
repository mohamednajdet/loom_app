import 'package:flutter/material.dart';
import '../widgets/back_button_custom.dart';
import '../services/api_service_dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackSuggestionsScreen extends StatefulWidget {
  const FeedbackSuggestionsScreen({super.key});

  @override
  State<FeedbackSuggestionsScreen> createState() =>
      _FeedbackSuggestionsScreenState();
}

class _FeedbackSuggestionsScreenState extends State<FeedbackSuggestionsScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendFeedback() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final phone = prefs.getString('userPhone');

      if (userId == null || phone == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ لم يتم العثور على بيانات المستخدم')),
          );
        }
        setState(() => _isSending = false);
        return;
      }

      final success = await ApiServiceDio.sendFeedback(
        message: message,
        userId: userId,
        phone: phone,
      );

      if (!mounted) return;

      if (success) {
        _controller.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إرسال الشكوى/الاقتراح بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ حدث خطأ أثناء الإرسال')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ فشل في الإرسال: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFDDDDDD);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const BackButtonCustom(title: 'الشكاوى والاقتراحات'),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withAlpha(33)
                                : const Color(0x3F000000),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Cairo',
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: 'اكتب الشكوى او الاقتراح هنا',
                          hintStyle: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF546E7A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: borderColor),
                      ),
                      shadowColor: isDark
                          ? Colors.black.withAlpha(33)
                          : const Color(0x3F000000),
                      elevation: 4,
                    ),
                    onPressed: _isSending ? null : _sendFeedback,
                    child: _isSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'ارسال',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Cairo',
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
}

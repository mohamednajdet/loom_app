import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service_dio.dart';
import '../widgets/back_button_custom.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController reasonController = TextEditingController();

  Future<void> _deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final userId = await ApiServiceDio.getUserIdFromToken(token);
    if (userId == null) return;

    final success = await ApiServiceDio.deleteUser(userId);
    if (!mounted) return;

    if (success) {
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('userName');
      await prefs.remove('userPhone');
      // ignore: use_build_context_synchronously
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل حذف الحساب. حاول لاحقاً!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mainTextColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final cardColor = isDark ? const Color(0xFF232F34) : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // back + title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: BackButtonCustom(title: 'حذف الحساب'),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // البطاقة الأولى
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : const Color(0xFFDDDDDD),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: mainTextColor.withAlpha((0.06 * 255).toInt()),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // العنوان بمسافة
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'سوف نقوم بحذف حسابك من تطبيق loom',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 117, 46, 46),
                                  fontFamily: 'Cairo',
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'نأسف لأنك سوف تغادرنا، وهناك أمور يجب أن تعلمها قبل حذف الحساب',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: mainTextColor.withAlpha((0.87 * 255).toInt()),
                                fontFamily: 'Cairo',
                                height: 1.7,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 14),
                            _deleteBullet(
                                'سوف يتم حذف جميع المشتريات الخاصة بك', mainTextColor),
                            _deleteBullet(
                                'سوف يتم حذف جميع العروض المخصصة لك', mainTextColor),
                            _deleteBullet(
                                'سوف يتم حذف جميع النقاط التي كسبتها من المشتريات',
                                mainTextColor),
                            const SizedBox(height: 16),
                            Text(
                              'ولكن في حال تسجيل الخروج، يمكنك الاحتفاظ بجميع هذه المعلومات. شكراً لك من لووم',
                              style: TextStyle(
                                fontSize: 13,
                                color: mainTextColor.withAlpha((0.7 * 255).toInt()),
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // البطاقة الثانية
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : const Color(0xFFDDDDDD),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: mainTextColor.withAlpha((0.04 * 255).toInt()),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'يمكنك اخبارنا بسبب مغادرتك لنا',
                                style: TextStyle(
                                  color:
                                      mainTextColor.withAlpha((0.7 * 255).toInt()),
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF232F34)
                                    : Colors.white,
                                border:
                                    Border.all(color: const Color(0xFFF0F0F0)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TextField(
                                controller: reasonController,
                                maxLines: null,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: mainTextColor,
                                ),
                                decoration: InputDecoration(
                                  hintText: "سبب المغادرة (اختياري)...",
                                  hintStyle: TextStyle(
                                    color: mainTextColor
                                        .withAlpha((0.55 * 255).toInt()),
                                    fontFamily: 'Cairo',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // الزر
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD71368),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1.5,
                    ),
                    onPressed: _deleteAccount,
                    child: const Text(
                      'حذف الحساب وتسجيل الخروج',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
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

  Widget _deleteBullet(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(Icons.circle, size: 7.3, color: Color(0xFF29434E)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13.2,
                  color: color,
                  fontFamily: 'Cairo',
                  height: 1.65,
                ),
              ),
            ),
          ],
        ),
      );
}

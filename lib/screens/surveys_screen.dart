import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service_dio.dart';
import '../widgets/back_button_custom.dart';

class SurveysScreen extends StatefulWidget {
  const SurveysScreen({super.key});

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSending = false;
  final Map<int, String> _answers = {};

  // ألوان الهوية البصرية
  static const kPrimary = Color(0xFF546E7A);
  static const kAccent = Color(0xFF29434E);
  static const kBgLight = Color(0xFFFAFAFA);
  static const kBorder = Color(0xFFDDDDDD);
  static const kTextLight = Color(0xFF333333);
  static const kTextDark = Colors.white;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'هل واجهت مشكلة عند استخدامك التطبيق؟',
      'options': ['نعم', 'كلا'],
    },
    {
      'question': 'ما مدى رضاك عن التطبيق بصورة عامة؟',
      'options': ['راض للغاية', 'راض', 'غير راض'],
    },
    {
      'question': 'هل تجد كل ماتحتاجه داخل التطبيق؟',
      'options': ['نعم', 'نوعا ما', 'كلا'],
    },
    {
      'question': 'ماهو تقييمك لموظف مركز خدمة الزبائن؟',
      'options': ['جيد جدا', 'جيد', 'سيئ'],
    },
  ];

  Future<void> _submitSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final phone = prefs.getString('userPhone');
    final notes = _noteController.text.trim();

    if (!mounted) return;

    if (userId == null || phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لم يتم العثور على بيانات المستخدم')),
      );
      return;
    }

    // جميع الأسئلة يجب أن تكون مجابة
    if (_answers.length != questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى الإجابة على جميع الأسئلة')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await ApiServiceDio.sendSurveys(
        userId: userId,
        phone: phone,
        answers: _answers,
        notes: notes,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إرسال الاستبيان بنجاح')),
      );

      _noteController.clear();
      setState(() {
        _answers.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ فشل في الإرسال: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? kAccent : kBgLight;
    final borderColor = isDark ? Colors.black26 : kBorder;
    final textColor = isDark ? kTextDark : kTextLight;
    final hintTextColor = isDark ? Colors.white54 : Colors.black38;
    final boxShadowColor = isDark ? Colors.black26 : const Color(0x3F000000);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldColor, // نفس باقي الشاشات
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const BackButtonCustom(title: 'الاستبيانات'),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: questions.length + 1,
                  separatorBuilder: (_,_) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index < questions.length) {
                      final q = questions[index];
                      return _buildQuestion(
                        context,
                        index,
                        q['question'],
                        q['options'],
                        cardColor,
                        borderColor,
                        textColor,
                        boxShadowColor,
                      );
                    } else {
                      // حقل الملاحظات
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: boxShadowColor,
                              blurRadius: 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'هل لديك ملاحظات اخرى؟ يمكنك كتابة الملاحظات',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _noteController,
                              maxLines: 4,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                color: textColor,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(12),
                                hintText: 'اكتب ملاحظتك هنا',
                                hintStyle: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: hintTextColor,
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.black12 : Color(0xFFF5F5F5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSending ? null : _submitSurvey,
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ارسال',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
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

  Widget _buildQuestion(
    BuildContext context,
    int index,
    String question,
    List<String> options,
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color boxShadowColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: boxShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '*',
                style: TextStyle(
                  color: kPrimary,
                  fontSize: 20,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((option) {
              Color buttonColor;
              // لون خاص للجواب كلا للسؤال الأول
              if (_answers[index] == option) {
                buttonColor = kAccent;
              } else if (option == 'كلا' && index == 0) {
                buttonColor = Color(0xFFD71468);
              } else {
                buttonColor = kPrimary;
              }
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _answers[index] = option;
                    });
                  },
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      option,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/back_button_custom.dart';

class AboutLoomScreen extends StatelessWidget {
  const AboutLoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const BackButtonCustom(title: 'عن لووم'),
              const SizedBox(height: 20),

              // نص loom خارج البوكس
              Text(
                'loom',
                style: TextStyle(
                  fontSize: 64,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF546E7A),
                ),
              ),
              const SizedBox(height: 20),

              // الصندوق المحتوي للنص الكامل
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.grey.shade700
                              : const Color(0xFFDDDDDD),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withAlpha((0.18 * 255).toInt())
                                : const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'عن loom\n'
                          'تطبيق loom هو منصة رقمية متكاملة لبيع الملابس أونلاين داخل العراق، تم تصميمه خصيصاً لتقديم تجربة تسوق استثنائية وسلسة للمستخدم العراقي، بعيداً عن التعقيد وبجودة تضاهي التطبيقات العالمية.\n\n'
                          'من خلال loom، نمنحك إمكانية تصفّح مئات المنتجات المتنوعة من الملابس الرجالية والنسائية، بتصنيفات واضحة تشمل: تيشيرتات، قمصان، جينزات، فساتين، بدلات، أحذية، وغيرها الكثير، مع تحديثات مستمرة لأحدث التشكيلات الموسمية والعصرية.\n\n'
                          'نحن في loom نؤمن بأن الأناقة تبدأ من التفاصيل، ولذلك ركزنا على تقديم ملابس مختارة بعناية، بجودة عالية وأسعار تنافسية، لتناسب كل الأذواق والمناسبات، سواءً كانت إطلالة كاجوال، رسمية، أو حتى رياضية.\n\n'
                          'يتميز تطبيق loom بواجهة استخدام بسيطة وسهلة، تدعم اللغتين العربية والإنجليزية، وتوفّر إمكانية التبديل بين الوضع الفاتح والداكن حسب تفضيل المستخدم. كما حرصنا على تصميم التطبيق ليكون متجاوبًا بالكامل مع جميع أنواع الأجهزة لضمان تجربة مثالية للجميع.\n\n'
                          'تشمل مميزات التطبيق:\n'
                          '• نظام مفضلة (Wishlist) لحفظ المنتجات المحببة\n'
                          '• بحث ذكي مع فلاتر متقدمة (النوع، السعر، المناسبة...)\n'
                          '• إشعارات فورية للعروض الجديدة\n'
                          '• دعم كامل لتسجيل الدخول عبر رقم الهاتف\n'
                          '• إدارة سهلة للعناوين وطرق التوصيل\n'
                          '• إمكانية مشاركة التطبيق مع الأصدقاء\n\n'
                          'نحن لا نقدّم فقط منتجاً، بل نبني تجربة تسوق متكاملة، تبدأ من تصفح المنتج حتى استلامه أمام باب بيتك. فريق loom يعمل باستمرار على تحسين الأداء، دعم الزبائن، وتوفير أفضل تجربة ممكنة.\n\n'
                          'نسعى لأن يكون loom الخيار الأول لكل من يبحث عن ملابس أنيقة، موثوقة، وسريعة الوصول داخل العراق.\n\n'
                          'شكراً لثقتكم بـ loom',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                            fontFamily: 'Cairo',
                            height: 1.6,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'إصدار التطبيق: v1.0.0',
                          style: TextStyle(
                            color: textColor.withAlpha((0.85 * 255).toInt()),
                            fontSize: 12,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
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

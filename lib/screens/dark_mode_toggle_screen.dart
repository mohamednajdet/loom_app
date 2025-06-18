import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/theme_cubit.dart';
import '../widgets/back_button_custom.dart'; // تأكد من الاستيراد

class DarkModeToggleScreen extends StatelessWidget {
  const DarkModeToggleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? const Color(0xFF333333);
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : const Color(0xFFF0F0F0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const BackButtonCustom(title: 'التبديل بين الوضع الفاتح والداكن'),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black.withAlpha((0.06 * 255).toInt())
                            : const Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          'تفعيل الوضع الداكن',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 11),
                        child: BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, mode) {
                            final bool isDark = mode == ThemeMode.dark;
                            return Transform.scale(
                              scale: 1.13,
                              child: Switch(
                                value: isDark,
                                onChanged: (v) =>
                                    context.read<ThemeCubit>().toggleTheme(),
                                activeColor: Colors.white,
                                activeTrackColor: const Color(0xFF546E7A), // شعار loom
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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

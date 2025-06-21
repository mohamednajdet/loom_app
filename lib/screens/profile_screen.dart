import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/api_service_dio.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userPhone;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'اسم المستخدم';
      userPhone = prefs.getString('userPhone') ?? '07XXXXXXXXX';
    });
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final userId = await ApiServiceDio.getUserIdFromToken(token);
    if (userId == null) return;

    final success = await ApiServiceDio.deleteUser(userId);
    if (success) {
      await prefs.remove('token');
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> showLogoutDialog(
    BuildContext context,
    VoidCallback onConfirm,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.08 * 255).toInt()),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'هل انت متأكد من تسجيل الخروج؟',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // زر "لا" على اليمين وثابت لونه
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF29434E),
                              side: const BorderSide(color: Color(0xFF29434E)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor:
                                  Colors.white, // يبقى أبيض في كل الحالات
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'لا',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF29434E), // ثابت في كل الحالات
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // زر "نعم" على اليسار وثابت لونه
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF546E7A), // ثابت
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onConfirm();
                            },
                            child: const Text(
                              'نعم',
                              style: TextStyle(
                                color: Colors.white, // ثابت
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = const Color(0xFF546E7A);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'حسابي',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: primary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? const Color.fromRGBO(0, 0, 0, 0.10)
                                : const Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/avatar.svg',
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontFamily: 'Cairo',
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userPhone ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // جميع الخيارات داخل Container واحد متلاصق
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? const Color.fromRGBO(0, 0, 0, 0.10)
                                : const Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildOption(
                        context: context,
                        icon: Icons.location_on_outlined,
                        title: 'العناوين المحفوظة',
                        iconColor: primary,
                        onTap: () => context.push('/saved_addresses'),
                        isFirst: true,
                      ),
                      _optionDivider(),
                      _buildOption(
                        context: context,
                        icon: Icons.phone_android,
                        title: 'تغيير الهاتف',
                        iconColor: primary,
                        subtitle: 'تغيير رقم الهاتف الخاص بحسابك',
                        onTap: () => context.push('/change_phone'),
                      ),
                      _optionDivider(),
                      _buildOption(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: 'إعدادات الإشعارات',
                        iconColor: primary,
                        subtitle: 'تخصيص الإشعارات الخاصة بك',
                        onTap: () => context.push('/notifications_settings'),
                      ),
                      _optionDivider(),
                      _buildOption(
                        context: context,
                        icon: Icons.chat_outlined,
                        title: 'الشكاوى والاقتراحات',
                        iconColor: primary,
                        onTap: () => context.push('/feedback'),
                      ),
                      _optionDivider(),
                      _buildOption(
                        context: context,
                        icon: Icons.list_alt_outlined,
                        title: 'الاستبيانات',
                        iconColor: primary,
                        onTap: () => context.push('/surveys'),
                      ),
                      _optionDivider(),
                      _buildOption(
                        context: context,
                        icon: Icons.wb_sunny_outlined,
                        title: 'التبديل بين الوضع الفاتح والداكن',
                        iconColor: primary,
                        onTap: () => context.push('/dark-mode-toggle'),
                      ),
                      _optionDivider(),
                      _buildOption(
                        context: context,
                        icon: Icons.favorite_border,
                        title: 'مفضلاتي',
                        iconColor: primary,
                        onTap: () => context.push('/wishlist'),
                      ),
                      _optionDivider(),
                      _buildOption(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'عن لووم',
                        iconColor: primary,
                        onTap: () => context.push('/about-loom'),
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? const Color.fromRGBO(0, 0, 0, 0.10)
                                : const Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Color(0xFFD71368),
                        ),
                        title: const Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Color(0xFFD71368),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        onTap:
                            () => showLogoutDialog(
                              context,
                              () => logout(context),
                            ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'حذف الحساب',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.red,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color(0xFF757575),
                        ),
                        onTap: () => context.push('/delete_account'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return BottomNavigationBar(
                selectedItemColor: primary,
                unselectedItemColor: const Color(0xFF777777),
                backgroundColor:
                    Theme.of(
                      context,
                    ).bottomNavigationBarTheme.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                currentIndex: 3,
                type: BottomNavigationBarType.fixed,
                onTap: (index) {
                  if (index == 0) {
                    context.go('/');
                  } else if (index == 1) {
                    context.go('/categories');
                  } else if (index == 2) {
                    context.go('/cart');
                  }
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    label: 'الرئيسية',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.category_outlined),
                    label: 'التصنيفات',
                  ),
                  BottomNavigationBarItem(
                    icon: badges.Badge(
                      showBadge: state.items.isNotEmpty,
                      badgeContent: Text(
                        '${state.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: Color(0xFF546E7A),
                        shape: badges.BadgeShape.circle,
                        padding: EdgeInsets.all(6),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    label: 'السلة',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'حسابي',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Divider رفيع بين الخيارات
  Widget _optionDivider() => const Divider(
    height: 1,
    thickness: 1,
    color: Color(0xFFF0F0F0),
    indent: 16,
    endIndent: 16,
  );

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Color iconColor = const Color(0xFF546E7A),
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontFamily: 'Cairo',
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                  ),
                )
                : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF757575),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        minVerticalPadding: 0,
        dense: true,
      ),
    );
  }
}

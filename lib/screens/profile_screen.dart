import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;

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
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'حسابي',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: Color(0xFF29434E),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFD9D9D9),
                        child: Icon(Icons.person, size: 30, color: Color(0xFF546E7A)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Cairo',
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userPhone ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildOption(
                  icon: Icons.location_on_outlined,
                  title: 'العناوين المحفوظة',
                  onTap: () => Navigator.pushNamed(context, '/saved_addresses'),
                ),
                _buildOption(icon: Icons.phone_android, title: 'تغيير الهاتف', subtitle: 'تغيير رقم الهاتف الخاص بحسابك'),
                _buildOption(icon: Icons.notifications_outlined, title: 'إعدادات الإشعارات', subtitle: 'تخصيص الإشعارات الخاصة بك'),
                _buildOption(icon: Icons.chat_outlined, title: 'الشكاوى والاقتراحات'),
                _buildOption(icon: Icons.list_alt_outlined, title: 'الاستبيانات'),
                _buildOption(icon: Icons.wb_sunny_outlined, title: 'التبديل بين الوضع الفاتح والداكن'),
                _buildOption(icon: Icons.favorite_border, title: 'مفضلاتي'),
                _buildOption(icon: Icons.info_outline, title: 'عن لووم'),

                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Color(0xFFD71368)),
                        title: const Text('تسجيل الخروج',
                            style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFD71368))),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF757575)),
                        onTap: () => logout(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                        title: const Text('حذف الحساب',
                            style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF757575)),
                        onTap: () => deleteAccount(context),
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
                selectedItemColor: const Color(0xFF546E7A),
                unselectedItemColor: const Color(0xFF777777),
                currentIndex: 3,
                type: BottomNavigationBarType.fixed,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushNamed(context, '/home');
                  } else if (index == 1) {
                    Navigator.pushNamed(context, '/categories');
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/cart');
                  }
                },
                items: [
                  const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
                  const BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: 'التصنيفات'),
                  BottomNavigationBarItem(
                    icon: badges.Badge(
                      showBadge: state.items.isNotEmpty,
                      badgeContent: Text(
                        '${state.items.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
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
                  const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF546E7A)),
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF757575)),
        onTap: onTap,
      ),
    );
  }
}

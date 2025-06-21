import 'package:flutter/material.dart';
import '../widgets/back_button_custom.dart';
import '../services/api_service_dio.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool notifOrderStatus = true;
  bool notifDeals = true;
  bool notifGeneral = true;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsFromServer();
  }

  Future<void> _loadSettingsFromServer() async {
    setState(() => isLoading = true);
    try {
      final settings = await ApiServiceDio.getNotificationSettings();
      if (!mounted) return; // ✅ حماية من استخدام context بعد await
      setState(() {
        notifOrderStatus = settings['orderStatus'] ?? true;
        notifDeals = settings['deals'] ?? true;
        notifGeneral = settings['general'] ?? true;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return; // ✅ حماية هنا أيضاً
      setState(() => isLoading = false);
      _showToast(context, 'فشل تحميل الإعدادات، تحقق من اتصالك');
    }
  }

  Future<void> _saveSettingsToServer() async {
    setState(() => isSaving = true);
    try {
      await ApiServiceDio.updateNotificationSettings(
        orderStatus: notifOrderStatus,
        deals: notifDeals,
        general: notifGeneral,
      );
      if (!mounted) return; // ✅ حماية من استخدام context بعد await
      setState(() => isSaving = false);
    } catch (e) {
      if (!mounted) return; // ✅ حماية هنا أيضاً
      setState(() => isSaving = false);
      _showToast(context, 'حدث خطأ أثناء الحفظ');
    }
  }

  void _onSwitchChanged(String type, bool value) {
    setState(() {
      if (type == 'orderStatus') notifOrderStatus = value;
      if (type == 'deals') notifDeals = value;
      if (type == 'general') notifGeneral = value;
    });
    _saveSettingsToServer();
  }

  Widget buildSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? const Color(0xFF333333);
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : const Color(0xFFF0F0F0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Container(
        height: 54,
        margin: const EdgeInsets.only(bottom: 16),
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
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF546E7A)),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Transform.scale(
                scale: 1.13,
                child: Switch(
                  value: value,
                  onChanged: isSaving ? null : onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF546E7A), // شعار loom
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const BackButtonCustom(title: 'إعدادات الإشعارات'),
                    const SizedBox(height: 40),
                    buildSwitch(
                      title: 'إشعارات حالة الطلب',
                      icon: Icons.local_shipping_outlined,
                      value: notifOrderStatus,
                      onChanged: (val) => _onSwitchChanged('orderStatus', val),
                    ),
                    buildSwitch(
                      title: 'إشعارات العروض والخصومات',
                      icon: Icons.local_offer_outlined,
                      value: notifDeals,
                      onChanged: (val) => _onSwitchChanged('deals', val),
                    ),
                    buildSwitch(
                      title: 'إشعارات عامة',
                      icon: Icons.notifications_none,
                      value: notifGeneral,
                      onChanged: (val) => _onSwitchChanged('general', val),
                    ),
                    if (isSaving) const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    if (!mounted) return; // ✅ حماية إضافية قبل استخدام context هنا أيضا
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ));
  }
}

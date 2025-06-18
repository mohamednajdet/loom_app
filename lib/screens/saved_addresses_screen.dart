import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';

import '../widgets/back_button_custom.dart';
import '../services/api_service_dio.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final logger = Logger();
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = false;

  // ألوان الهوية البصرية
  static const Color kPrimary = Color(0xFF546E7A);
  static const Color kAccent = Color(0xFF29434E);
  static const Color kDelete = Color(0xFFE57373);
  static const Color kBgLight = Color(0xFFFAFAFA);
  static const Color kText = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => isLoading = true);
    try {
      addresses = await ApiServiceDio.fetchUserAddresses();
    } catch (e) {
      logger.e('❌ فشل تحميل العناوين', error: e);
    }
    setState(() => isLoading = false);
  }

  Future<void> _addNewAddress() async {
    final result = await context.push('/map-picker');
    if (result != null &&
        result is Map<String, dynamic> &&
        result.containsKey('lat') &&
        result.containsKey('lng') &&
        result.containsKey('label')) {
      final lat = result['lat'];
      final lng = result['lng'];
      final label = result['label'];

      try {
        await ApiServiceDio.addAddress(lat: lat, lng: lng, label: label);
        _loadAddresses();
      } catch (e) {
        logger.e('❌ فشل في حفظ العنوان', error: e);
      }
    }
  }

  Future<void> _editAddress(Map<String, dynamic> address) async {
    final result = await context.push('/map-picker');
    if (result != null &&
        result is Map<String, dynamic> &&
        result.containsKey('lat') &&
        result.containsKey('lng') &&
        result.containsKey('label')) {
      final lat = result['lat'];
      final lng = result['lng'];
      final label = result['label'];

      try {
        await ApiServiceDio.updateAddress(
          addressId: address['_id'],
          lat: lat,
          lng: lng,
          newLabel: label,
        );
        _loadAddresses();
      } catch (e) {
        logger.e('❌ فشل تعديل العنوان', error: e);
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await ApiServiceDio.deleteAddress(addressId);
      _loadAddresses();
    } catch (e) {
      logger.e('❌ فشل حذف العنوان', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? kAccent : kBgLight;
    final textColor = isDark ? Colors.white : kText;
final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldColor,
        body: SafeArea(
          child: Column(
            children: [
              const BackButtonCustom(title: 'العناوين المحفوظة'),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _addNewAddress,
                  child: const Text(
                    'إضافة عنوان جديد  +',
                    style: TextStyle(
                      fontSize: 16,
                      color: kPrimary,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              isLoading
                  ? const Expanded(
                      child: Center(child: CircularProgressIndicator(color: kPrimary)))
                  : addresses.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              'لا توجد عناوين محفوظة',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final item = addresses[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha((0.07 * 255).toInt()),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFFD9D9D9),
                                    child: Icon(
                                      Icons.location_on,
                                      color: kPrimary,
                                    ),
                                  ),
                                  title: Text(
                                    item['label'] ?? 'عنوان غير معروف',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Cairo',
                                      color: textColor,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: kPrimary),
                                        onPressed: () => _editAddress(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: kDelete),
                                        onPressed: () => _deleteAddress(item['_id']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

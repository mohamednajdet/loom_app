import 'package:flutter/material.dart';
import '../widgets/back_button_custom.dart'; // تأكد من وجود هذا المسار الصحيح

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  final List<Map<String, String>> addresses = const [
    {
      'title': 'السيدية حي الكفاءات',
      'subtitle': 'المنزل, كفاءات السيدية',
    },
    {
      'title': 'حي العدل',
      'subtitle': 'المنزل, مجمع اميمة',
    },
    {
      'title': 'حي النصر',
      'subtitle': 'المنزل, كركوك حي النصر',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              BackButtonCustom(title: 'العناوين المحفوظة'),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: إضافة عنوان جديد
                  },
                  child: const Text(
                    'إضافة +',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF333333),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final item = addresses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFD9D9D9),
                          child: Icon(Icons.location_on, color: Color(0xFF546E7A)),
                        ),
                        title: Text(
                          item['title']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Cairo',
                            color: Color(0xFF333333),
                          ),
                        ),
                        subtitle: Text(
                          item['subtitle']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Cairo',
                            color: Color(0xFF888888),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                // TODO: تعديل العنوان
                              },
                              icon: const Icon(Icons.edit, color: Color(0xFF546E7A)),
                            ),
                            IconButton(
                              onPressed: () {
                                // TODO: حذف العنوان
                              },
                              icon: const Icon(Icons.delete, color: Color(0xFF80B0C6)),
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

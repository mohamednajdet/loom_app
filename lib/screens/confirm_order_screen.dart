import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/cart/cart_event.dart';
import '../services/api_service_dio.dart';
import '../widgets/back_button_custom.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final cartItems = state.cartItems;
              final totalItems = cartItems.fold<int>(
                0,
                (sum, item) => sum + item.quantity,
              );
              final totalPrice = cartItems.fold<int>(
                0,
                (sum, item) => sum + item.product.price * item.quantity,
              );
              final deliveryFee = totalPrice >= 100000 ? 0 : 5000;
              final grandTotal = totalPrice + deliveryFee;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackButtonCustom(title: 'إتمام الطلب'),
                    const SizedBox(height: 20),

                    // 🔹 عنوان التوصيل
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF546E7A),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حي النصر',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Cairo',
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                Text(
                                  'المنزل, كركوك حي النصر',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Cairo',
                                    color: Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                            size: 24,
                            color: Color(0xFF546E7A),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 العناصر بالسلة
                    ...cartItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image:
                                      item.product.images.isNotEmpty
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              item.product.images.first,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                  color: const Color(0xFFD9D9D9),
                                ),
                                child:
                                    item.product.images.isEmpty
                                        ? const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Cairo',
                                        color: Color(0xFF29434E),
                                      ),
                                    ),
                                    Text(
                                      '${item.product.price * item.quantity} د.ع',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _buildColorCircle(item.selectedColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          'القياس: ${item.selectedSize}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Cairo',
                                            color: Color(0xFF29434E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 الملخص المالي
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryLine('عدد المنتجات :', '$totalItems'),
                          _buildSummaryLine(
                            'مجموع المنتجات :',
                            '$totalPrice د.ع',
                          ),
                          _buildSummaryLine(
                            'التوصيل :',
                            deliveryFee == 0 ? 'مجاناً' : '$deliveryFee د.ع',
                          ),
                          _buildSummaryLine(
                            'الاجمالي :',
                            '$grandTotal د.ع',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 أزرار تأكيد وإلغاء
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF546E7A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final cartItems =
                                  context.read<CartBloc>().state.cartItems;

                              if (cartItems.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🚫 السلة فارغة'),
                                  ),
                                );
                                return;
                              }

                              final messenger = ScaffoldMessenger.of(
                                context,
                              ); // 🔹 نحجزه قبل await
                              final nav = Navigator.of(
                                context,
                              ); // 🔹 نحجزه قبل await
                              final bloc =
                                  context
                                      .read<CartBloc>(); // 🔹 نحجزه قبل await

                              try {
                                await ApiServiceDio.sendOrder(
                                  items: cartItems,
                                  address: 'المنزل, كركوك حي النصر',
                                );

                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ تم إرسال الطلب بنجاح'),
                                  ),
                                );

                                bloc.add(ClearCart());
                                nav.pop(); // رجوع
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('❌ فشل إرسال الطلب: $e'),
                                  ),
                                );
                              }
                            },

                            child: const Text(
                              'تأكيد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF29434E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(String colorName) {
    final color = _getColorFromName(colorName);
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26),
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label ',
                style: TextStyle(
                  color:
                      isTotal
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF333333),
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  color:
                      isTotal
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF757575),
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'red':
      case 'أحمر':
        return Colors.red;
      case 'blue':
      case 'أزرق':
        return Colors.blue;
      case 'green':
      case 'أخضر':
        return Colors.green;
      case 'black':
      case 'أسود':
        return Colors.black;
      case 'white':
      case 'أبيض':
        return Colors.white;
      case 'navy':
      case 'كحلي':
        return const Color(0xFF000080);
      case 'gray':
      case 'رمادي':
        return Colors.grey;
      case 'orange':
      case 'برتقالي':
        return Colors.orange;
      case 'yellow':
      case 'أصفر':
        return Colors.yellow;
      case 'pink':
      case 'وردي':
        return Colors.pink;
      case 'brown':
      case 'بني':
        return Colors.brown;
      case 'beige':
      case 'بيج':
        return const Color(0xFFF5F5DC);
      case 'purple':
      case 'بنفسجي':
        return Colors.purple;
      default:
        return const Color(0xFFCCCCCC);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/cart/cart_event.dart';
import '../services/api_service_dio.dart';
import '../widgets/back_button_custom.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFDDDDDD);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final cartItems = state.cartItems;
              final selectedAddress = state.selectedAddressLabel;
              final totalItems = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
              // مجموع الأسعار المخفضة وليس الأصلية
              final totalPrice = cartItems.fold<int>(
                0,
                (sum, item) => sum + (item.product.discountedPrice ?? item.product.price) * item.quantity,
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

                    // عنوان التوصيل
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withAlpha(33)
                                : const Color(0x26000000),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
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
                            child: const Icon(Icons.location_on, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedAddress ?? 'لم يتم اختيار عنوان',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontFamily: 'Cairo',
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // المنتجات
                    ...cartItems.map(
                      (item) {
                        final int price = item.product.price;
                        final int discountedPrice = item.product.discountedPrice ?? price;
                        final bool hasDiscount = item.product.discount > 0 && discountedPrice < price;
                        final int totalDiscounted = discountedPrice * item.quantity;
                        final int totalOriginal = price * item.quantity;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withAlpha(31)
                                      : Colors.black.withAlpha(15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
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
                                    image: item.product.images.isNotEmpty
                                        ? DecorationImage(image: NetworkImage(item.product.images.first), fit: BoxFit.cover)
                                        : null,
                                    color: isDark
                                        ? Colors.grey[800]
                                        : const Color(0xFFD9D9D9),
                                  ),
                                  child: item.product.images.isEmpty
                                      ? Icon(Icons.image, color: isDark ? Colors.grey[500] : Colors.grey)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            fontSize: 14,
                                            fontFamily: 'Cairo',
                                            color: theme.colorScheme.primary,
                                          )),
                                      Row(
                                        children: [
                                          // سعر بعد التخفيض
                                          Text(
                                            '$totalDiscounted د.ع',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontSize: 13,
                                              fontFamily: 'Cairo',
                                              color: isDark
                                                  ? Colors.grey[300]
                                                  : const Color(0xFF757575),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // السعر الأصلي مشطوب إذا يوجد خصم
                                          if (hasDiscount)
                                            Text(
                                              '$totalOriginal د.ع',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                fontSize: 12,
                                                fontFamily: 'Cairo',
                                                color: Colors.grey,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          _buildColorCircle(item.selectedColor, theme),
                                          const SizedBox(width: 6),
                                          Text('القياس: ${item.selectedSize}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: 14,
                                                fontFamily: 'Cairo',
                                                color: theme.colorScheme.primary,
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ملخص الفاتورة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withAlpha(33)
                                : const Color(0x3F000000),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryLine(theme, 'عدد المنتجات :', '$totalItems'),
                          _buildSummaryLine(theme, 'مجموع المنتجات :', '$totalPrice د.ع'),
                          _buildSummaryLine(theme, 'التوصيل :', deliveryFee == 0 ? 'مجاناً' : '$deliveryFee د.ع'),
                          _buildSummaryLine(theme, 'الاجمالي :', '$grandTotal د.ع', isTotal: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // أزرار
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF546E7A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              if (cartItems.isEmpty || selectedAddress == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('🚫 تأكد من إضافة منتجات واختيار عنوان')),
                                );
                                return;
                              }

                              final messenger = ScaffoldMessenger.of(context);
                              final bloc = context.read<CartBloc>();

                              try {
                                await ApiServiceDio.sendOrder(
                                  items: cartItems,
                                  address: selectedAddress,
                                );

                                bloc.add(ClearCart());
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('✅ تم إرسال الطلب بنجاح')),
                                );
                                if (!context.mounted) return;
                                context.pop();
                              } catch (e) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('❌ فشل إرسال الطلب: $e')),
                                );
                              }
                            },
                            child: const Text('تأكيد', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF29434E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => context.pop(),
                            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
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

  Widget _buildColorCircle(String colorName, ThemeData theme) {
    final color = _getColorFromName(colorName);
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: theme.dividerColor),
      ),
    );
  }

  Widget _buildSummaryLine(ThemeData theme, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isTotal ? Colors.green : theme.textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              TextSpan(
                text: value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isTotal ? Colors.green : theme.textTheme.bodySmall?.color,
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
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

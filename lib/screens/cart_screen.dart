import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/cart/cart_event.dart';
import '../widgets/back_button_custom.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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

              if (cartItems.isEmpty) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      child: const BackButtonCustom(title: 'السلة'),
                    ),
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'السلة فارغة حالياً',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Cairo',
                        color: Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF546E7A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Text(
                          'العودة إلى المتجر',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Cairo',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackButtonCustom(title: 'السلة'),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF29434E),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'المنزل - بغداد، حي الجامعة، شارع المدارس',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                color: Color(0xFF29434E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                          size: 32,
                                          color: Colors.grey,
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF29434E),
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    Text(
                                      '${item.product.price * item.quantity} د.ع',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF757575),
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _buildColorCircle(item.selectedColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          'القياس: ${item.selectedSize}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF29434E),
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _buildCircleButton('+', () {
                                          context.read<CartBloc>().add(
                                            IncreaseQuantity(
                                              product: item.product,
                                              selectedColor: item.selectedColor,
                                              selectedSize: item.selectedSize,
                                            ),
                                          );
                                        }),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        _buildCircleButton('-', () {
                                          context.read<CartBloc>().add(
                                            DecreaseQuantity(
                                              product: item.product,
                                              selectedColor: item.selectedColor,
                                              selectedSize: item.selectedSize,
                                            ),
                                          );
                                        }),
                                        IconButton(
                                          onPressed: () {
                                            context.read<CartBloc>().add(
                                              RemoveFromCart(
                                                product: item.product,
                                                selectedColor:
                                                    item.selectedColor,
                                                selectedSize: item.selectedSize,
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
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
                          buildSummaryLine('عدد المنتجات :', '$totalItems'),
                          buildSummaryLine(
                            'مجموع المنتجات :',
                            '$totalPrice د.ع',
                          ),
                          buildSummaryLine(
                            'التوصيل :',
                            deliveryFee == 0 ? 'مجاناً' : '$deliveryFee د.ع',
                          ),
                          buildSummaryLine(
                            'الاجمالي :',
                            '$grandTotal د.ع',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF546E7A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/confirm-order');
                        },
                        child: const Text(
                          'اتمام الدفع',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Cairo',
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  Widget _buildCircleButton(String symbol, VoidCallback onPressed) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        color: Color(0xFF546E7A),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Text(
          symbol,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget buildSummaryLine(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color:
                    isTotal ? const Color(0xFF2E7D32) : const Color(0xFF333333),
                fontSize: 16,
                fontFamily: 'Cairo',
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color:
                    isTotal ? const Color(0xFF2E7D32) : const Color(0xFF757575),
                fontSize: 16,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        textAlign: TextAlign.right,
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

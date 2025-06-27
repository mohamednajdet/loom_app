import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/flutter_svg.dart';

import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/cart/cart_event.dart';
import '../services/api_service_dio.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> userAddresses = [];
  Map<String, dynamic>? selectedAddress;
  int _selectedIndex = 2; // السلة دائماً Active

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final result = await ApiServiceDio.fetchUserAddresses();
      if (result.isNotEmpty) {
        setState(() {
          userAddresses = result;
          selectedAddress = result.first;
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  void _selectAddress(Map<String, dynamic> address) {
    setState(() {
      selectedAddress = address;
    });
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/categories');
        break;
      case 2:
        // سلة، لا شي
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF546E7A);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = const Color(0xFF546E7A);
    final cardColor = theme.cardColor;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldBg,
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
                (sum, item) =>
                    sum +
                    (item.product.discountedPrice ?? item.product.price) *
                        item.quantity,
              );
              final deliveryFee = totalPrice >= 100000 ? 0 : 5000;
              final grandTotal = totalPrice + deliveryFee;

              if (cartItems.isEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'السلة',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: isDark ? Colors.grey[600] : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'السلة فارغة حالياً',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontFamily: 'Cairo',
                        color: isDark
                            ? Colors.grey[200]
                            : const Color(0xFF555555),
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
                      onPressed: () => context.go('/'),
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
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'السلة',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (userAddresses.isNotEmpty)
                      Column(
                        children: userAddresses.map((address) {
                          final isSelected =
                              selectedAddress != null &&
                              selectedAddress!['_id'] == address['_id'];
                          return GestureDetector(
                            onTap: () => _selectAddress(address),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primary.withAlpha((0.15 * 255).toInt())
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? primary
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      address['label'],
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontFamily: 'Cairo',
                                            color: primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    ...cartItems.map((item) {
                      final int price = item.product.price;
                      final int discountedPrice =
                          item.product.discountedPrice ?? price;
                      final bool hasDiscount =
                          item.product.discount > 0 && discountedPrice < price;
                      final int totalDiscounted =
                          discountedPrice * item.quantity;
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
                                    ? Colors.black.withAlpha(
                                        (0.12 * 255).toInt(),
                                      )
                                    : Colors.black.withAlpha(
                                        (0.06 * 255).toInt(),
                                      ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
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
                                  image: item.product.images.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            item.product.images.first,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : const Color(0xFFD9D9D9),
                                ),
                                child: item.product.images.isEmpty
                                    ? Icon(
                                        Icons.image,
                                        size: 32,
                                        color: isDark
                                            ? Colors.grey[500]
                                            : Colors.grey,
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
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontSize: 14,
                                            color: primary,
                                            fontFamily: 'Cairo',
                                          ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // سعر بعد التخفيض
                                        Text(
                                          '$totalDiscounted د.ع',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 13,
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : const Color(0xFF757575),
                                                fontFamily: 'Cairo',
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        // سعر اصلي مشطوب
                                        if (hasDiscount)
                                          Text(
                                            '$totalOriginal د.ع',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  fontFamily: 'Cairo',
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                          ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _buildColorCircle(
                                          item.selectedColor,
                                          theme,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'القياس: ${item.selectedSize}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontSize: 14,
                                                color: primary,
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
                                        }, theme),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(fontSize: 16),
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
                                        }, theme),
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
                      );
                    }),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border.all(
                          color: isDark
                              ? Colors.grey[800]!
                              : const Color(0xFFDDDDDD),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withAlpha((0.13 * 255).toInt())
                                : const Color(0x3F000000),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildSummaryLine(
                            theme,
                            'عدد المنتجات :',
                            '$totalItems',
                          ),
                          buildSummaryLine(
                            theme,
                            'مجموع المنتجات :',
                            '$totalPrice د.ع',
                          ),
                          buildSummaryLine(
                            theme,
                            'التوصيل :',
                            deliveryFee == 0 ? 'مجاناً' : '$deliveryFee د.ع',
                          ),
                          buildSummaryLine(
                            theme,
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
                          if (selectedAddress != null) {
                            context.read<CartBloc>().add(
                              SelectAddress(selectedAddress!['label']),
                            );
                            context.push('/confirm-order');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى اختيار عنوان أولاً'),
                              ),
                            );
                          }
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
        bottomNavigationBar: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return BottomNavigationBar(
                selectedItemColor: primary,
                unselectedItemColor: const Color(0xFF777777),
                currentIndex: _selectedIndex,
                type: BottomNavigationBarType.fixed,
                backgroundColor:
                    Theme.of(
                      context,
                    ).bottomNavigationBarTheme.backgroundColor ??
                    Theme.of(context).scaffoldBackgroundColor,
                onTap: _onNavTap,
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
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icons/delivery.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 3
                            ? primaryColor
                            : const Color(0xFF777777),
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'طلباتي',
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

  Widget _buildCircleButton(
    String symbol,
    VoidCallback onPressed,
    ThemeData theme,
  ) {
    final Color btnColor = symbol == '+'
        ? const Color(0xFF546E7A)
        : const Color(0xFF29434E);

    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(color: btnColor, shape: BoxShape.circle),
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

  Widget buildSummaryLine(
    ThemeData theme,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isTotal
                    ? Colors.green
                    : theme.textTheme.bodyLarge?.color,
                fontSize: 16,
                fontFamily: 'Cairo',
              ),
            ),
            TextSpan(
              text: value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isTotal
                    ? Colors.green
                    : theme.textTheme.bodySmall?.color,
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

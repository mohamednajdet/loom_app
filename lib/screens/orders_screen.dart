import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../blocs/orders/orders_bloc.dart';
import '../blocs/orders/orders_state.dart';
import '../blocs/orders/orders_event.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'delivered':
      case 'تم التوصيل':
        return Colors.green;
      case 'cancelled':
      case 'ملغي':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _statusArabic(String status) {
    switch (status) {
      case 'pending':
        return 'قيد التنفيذ';
      case 'shipped':
        return 'قيد التوصيل';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = const Color(0xFF546E7A);
    final priceColor = isDark ? Colors.white : primary;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'طلباتي',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: primary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, state) {
                    if (state is OrdersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is OrdersError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حدث خطأ أثناء تحميل الطلبات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 17,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<OrdersBloc>().add(LoadOrders()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                              ),
                              child: const Text(
                                'إعادة المحاولة',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is OrdersLoaded) {
                      final orders = state.orders;
                      if (orders.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد طلبات',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, idx) {
                          final order = orders[idx];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black12
                                      : Colors.black.withAlpha(18),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'رقم الطلب: #${order.orderNumber}',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Cairo',
                                        color: primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status, theme),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _statusArabic(order.status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'تاريخ الطلب: ${_formatDate(order.createdAt)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'Cairo',
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFF546E7A),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        order.address,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // قائمة المنتجات مع السعر المخفض والسعر الأصلي
                                ...order.products.map((prod) {
                                  final int discountedPrice = prod.discountedPrice ?? prod.priceAtOrder;
                                  final int originalPrice = prod.originalPrice ?? prod.priceAtOrder;
                                  final int discount = prod.discount ?? 0;
                                  final bool hasDiscount = discount > 0 && discountedPrice < originalPrice;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            prod.image,
                                            width: 42,
                                            height: 42,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Container(
                                              width: 42,
                                              height: 42,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                prod.name,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 14,
                                                  color: textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      color: _getColorFromName(prod.color),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: theme.dividerColor,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'المقاس: ${prod.size}',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      fontFamily: 'Cairo',
                                                      fontSize: 12,
                                                      color: isDark
                                                          ? Colors.grey[400]
                                                          : Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // السعر المخفض والسعر الأصلي مشطوب بأسلوب Home
                                              Row(
                                                children: [
                                                  Text(
                                                    '$discountedPrice د.ع',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Cairo',
                                                      color: priceColor,
                                                    ),
                                                  ),
                                                  if (hasDiscount) ...[
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '$originalPrice د.ع',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: 'Cairo',
                                                        color: Colors.grey,
                                                        decoration: TextDecoration.lineThrough,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF29434E),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        '-$discount%',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontFamily: 'Tajawal',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'x${prod.quantity}',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontFamily: 'Cairo',
                                                color: primary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${discountedPrice * prod.quantity} د.ع',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontFamily: 'Cairo',
                                                color: isDark
                                                    ? Colors.grey[300]
                                                    : Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(height: 28),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'سعر التوصيل:',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontFamily: 'Cairo',
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${order.deliveryFee} د.ع',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontFamily: 'Cairo',
                                        color: isDark
                                            ? Colors.grey[300]
                                            : Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'المجموع الكلي:',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${order.totalPrice} د.ع',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontFamily: 'Cairo',
                                        color: primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    // بداية التحميل أو حالة أخرى
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
        // البار السفلي الثابت
        bottomNavigationBar: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return BottomNavigationBar(
                selectedItemColor: primary,
                unselectedItemColor: const Color(0xFF777777),
                currentIndex: 3, // طلباتي = المؤشر الثالث
                type: BottomNavigationBarType.fixed,
                backgroundColor:
                    theme.bottomNavigationBarTheme.backgroundColor ??
                    theme.scaffoldBackgroundColor,
                onTap: (index) {
                  if (index == 0) {
                    context.go('/');
                  } else if (index == 1) {
                    context.push('/categories');
                  } else if (index == 2) {
                    context.push('/cart');
                  } else if (index == 3) {
                    // أنت هنا
                  } else if (index == 4) {
                    context.push('/profile');
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
                        badgeColor: Color(0xFF29434E),
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
                      colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
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
}

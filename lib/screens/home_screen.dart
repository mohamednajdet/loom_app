import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:go_router/go_router.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_state.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_state.dart';
import '../blocs/favorite/favorite_event.dart';
import '../models/product_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF546E7A);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = isDark ? Colors.grey[800]! : const Color(0xFFEEEEEE);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // الجرس
                    const Icon(Icons.notifications_none, color: primaryColor),
                    Container(
                      width: 290,
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'العنوان',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: textColor.withAlpha((0.7 * 255).toInt()),
                          ),
                        ],
                      ),
                    ),
                    // البحث
                    const Icon(Icons.search, color: primaryColor),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29434E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'إكتشف تشكيلتنا الجديدة الآن!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'خصومات تصل لـ 30%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    CategoryCircle(label: 'تيشيرتات'),
                    CategoryCircle(label: 'فساتين'),
                    CategoryCircle(label: 'أحذية'),
                    CategoryCircle(label: 'بناطير'),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'مقترحاتنا لك',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontFamily: 'Cairo',
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is HomeLoaded) {
                      final List<ProductModel> products = state.products;

                      return BlocBuilder<FavoriteBloc, FavoriteState>(
                        builder: (context, favState) {
                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                            children:
                                products.map<Widget>((product) {
                                  final isFav = favState.favoriteProductIds
                                      .contains(product.id);
                                  return GestureDetector(
                                    onTap:
                                        () => context.push(
                                          '/product-details',
                                          extra: product,
                                        ),
                                    child: ProductCard(
                                      key: ValueKey(product.id),
                                      title: product.name,
                                      price: '${product.price} د.ع',
                                      discount:
                                          product.discount != 0
                                              ? '-${product.discount}%'
                                              : null,
                                      imageUrl:
                                          product.images.isNotEmpty
                                              ? product.images[0]
                                              : null,
                                      showHeart: true,
                                      isFavorite: isFav,
                                      onFavoriteToggle: () {
                                        context.read<FavoriteBloc>().add(
                                          ToggleFavorite(product.id),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      );
                    } else if (state is HomeError) {
                      return Center(child: Text(state.message));
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return BottomNavigationBar(
                selectedItemColor: primaryColor, // الرئيسية ACTIVE
                unselectedItemColor: const Color(0xFF777777),
                currentIndex: 0,
                type: BottomNavigationBarType.fixed,
                backgroundColor:
                    theme.bottomNavigationBarTheme.backgroundColor ??
                    theme.scaffoldBackgroundColor,
                onTap: (index) {
                  if (index == 2) {
                    context.push('/cart');
                  } else if (index == 3) {
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
                        badgeColor: Color(0xFF29434E), // لون الدائرة للسلة
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
}

class CategoryCircle extends StatelessWidget {
  final String label;
  const CategoryCircle({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey[800] : const Color(0xFFD9D9D9),
          ),
          child: Icon(
            Icons.image,
            color: isDark ? Colors.grey[500] : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontFamily: 'Cairo',
            color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? discount;
  final String? imageUrl;
  final bool showHeart;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.discount,
    this.imageUrl,
    this.showHeart = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey.shade300;
    final titleColor = isDark ? Colors.white : const Color(0xFF29434E);
    final priceColor = isDark ? Colors.grey[300]! : const Color(0xFF546E7A);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child:
                    imageUrl != null
                        ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.broken_image,
                                  color:
                                      isDark ? Colors.grey[500] : Colors.grey,
                                ),
                          ),
                        )
                        : Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: isDark ? Colors.grey[500] : Colors.grey,
                          ),
                        ),
              ),
              if (discount != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF29434E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      discount!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
              if (showHeart)
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite
                              ? const Color(0xFF546E7A)
                              : (isDark ? Colors.grey[600] : Colors.grey),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    color: titleColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Cairo',
                    color: priceColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

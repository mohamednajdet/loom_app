import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

import '../widgets/product_card.dart';
import '../blocs/search/search_bloc.dart';
import '../blocs/search/search_event.dart';
import '../blocs/search/search_state.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_event.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1; // التصنيفات دائماً active

  final List<String> mainCategories = [
    'نساء',
    'رجال',
    'اطفال بناتي',
    'اطفال ولادي',
  ];

  final List<String> genderValues = [
    'female', // نساء
    'male', // رجال
    'girl', // طفلة أنثى
    'boy', // طفل ذكر
  ];

  final List<List<Map<String, String>>> allSubCategories = [
    // نساء
    [
      {'title': 'ملابس داخلية', 'icon': 'assets/icons/underwear.svg'},
      {'title': 'ملابس بيت', 'icon': 'assets/icons/homewear.svg'},
      {'title': 'ملابس طلعة', 'icon': 'assets/icons/dress_icon.svg'},
      {'title': 'ملابس نوم', 'icon': 'assets/icons/women_sleep_icon.svg'},
      {'title': 'جنط', 'icon': 'assets/icons/bag.svg'},
      {'title': 'أحذية وسليبرز', 'icon': 'assets/icons/high_heel.svg'},
      {'title': 'جوارب', 'icon': 'assets/icons/socks_icon.svg'},
    ],
    // رجال
    [
      {'title': 'ملابس داخلية', 'icon': 'assets/icons/men-boxers.svg'},
      {'title': 'ملابس بيت', 'icon': 'assets/icons/homewear.svg'},
      {'title': 'ملابس طلعة', 'icon': 'assets/icons/men-casual-wear.svg'},
      {'title': 'ملابس نوم', 'icon': 'assets/icons/sleepwear_men.svg'},
      {'title': 'أحذية وسليبرز', 'icon': 'assets/icons/men_slippers.svg'},
      {'title': 'جوارب', 'icon': 'assets/icons/socks_icon.svg'},
    ],
    // طفلة أنثى
    [
      {'title': 'ملابس داخلية', 'icon': 'assets/icons/baby-diaper.svg'},
      {'title': 'ملابس بيت', 'icon': 'assets/icons/girl_homewear.svg'},
      {'title': 'ملابس طلعة', 'icon': 'assets/icons/girl_outfit.svg'},
      {'title': 'أحذية وسليبرز', 'icon': 'assets/icons/slipper_girl.svg'},
      {'title': 'جوارب', 'icon': 'assets/icons/socks_kids.svg'},
    ],
    // طفل ذكر
    [
      {'title': 'ملابس داخلية', 'icon': 'assets/icons/baby-diaper.svg'},
      {'title': 'ملابس بيت', 'icon': 'assets/icons/boy_homewear.svg'},
      {'title': 'ملابس طلعة', 'icon': 'assets/icons/boy_outfit.svg'},
      {'title': 'أحذية وسليبرز', 'icon': 'assets/icons/slipper_boy.svg'},
      {'title': 'جوارب', 'icon': 'assets/icons/socks_kids.svg'},
    ],
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<SearchBloc>().stream.listen((state) {
      if (mounted && _searchController.text.trim().isNotEmpty) {
        setState(() {});
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {});
    } else {
      context.read<SearchBloc>().add(SearchProducts(query));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_selectedIndex == index) return; // لا يعمل إذا نفس الشاشة
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        // التصنيفات - لا شي
        break;
      case 2:
        context.go('/cart');
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final primary = const Color(0xFF546E7A);
    final secondaryBg = isDark ? const Color(0xFF222D32) : const Color(0xFFF5F5F5);
    final chipSelected = isDark ? Colors.white10 : const Color(0x66546E7A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // العنوان فقط بدون سهم رجوع
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Center(
                  child: Text(
                    'التصنيفات',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: secondaryBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontFamily: 'Cairo'),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'ابحث عن منتج',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : const Color(0xFF9E9E9E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.search,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _searchController.text.trim().isEmpty
                    ? Row(
                        children: [
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.8,
                              children: allSubCategories[selectedCategoryIndex]
                                  .map((item) {
                                    return GestureDetector(
                                      onTap: () {
                                        final selectedGender = genderValues[selectedCategoryIndex];
                                        final selectedCategoryType = item['title']!;
                                        context.push(
                                          '/products',
                                          extra: {
                                            'gender': selectedGender,
                                            'categoryType': selectedCategoryType,
                                          },
                                        );
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 35,
                                            backgroundColor: isDark
                                                ? const Color(0xFF546E7A).withAlpha(220)
                                                : const Color(0xFF546E7A),
                                            child: Container(
                                              width: 38,
                                              height: 38,
                                              alignment: Alignment.center,
                                              child: SvgPicture.asset(
                                                item['icon']!,
                                                width: 38,
                                                height: 38,
                                                fit: BoxFit.contain,
                                                colorFilter: const ColorFilter.mode(
                                                  Colors.white,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item['title']!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 13,
                                              color: isDark ? Colors.grey[300] : const Color(0xFF29434E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 90,
                            child: ListView.builder(
                              itemCount: mainCategories.length,
                              itemBuilder: (context, index) {
                                final isSelected = selectedCategoryIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => selectedCategoryIndex = index);
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? chipSelected : Colors.transparent,
                                          borderRadius: const BorderRadius.horizontal(
                                            right: Radius.circular(0),
                                            left: Radius.circular(16),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            mainCategories[index],
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              color: isSelected
                                                  ? primary
                                                  : (isDark ? Colors.white : Colors.black),
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                            width: 6,
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF29434A) : const Color(0xFF29434E),
                                              borderRadius: const BorderRadius.only(
                                                bottomRight: Radius.circular(16),
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
                        ],
                      )
                    : BlocBuilder<SearchBloc, SearchState>(
                        builder: (context, state) {
                          if (state is SearchInitial) {
                            return Center(
                              child: Text(
                                'ابحث عن منتج...',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: textColor.withAlpha((0.6 * 255).toInt()),
                                ),
                              ),
                            );
                          } else if (state is SearchLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is SearchLoaded) {
                            final products = state.products;
                            if (products.isEmpty) {
                              return Center(
                                child: Text(
                                  'لا توجد منتجات مطابقة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: textColor.withAlpha((0.6 * 255).toInt()),
                                  ),
                                ),
                              );
                            }
                            final favoriteState = context.watch<FavoriteBloc>().state;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: GridView.builder(
                                itemCount: products.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.60,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  final isFav = favoriteState.favoriteProductIds.contains(product.id);

                                  // حساب الأسعار للمنتج (سعر اصلي وسعر التخفيض)
                                  final int price = product.price;
                                  final int discountedPrice = product.discountedPrice ?? price;
                                  final bool hasDiscount = product.discount > 0 && discountedPrice < price;

                                  void goToDetails() => context.push(
                                    '/product-details',
                                    extra: product,
                                  );
                                  return AspectRatio(
                                    aspectRatio: 0.60,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark ? Colors.black38 : Colors.black12,
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: goToDetails,
                                              child: ProductCard(
                                                title: product.name,
                                                price: '$discountedPrice د.ع',
                                                originalPrice: hasDiscount ? price : null,
                                                discount: hasDiscount ? '-${product.discount}%' : null,
                                                imageUrl: product.images.isNotEmpty ? product.images[0] : null,
                                                showHeart: true,
                                                isFavorite: isFav,
                                                onFavoriteToggle: () {
                                                  context.read<FavoriteBloc>().add(
                                                        ToggleFavorite(product.id),
                                                      );
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 40,
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                elevation: 4,
                                              ),
                                              onPressed: goToDetails,
                                              child: const Text(
                                                'تفاصيل المنتج',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Cairo',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else if (state is SearchError) {
                            return Center(child: Text(state.message));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
              ),
            ],
          ),
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
                  Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
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
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/delivery.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 3 ? primary : const Color(0xFF777777),
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
    );
  }
}

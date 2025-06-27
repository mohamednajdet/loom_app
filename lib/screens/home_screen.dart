import 'dart:async';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_state.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_event.dart';
import '../blocs/favorite/favorite_state.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_state.dart';
import '../helpers/notifications_helper.dart';
import '../services/api_service_dio.dart';
import '../services/firebase_messaging_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasUnread = false;
  late final StreamSubscription _notificationStream;
  int _selectedIndex = 0;
  String? selectedAddress = '';
  List<Map<String, dynamic>> savedAddresses = [];
  bool isLoadingAddresses = false;

  static const kPrimary = Color(0xFF546E7A);
  static const kRed = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _loadNotificationsBadge();
    _notificationStream = FirebaseMessagingHelper
        .notificationStreamController
        .stream
        .listen((_) => _loadNotificationsBadge());
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _notificationStream.cancel();
    super.dispose();
  }

  Future<void> _loadNotificationsBadge() async {
    final val = await NotificationsHelper.hasUnreadNotifications();
    if (mounted) setState(() => hasUnread = val);
  }

  Future<void> _openNotificationsScreen() async {
    await NotificationsHelper.markAllAsRead();
    if (!mounted) return;
    await context.push('/notifications');
    if (mounted) await _loadNotificationsBadge();
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/categories');
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

  Future<void> _loadSavedAddresses() async {
    setState(() => isLoadingAddresses = true);
    try {
      savedAddresses = await ApiServiceDio.fetchUserAddresses();
      if (selectedAddress == '' && savedAddresses.isNotEmpty) {
        selectedAddress = savedAddresses.first['label'];
      }
    } catch (e) {
      savedAddresses = [];
    }
    setState(() => isLoadingAddresses = false);
  }

  void _showAddressPicker() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF20262C) : Colors.white;
    final dividerColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    if (savedAddresses.isEmpty && !isLoadingAddresses) {
      await _loadSavedAddresses();
      if (!mounted) return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final double maxHeight = MediaQuery.of(context).size.height * 0.85;
        final double minHeight = 250;

        return Container(
          constraints: BoxConstraints(
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'اختر الموقع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: isDark ? Colors.white : const Color(0xFF29434E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // العناوين المحفوظة
                  if (isLoadingAddresses)
                    const Center(child: CircularProgressIndicator())
                  else if (savedAddresses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'لم تقم بحفظ عنوان حتى الان. هل تريد اضافة عنوان موقعك الحالي الى قائمة العناوين الخاصة بك؟',
                      ),
                    )
                  else
                    ...savedAddresses.map(
                      (item) => _AddressTile(
                        title: item['label'] ?? 'عنوان غير معروف',
                        selected: selectedAddress == item['label'],
                        accentColor: kPrimary,
                        textColor: isDark
                            ? Colors.white
                            : const Color(0xFF29434E),
                        onTap: () {
                          setState(() => selectedAddress = item['label']);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      context
                          .push('/saved_addresses')
                          .then((_) => _loadSavedAddresses());
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF20262C)
                            : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: dividerColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'العناوين المحفوظة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF29434E),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: kPrimary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/map-picker');
                      },
                      child: const Text(
                        'اختر موقعك الجغرافي',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Cairo',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgGrey = isDark ? const Color(0xFF232B32) : const Color(0xFFF1F1F1);
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
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/search'),
                      child: const Icon(
                        Icons.search,
                        color: kPrimary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _showAddressPicker,
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: bgGrey,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedAddress?.isNotEmpty == true
                                      ? selectedAddress!
                                      : 'اختر الموقع',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: kPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    BlocBuilder<FavoriteBloc, FavoriteState>(
                      builder: (context, favState) {
                        final hasFav = favState.favoriteProductIds.isNotEmpty;
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context.push('/wishlist'),
                          child: Icon(
                            hasFav ? Icons.favorite : Icons.favorite_border,
                            color: kPrimary,
                            size: 28,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _openNotificationsScreen,
                      child: badges.Badge(
                        showBadge: hasUnread,
                        badgeContent: const SizedBox(),
                        position: badges.BadgePosition.topEnd(top: -4, end: -4),
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: kRed,
                          padding: EdgeInsets.all(5),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: kPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _HomeBody(selectedAddress: selectedAddress ?? ''),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final String title;
  final bool selected;
  final Color accentColor;
  final Color textColor;
  final VoidCallback onTap;
  const _AddressTile({
    required this.title,
    required this.selected,
    required this.accentColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: accentColor, width: 2),
          color: selected ? accentColor : Colors.transparent,
        ),
        child: selected
            ? Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Cairo', color: textColor),
      ),
      trailing: selected ? Icon(Icons.location_on, color: accentColor) : null,
      onTap: onTap,
    );
  }
}

// ✅ الجزء المعدل هنا
class _HomeBody extends StatelessWidget {
  final String selectedAddress;
  const _HomeBody({required this.selectedAddress});

  @override
  Widget build(BuildContext context) {
    const kAccent = Color(0xFF29434E);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    // ✅ دالة جديدة للانتقال إلى products_screen مع الفلتر المناسب
    void goToProductsType(String type) {
      context.push('/products', extra: {'type': type});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --------- البانر التفاعلي ---------
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/discounted_products'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAccent,
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
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CategoryCircle(
              label: 'تيشيرتات',
              imageAsset: 'assets/images/tshirt.webp',
              onTap: () => goToProductsType('تيشيرت'),
            ),
            CategoryCircle(
              label: 'فساتين',
              imageAsset: 'assets/images/dress.webp',
              onTap: () => goToProductsType('فستان'),
            ),
            CategoryCircle(
              label: 'أحذية',
              imageAsset: 'assets/images/shoes.webp',
              onTap: () => goToProductsType('حذاء'),
            ),
            CategoryCircle(
              label: 'بناطير',
              imageAsset: 'assets/images/pants.webp',
              onTap: () => goToProductsType('بنطرون'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'مقترحاتنا لك',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontFamily: 'Cairo',
              color:  textColor,
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
              final products = state.products;
              return BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, favState) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                    children: products.map((product) {
                      final isFav = favState.favoriteProductIds.contains(
                        product.id,
                      );
                      final price = product.price;
                      final discountedPrice = product.discountedPrice ?? price;
                      final hasDiscount =
                          product.discount > 0 && discountedPrice < price;
                      return GestureDetector(
                        onTap: () =>
                            context.push('/product-details', extra: product),
                        child: ProductCard(
                          key: ValueKey(product.id),
                          title: product.name,
                          price: discountedPrice,
                          originalPrice: hasDiscount ? price : null,
                          discount: product.discount != 0
                              ? '-${product.discount}%'
                              : null,
                          imageUrl: product.images.isNotEmpty
                              ? product.images[0]
                              : null,
                          showHeart: true,
                          isFavorite: isFav,
                          onFavoriteToggle: () => context
                              .read<FavoriteBloc>()
                              .add(ToggleFavorite(product.id)),
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
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF546E7A);
    const kAccent = Color(0xFF29434E);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          return BottomNavigationBar(
            selectedItemColor: kPrimary,
            unselectedItemColor: const Color(0xFF777777),
            currentIndex: selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor,
            onTap: onTap,
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
                    badgeColor: kAccent,
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
                    selectedIndex == 3 ? kPrimary : const Color(0xFF777777),
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
    );
  }
}

class CategoryCircle extends StatelessWidget {
  final String label;
  final String? imageAsset;
  final VoidCallback? onTap;

  const CategoryCircle({
    super.key,
    required this.label,
    this.imageAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF29434E) : const Color(0xFF546E7A),
            ),
            child: imageAsset != null
                ? ClipOval(
                    child: Image.asset(
                      imageAsset!,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  )
                : Icon(
                    Icons.image,
                    color: isDark ? Colors.grey[500] : Colors.grey,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontFamily: 'Cairo',
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  const Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}

// نفس كود ProductCard القديم بدون تغيير
class ProductCard extends StatelessWidget {
  final String title;
  final int price;
  final int? originalPrice;
  final String? discount;
  final String? imageUrl;
  final bool showHeart;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.originalPrice,
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
                child: imageUrl != null
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
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            color: isDark ? Colors.grey[500] : Colors.grey,
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
                      color: isFavorite
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (originalPrice != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Text(
                          '$originalPrice د.ع',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    Text(
                      '$price د.ع',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: priceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

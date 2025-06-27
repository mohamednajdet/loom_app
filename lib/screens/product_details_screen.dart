import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_model.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../widgets/back_button_custom.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_event.dart';
import '../blocs/favorite/favorite_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  String? selectedSize;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      _currentPage.value = page;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = const Color(0xFF546E7A);
    final background = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = isDark ? Colors.grey[100] : const Color(0xFF29434E);

    // حساب السعر المخفض والسعر الأصلي ونسبة الخصم
    final int price = widget.product.price;
    final int discountedPrice = widget.product.discountedPrice ?? price;
    final int discount = widget.product.discount;
    final bool hasDiscount = discount > 0 && discountedPrice < price;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: BackButtonCustom(title: 'تفاصيل المنتج'),
                    ),
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        reverse: true,
                        itemCount: widget.product.images.length,
                        itemBuilder: (context, index) {
                          return KeyedSubtree(
                            key: ValueKey('${widget.product.id}-$index'),
                            child: BlocBuilder<FavoriteBloc, FavoriteState>(
                              builder: (context, favState) {
                                final isFav = favState.favoriteProductIds
                                    .contains(widget.product.id);
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Container(
                                        color: cardColor,
                                        child: Image.network(
                                          widget.product.images[index],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                                    Icons.broken_image,
                                                    color:
                                                        isDark
                                                            ? Colors.white24
                                                            : Colors.black26,
                                                  ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<FavoriteBloc>().add(
                                            ToggleFavorite(widget.product.id),
                                          );
                                        },
                                        child: Icon(
                                          isFav
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              isFav
                                                  ? primaryColor
                                                  : (isDark
                                                      ? Colors.grey[600]
                                                      : Colors.grey),
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (context, currentPage, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.product.images.length,
                            (index) {
                              final dotIndex =
                                  widget.product.images.length - index - 1;
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      currentPage == dotIndex
                                          ? primaryColor
                                          : (isDark
                                              ? Colors.grey[700]
                                              : Colors.grey[300]),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // اسم المنتج بنفس لون السعر، لكن يستجيب للثيم
                          Text(
                            widget.product.name,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'Cairo',
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // السعر والسعر المشطوب وشارة الخصم إذا يوجد خصم
                          Row(
                            children: [
                              Text(
                                '$discountedPrice د.ع',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Cairo',
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 10),
                                Text(
                                  '$price د.ع',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Cairo',
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF29434E),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-$discount%',
                                    style: const TextStyle(
                                      fontSize: 13,
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
                    const SizedBox(height: 24),
                    _buildSectionTitle('تفاصيل المنتج:', isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'هذا المنتج من ضمن تشكيلتنا الجديدة المميزة.\nالخامة عالية الجودة، ويدعم خيارات متعددة من المقاسات والألوان.',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Cairo',
                          color:
                              isDark
                                  ? Colors.grey[300]
                                  : const Color(0xFF666666),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('اختر القياس', isDark),
                    _buildSizeOptions(primaryColor, isDark),
                    const SizedBox(height: 16),
                    _buildSectionTitle('اختر اللون', isDark),
                    _buildColorOptions(primaryColor, isDark),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _addToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'أضف للسلة',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Cairo',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Cairo',
            color: isDark ? Colors.grey[200] : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOptions(Color primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        children:
            widget.product.sizes.map((size) {
              final isSelected = selectedSize == size;
              return ChoiceChip(
                label: Text(size),
                selected: isSelected,
                onSelected: (_) => setState(() => selectedSize = size),
                selectedColor: primaryColor,
                backgroundColor:
                    isDark ? Colors.grey[850] : const Color(0xFFEEEEEE),
                labelStyle: TextStyle(
                  color:
                      isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[200] : Colors.black),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildColorOptions(Color primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        children:
            widget.product.colors.map((color) {
              final isSelected = selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => selectedColor = color),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getColorFromName(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? primaryColor
                              : (isDark ? Colors.grey : Colors.grey[400]!),
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  void _addToCart() {
    if (selectedSize == null || selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار القياس واللون أولاً")),
      );
      return;
    }

    BlocProvider.of<CartBloc>(context).add(
      AddToCart(
        product: widget.product,
        selectedSize: selectedSize!,
        selectedColor: selectedColor!,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("تمت إضافة المنتج إلى السلة")));
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
        try {
          String hex = name.replaceAll('#', '').toUpperCase();
          if (hex.length == 6) hex = 'FF$hex';
          if (hex.length == 8) return Color(int.parse('0x$hex'));
        } catch (_) {}
        return const Color(0xFFCCCCCC);
    }
  }
}

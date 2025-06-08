import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_model.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/cart/cart_event.dart';
import '../widgets/back_button_custom.dart';

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
    final primaryColor = const Color(0xFF546E7A);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: BackButtonCustom(title: 'تفاصيل المنتج'),

                    ),

                    // ✅ صور المنتج
                    SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        reverse: true,
                        itemCount: widget.product.images.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            widget.product.images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ✅ مؤشرات الصور
                    ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (context, currentPage, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.product.images.length, (index) {
                            final dotIndex = widget.product.images.length - index - 1;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentPage == dotIndex
                                    ? primaryColor
                                    : Colors.grey[300],
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ✅ الاسم والسعر
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Cairo',
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.product.price} د.ع',
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Cairo',
                              color: Color(0xFF29434E),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ✅ تفاصيل المنتج
                    _buildSectionTitle('تفاصيل المنتج:'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'هذا المنتج من ضمن تشكيلتنا الجديدة المميزة.\nالخامة عالية الجودة، ويدعم خيارات متعددة من المقاسات والألوان.',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Cairo',
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('اختر القياس'),
                    _buildSizeOptions(primaryColor),

                    const SizedBox(height: 16),
                    _buildSectionTitle('اختر اللون'),
                    _buildColorOptions(primaryColor),

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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Cairo',
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeOptions(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        children: widget.product.sizes.map((size) {
          final isSelected = selectedSize == size;
          return ChoiceChip(
            label: Text(size),
            selected: isSelected,
            onSelected: (_) => setState(() => selectedSize = size),
            selectedColor: primaryColor,
            backgroundColor: const Color(0xFFEEEEEE),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorOptions(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        children: widget.product.colors.map((color) {
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
                  color: isSelected ? primaryColor : Colors.grey,
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تمت إضافة المنتج إلى السلة")),
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
        try {
          String hex = name.replaceAll('#', '').toUpperCase();
          if (hex.length == 6) hex = 'FF$hex';
          if (hex.length == 8) return Color(int.parse('0x$hex'));
        } catch (_) {}
        return const Color(0xFFCCCCCC);
    }
  }
}

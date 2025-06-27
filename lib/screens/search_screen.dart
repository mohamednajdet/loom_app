import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/back_button_custom.dart';
import '../widgets/product_card.dart';
import '../blocs/search/search_bloc.dart';
import '../blocs/search/search_event.dart';
import '../blocs/search/search_state.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_event.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const kPrimary = Color(0xFF546E7A);
  static const kAccent = Color(0xFF29434E);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldColor = theme.scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final emptyTextColor = isDark ? Colors.white60 : Colors.grey;
    final secondaryBg =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final controller = TextEditingController();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldColor,
        body: SafeArea(
          child: Column(
            children: [
              const BackButtonCustom(title: 'البحث'),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: secondaryBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 24.0,
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: 'Cairo',
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'ابحث عن منتج',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF9E9E9E),
                              fontFamily: 'Cairo',
                            ),
                          ),
                          onChanged: (query) => context.read<SearchBloc>().add(
                                SearchProducts(query),
                              ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          isScrollControlled: true,
                          backgroundColor: scaffoldColor,
                          builder: (_) => BlocProvider.value(
                            value: context.read<SearchBloc>(),
                            child: const _FilterDialog(),
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/filter.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            isDark ? Colors.white70 : Colors.grey,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return Center(
                        child: Text(
                          'ابدأ بالبحث عن المنتجات…',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            color: emptyTextColor,
                          ),
                        ),
                      );
                    } else if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SearchLoaded) {
                      final products = state.products;
                      if (products.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد منتجات مطابقة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              color: emptyTextColor,
                            ),
                          ),
                        );
                      }

                      final favoriteState = context.watch<FavoriteBloc>().state;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: GridView.builder(
                          itemCount: products.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final isFav = favoriteState.favoriteProductIds
                                .contains(product.id);

                            // منطق السعر: سعر مخفض + سعر أصلي مشطوب + شارة الخصم
                            final int price = product.price;
                            final int discountedPrice =
                                product.discountedPrice ?? price;
                            final int discount = product.discount;
                            final bool hasDiscount =
                                discount > 0 && discountedPrice < price;

                            void goToDetails() => context.push(
                                  '/product-details',
                                  extra: product,
                                );

                            return AspectRatio(
                              aspectRatio: 0.60,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black38
                                          : Colors.black12,
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
                                          originalPrice:
                                              hasDiscount ? price : null,
                                          discount:
                                              hasDiscount ? '-$discount%' : null,
                                          imageUrl: product.images.isNotEmpty
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
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 40,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                              8,
                                            ),
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
    );
  }
}

// الفلاتر كما هي (بلا تعديل)
class _FilterDialog extends StatefulWidget {
  const _FilterDialog();

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  final Set<String> selectedTypes = {};
  final Set<String> selectedGenders = {};
  final Set<String> selectedSizes = {};
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  String convertGenderToBackend(String label) {
    switch (label.trim()) {
      case 'رجالي':
        return 'male';
      case 'نسائي':
        return 'female';
      case 'اطفال بناتي':
        return 'girl';
      case 'اطفال ولادي':
        return 'boy';
      default:
        return '';
    }
  }

  String convertTypeToBackend(String label) {
    switch (label.trim()) {
      case 'تيشيرتات':
        return 'تيشيرت';
      case 'أحذية':
        return 'حذاء';
      case 'بناطيل':
      case 'بناطير':
        return 'بنطرون';
      case 'فساتين':
        return 'فستان';
      case 'تنانير':
        return 'تنورا';
      case 'رسمي':
        return 'رسمي';
      case 'كاچوال':
        return 'كاجوال';
      case 'قمصان':
        return 'قميص';
      case 'تراكات':
        return 'تراكسود';
      case 'جمسوت':
        return 'جمسوت';
      case 'برمودا':
        return 'برمودا';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFD6D6D6);
    final chipBgColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'فلترة المنتجات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Cairo',
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFilterSection(
                  'نوع المنتج',
                  [
                    'تيشيرتات',
                    'أحذية',
                    'بناطيل',
                    'فساتين',
                    'تنانير',
                    'رسمي',
                    'كاچوال',
                    'قمصان',
                    'تراكات',
                    'جمسوت',
                    'برمودا',
                  ],
                  selectedTypes,
                  chipBgColor,
                  borderColor,
                  textColor,
                ),
                const SizedBox(height: 12),
                _buildFilterSection(
                  'الجنس',
                  ['نسائي', 'رجالي', 'اطفال بناتي', 'اطفال ولادي'],
                  selectedGenders,
                  chipBgColor,
                  borderColor,
                  textColor,
                ),
                const SizedBox(height: 12),
                _buildFilterSection(
                  'المقاس',
                  ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'],
                  selectedSizes,
                  chipBgColor,
                  borderColor,
                  textColor,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'نطاق السعر',
                    style: TextStyle(fontFamily: 'Cairo', color: textColor),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPriceController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'من',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: chipBgColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxPriceController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'إلى',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: chipBgColor,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final min = minPriceController.text.trim();
                    final max = maxPriceController.text.trim();
                    context.read<SearchBloc>().add(
                          SearchProductsWithFilters(
                            query: '',
                            types: selectedTypes
                                .map(convertTypeToBackend)
                                .where((e) => e.isNotEmpty)
                                .toList(),
                            genders: selectedGenders
                                .map(convertGenderToBackend)
                                .where((e) => e.isNotEmpty)
                                .toList(),
                            sizes: selectedSizes.toList(),
                            minPrice: min.isEmpty ? null : double.tryParse(min),
                            maxPrice: max.isEmpty ? null : double.tryParse(max),
                          ),
                        );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SearchScreen.kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تطبيق الفلاتر',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    Set<String> selectedOptions,
    Color chipBg,
    Color borderColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            title,
            style: TextStyle(fontFamily: 'Cairo', color: textColor),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((label) {
            final isSelected = selectedOptions.contains(label);
            return FilterChip(
              label: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: isSelected ? Colors.white : textColor,
                ),
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedOptions.add(label);
                  } else {
                    selectedOptions.remove(label);
                  }
                });
              },
              selectedColor: SearchScreen.kPrimary,
              backgroundColor: chipBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: borderColor),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }
}

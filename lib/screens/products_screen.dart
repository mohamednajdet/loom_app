import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/back_button_custom.dart';
import '../../widgets/product_card.dart';
import '../../models/product_model.dart';
import '../../services/api_service_dio.dart';

// Bloc imports
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_state.dart';
import '../../blocs/favorite/favorite_event.dart';

class ProductsScreen extends StatefulWidget {
  final String? gender;
  final String? type;
  final String? categoryType;

  const ProductsScreen({super.key, this.gender, this.type, this.categoryType});

  static const kPrimary = Color(0xFF546E7A);
  static const kAccent = Color(0xFF29434E);
  static const kBgLight = Color(0xFFFAFAFA);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ApiServiceDio.fetchProducts(
      gender: widget.gender,
      type: widget.type,
      categoryType: widget.categoryType, // <-- دعم categoryType
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? ProductsScreen.kAccent : ProductsScreen.kBgLight;
    final emptyTextColor = isDark ? Colors.white60 : Colors.grey;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: scaffoldColor,
        body: SafeArea(
          child: Column(
            children: [
              const BackButtonCustom(title: 'كل المنتجات'),
              Expanded(
                child: FutureBuilder<List<ProductModel>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ أثناء جلب المنتجات.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    final products = snapshot.data ?? [];
                    return BlocBuilder<FavoriteBloc, FavoriteState>(
                      builder: (context, favState) {
                        if (products.isEmpty) {
                          return Center(
                            child: Text(
                              'لا توجد منتجات متوفرة حالياً.',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                color: emptyTextColor,
                              ),
                            ),
                          );
                        }
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
                              // الأسعار والحسومات
                              final int price = product.price;
                              final int discountedPrice = product.discountedPrice ?? price;
                              final int discount = product.discount;
                              final bool hasDiscount = discount > 0 && discountedPrice < price;

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
                                            originalPrice: hasDiscount ? price : null,
                                            discount: hasDiscount ? '-$discount%' : null,
                                            imageUrl: product.images.isNotEmpty
                                                ? product.images[0]
                                                : null,
                                            showHeart: true,
                                            isFavorite: favState
                                                .favoriteProductIds
                                                .contains(product.id),
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
                                            backgroundColor:
                                                ProductsScreen.kPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                      },
                    );
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/home/home_bloc.dart';
import '../blocs/home/home_state.dart';
import '../blocs/favorite/favorite_bloc.dart';
import '../blocs/favorite/favorite_event.dart';
import '../blocs/favorite/favorite_state.dart';
import '../widgets/product_card.dart';
import '../widgets/back_button_custom.dart'; // تأكد من الاستيراد
import 'package:go_router/go_router.dart';

class DiscountedProductsScreen extends StatelessWidget {
  const DiscountedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const BackButtonCustom(title: 'الخصومات'),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is HomeLoaded) {
                      final discountedProducts = state.products
                          .where((p) => p.discount > 0)
                          .toList();
                      if (discountedProducts.isEmpty) {
                        return const Center(
                          child: Text('لا توجد منتجات مخفضة حالياً'),
                        );
                      }
                      return BlocBuilder<FavoriteBloc, FavoriteState>(
                        builder: (context, favState) {
                          return GridView.count(
                            crossAxisCount: 2,
                            padding: const EdgeInsets.all(16),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                            children: discountedProducts.map((product) {
                              final isFav = favState.favoriteProductIds
                                  .contains(product.id);
                              final price = product.price;
                              final discountedPrice =
                                  product.discountedPrice ?? price;
                              final hasDiscount =
                                  product.discount > 0 &&
                                  discountedPrice < price;
                              return GestureDetector(
                                onTap: () => context.push(
                                  '/product-details',
                                  extra: product,
                                ),
                                child: ProductCard(
                                  key: ValueKey(product.id),
                                  title: product.name,
                                  price: discountedPrice.toString(), // int
                                  originalPrice: hasDiscount
                                      ? price
                                      : null, // int or null فقط
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

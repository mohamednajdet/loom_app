import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? discount;
  final String? imageUrl;
  final bool showHeart;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final Widget? childBelow; // ✅ ويدجت إضافي اختياري

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.discount,
    this.imageUrl,
    this.showHeart = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.childBelow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF29434E) : Colors.white;
    final borderColor = isDark ? Colors.black26 : Colors.grey.shade300;
    final titleColor = isDark ? Colors.white : const Color(0xFF29434E);
    final priceColor = isDark ? Colors.grey[300]! : const Color(0xFF757575);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
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
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
              ),
              if (discount != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      color: isFavorite ? const Color(0xFF546E7A) : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    color: priceColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (childBelow != null) ...[
                  const SizedBox(height: 8),
                  childBelow!,
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

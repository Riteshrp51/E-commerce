import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/app_toast.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final inCart = cartProvider.isInCart(product.id);
    final qty = cartProvider.getQuantity(product.id);

    // Deterministic dummy ratings based on product name
    final rating = 4.2 + ((product.name.hashCode.abs() % 8) / 10.0);
    final reviewCount = 18 + (product.name.hashCode.abs() % 75);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Hero(
                    tag: 'product_image_${product.id}',
                    child: Container(
                      height: 105,
                      width: double.infinity,
                      color: AppColors.getCategoryColor(product.category).withValues(alpha: 0.35),
                      child: CachedNetworkImage(
                        imageUrl: ApiConstants.resolveImageUrl(product.imageUrl),
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/${product.imageUrl.split('/').last}',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.shopping_basket_rounded,
                            size: 36,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!product.inStock)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Information below image (compact, reduced space)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category, Name, Yellow Star Reviews
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Dummy Reviews in form of stars, filled with yellow
                        Row(
                          children: [
                            ...List.generate(5, (index) => const Icon(
                              Icons.star,
                              size: 12,
                              color: Color(0xFFFFB800),
                            )),
                            const SizedBox(width: 4),
                            Text(
                              '${rating.toStringAsFixed(1)} ($reviewCount)',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Price above, Add to Cart button below (tightly spaced)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${product.effectivePrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Add to Cart Button
                        if (!product.inStock)
                          Container(
                            height: 30,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          )
                        else if (!inCart)
                          SizedBox(
                            height: 30,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                cartProvider.addToCart(product, quantity: 1);
                                AppToast.success(context, '${product.name} added to cart');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_shopping_cart_rounded, size: 13, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Add to Cart',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 30,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: AppColors.primary, width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    final willRemove = qty <= 1;
                                    cartProvider.updateQuantity(product.id, qty - 1);
                                    if (willRemove) {
                                      AppToast.info(context, '${product.name} removed from cart');
                                    }
                                  },
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                    child: Icon(Icons.remove, size: 13, color: AppColors.primary),
                                  ),
                                ),
                                Text(
                                  '$qty in cart',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    cartProvider.updateQuantity(product.id, qty + 1);
                                  },
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                    child: Icon(Icons.add, size: 13, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

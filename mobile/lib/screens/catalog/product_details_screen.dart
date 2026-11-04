import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_toast.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
import '../cart/cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedQuantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = Provider.of<CartProvider>(context);
    final inCart = cartProvider.isInCart(product.id);

    final displayImages = product.images.isNotEmpty
        ? product.images
        : [product.imageUrl];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${cartProvider.itemCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Gallery
            Container(
              height: 280,
              width: double.infinity,
              color: AppColors.getCategoryColor(product.category).withValues(alpha: 0.3),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'product_image_${product.id}',
                    child: CachedNetworkImage(
                      imageUrl: ApiConstants.resolveImageUrl(
                        displayImages[_selectedImageIndex],
                      ),
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) => Image.asset(
                        'assets/${displayImages[_selectedImageIndex].split('/').last}',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shopping_basket_outlined,
                          size: 80,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Multiple Thumbnail Variants (if available)
            if (displayImages.length > 1) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayImages.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedImageIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImageIndex = index),
                      child: Container(
                        width: 56,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: ApiConstants.resolveImageUrl(displayImages[index]),
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.image, size: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Stock Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.getCategoryColor(product.category),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.inStock
                              ? 'In Stock (${product.stock} units)'
                              : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: product.inStock ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product Title
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Reviews with Yellow Stars
                  Row(
                    children: [
                      ...List.generate(5, (index) => const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFFB800),
                      )),
                      const SizedBox(width: 6),
                      Text(
                        '${(4.2 + ((product.name.hashCode.abs() % 8) / 10.0)).toStringAsFixed(1)} (${18 + (product.name.hashCode.abs() % 75)} reviews)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '₹${product.effectivePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Divider(height: 32),

                  // Product Description
                  const Text(
                    'About this Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // DailyMart Trust Badges
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureTile(
                          icon: Icons.electric_bolt_rounded,
                          title: 'Superfast Delivery',
                          subtitle: 'Guaranteed delivery in 30 minutes',
                        ),
                        const Divider(height: 20),
                        _buildFeatureTile(
                          icon: Icons.eco_rounded,
                          title: 'Freshness Guaranteed',
                          subtitle: 'Handpicked quality straight from farms',
                        ),
                        const Divider(height: 20),
                        _buildFeatureTile(
                          icon: Icons.verified_user_outlined,
                          title: 'Safe & Hygienic',
                          subtitle: 'Contactless delivery & sanitized packaging',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90), // Bottom padding for sticky button
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Bar
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Counter (if in stock)
              if (product.inStock) ...[
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: _selectedQuantity > 1
                            ? () => setState(() => _selectedQuantity--)
                            : null,
                      ),
                      Text(
                        '$_selectedQuantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: _selectedQuantity < product.stock
                            ? () => setState(() => _selectedQuantity++)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
              ],

              // Add to Cart Button
              Expanded(
                child: CustomButton(
                  text: !product.inStock
                      ? 'Out of Stock'
                      : inCart
                          ? 'Add More to Cart'
                          : 'Add to Cart',
                  icon: Icons.shopping_basket_outlined,
                  onPressed: !product.inStock
                      ? null
                      : () async {
                          final ok = await cartProvider.addToCart(
                            product,
                            quantity: _selectedQuantity,
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            AppToast.success(
                              context,
                              'Added $_selectedQuantity x ${product.name} to cart',
                            );
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

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}


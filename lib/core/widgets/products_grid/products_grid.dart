import 'package:flutter/material.dart';
import 'package:minechat/core/widgets/product_card/product_card.dart';
import 'package:minechat/model/data/product_service_model.dart';

class ProductsGrid extends StatelessWidget {
  final List<ProductServiceModel> products;
  final Function(ProductServiceModel)? onEdit;
  final Function(ProductServiceModel)? onDelete;
  final bool isDark;

  // ✅ New optional params
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final int? crossAxisCount; // if null → auto responsive

  const ProductsGrid({
    super.key,
    required this.products,
    this.onEdit,
    this.onDelete,
    required this.isDark,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    // ✅ Responsive grid: auto count based on screen width
    final int calculatedCrossAxisCount = crossAxisCount ??
        (MediaQuery.of(context).size.width ~/ 180).clamp(2, 6);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: calculatedCrossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          isDark: isDark,
          onEdit: onEdit != null ? () => onEdit!(product) : null,
          onDelete: onDelete != null ? () => onDelete!(product) : null,
        );
      },
    );
  }
}

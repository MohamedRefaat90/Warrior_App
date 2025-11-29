import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/favorites_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorites screen showing all favorite products
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr(context)),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                // TODO: Implement sorting
              },
            ),
        ],
      ),
      body: favorites.isEmpty
          ? EmptyStateWidget(
              title: context.l10n.noFavoritesYet,
              message: context.l10n.addProductsToFavorites,
              icon: Icons.favorite_border,
            )
          : GridView.builder(
              padding: context.screenPadding,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveUtils.getGridColumns(context,
                    mobile: 2, tablet: 3, desktop: 4),
                childAspectRatio: 0.7,
                crossAxisSpacing: context.smallSpacing,
                mainAxisSpacing: context.smallSpacing,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return ProductCard(product: favorites[index].foodProduct);
              },
            ),
    );
  }
}

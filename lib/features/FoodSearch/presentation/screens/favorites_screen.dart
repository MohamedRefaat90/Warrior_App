import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/favorites_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorites screen showing all favorite products
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(sortedFavoritesProvider);
    final currentSort = ref.watch(favoritesSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr(context)),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.sortBy,
              onPressed: () => _showSortDialog(context, ref, currentSort),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? EmptyStateWidget(
              title: context.l10n.noFavoritesYet,
              message: context.l10n.addProductsToFavorites,
              icon: Icons.favorite_border,
            )
          : RefreshIndicator(
              onRefresh: () async {
                // Reload favorites from local storage
                ref.invalidate(favoritesProvider);
              },
              child: GridView.builder(
                padding: context.screenPadding,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtils.getGridColumns(context,
                      mobile: 2, tablet: 3, desktop: 4),
                  childAspectRatio: 0.83,
                  crossAxisSpacing: context.smallSpacing,
                  mainAxisSpacing: context.smallSpacing,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final favorite = favorites[index];
                  return Dismissible(
                    key: Key(favorite.foodProduct.barcode),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: context.mediumSpacing),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(
                            context.responsiveBorderRadius),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.l10n.removeFromFavorites),
                          content: Text(
                            context.l10n.confirmRemoveFavorite(
                              favorite.foodProduct.productName ??
                                  context.l10n.unknownProduct,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(context.l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              child: Text(context.l10n.remove),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      ref
                          .read(favoritesProvider.notifier)
                          .removeFavorite(favorite.foodProduct.barcode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.l10n.removedFromFavorites(
                              favorite.foodProduct.productName ??
                                  context.l10n.unknownProduct,
                            ),
                          ),
                          action: SnackBarAction(
                            label: context.l10n.undo,
                            onPressed: () {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .addFavorite(favorite.foodProduct);
                            },
                          ),
                        ),
                      );
                    },
                    child: ProductCard(product: favorite.foodProduct),
                  );
                },
              ),
            ),
    );
  }

  void _showSortDialog(
    BuildContext context,
    WidgetRef ref,
    FavoritesSortOption currentSort,
  ) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(context.mediumSpacing),
              child: Text(
                context.l10n.sortBy,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            _SortOptionTile(
              title: context.l10n.dateNewest,
              icon: Icons.arrow_downward,
              isSelected: currentSort == FavoritesSortOption.dateNewest,
              onTap: () {
                ref
                    .read(favoritesSortProvider.notifier)
                    .setSortOption(FavoritesSortOption.dateNewest);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: context.l10n.dateOldest,
              icon: Icons.arrow_upward,
              isSelected: currentSort == FavoritesSortOption.dateOldest,
              onTap: () {
                ref
                    .read(favoritesSortProvider.notifier)
                    .setSortOption(FavoritesSortOption.dateOldest);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: context.l10n.nameAZ,
              icon: Icons.sort_by_alpha,
              isSelected: currentSort == FavoritesSortOption.nameAsc,
              onTap: () {
                ref
                    .read(favoritesSortProvider.notifier)
                    .setSortOption(FavoritesSortOption.nameAsc);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: context.l10n.nameZA,
              icon: Icons.sort_by_alpha,
              isSelected: currentSort == FavoritesSortOption.nameDesc,
              onTap: () {
                ref
                    .read(favoritesSortProvider.notifier)
                    .setSortOption(FavoritesSortOption.nameDesc);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: context.l10n.brandAZ,
              icon: Icons.business,
              isSelected: currentSort == FavoritesSortOption.brandAsc,
              onTap: () {
                ref
                    .read(favoritesSortProvider.notifier)
                    .setSortOption(FavoritesSortOption.brandAsc);
                Navigator.pop(context);
              },
            ),
            _SortOptionTile(
              title: context.l10n.brandZA,
              icon: Icons.business,
              isSelected: currentSort == FavoritesSortOption.brandDesc,
              onTap: () {
                ref
                    .read(favoritesSortProvider.notifier)
                    .setSortOption(FavoritesSortOption.brandDesc);
                Navigator.pop(context);
              },
            ),
            SizedBox(height: context.mediumSpacing),
          ],
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check) : null,
      selected: isSelected,
      onTap: onTap,
    );
  }
}

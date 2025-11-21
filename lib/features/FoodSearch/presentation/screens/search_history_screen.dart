import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';
import 'package:Warrior/features/FoodSearch/data/repo/food_search_repo.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/search_history_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Search history screen
class SearchHistoryScreen extends ConsumerStatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  ConsumerState<SearchHistoryScreen> createState() =>
      _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends ConsumerState<SearchHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('searchHistory'.tr(context)),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('clearHistory'.tr(context)),
                    content: const Text(
                        'Are you sure you want to clear all search history?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('cancel'.tr(context)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('clear'.tr(context)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref.read(searchHistoryProvider.notifier).clearHistory();
                }
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? const EmptyStateWidget(
              title: 'No Search History',
              message: 'Your search history will appear here',
              icon: Icons.history,
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  leading: Icon(
                    item.searchType.name == 'barcode'
                        ? Icons.qr_code
                        : Icons.search,
                  ),
                  title: Text(item.searchQuery),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(item.timestamp)} • ${item.resultCount} results',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _handleHistoryItemTap(context, ref, item),
                );
              },
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Refresh history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchHistoryProvider.notifier).refresh();
    });
  }

  Future<void> _handleHistoryItemTap(
    BuildContext context,
    WidgetRef ref,
    SearchHistoryModel item,
  ) async {
    final repo = ref.read(foodSearchRepoProvider);

    if (item.searchType == SearchType.barcode) {
      // For barcode searches, try to get from cache first
      final cachedProduct = repo.getProductFromCache(item.searchQuery);

      if (cachedProduct != null) {
        // Product found in cache, navigate directly to details
        context.pushNamed(
          AppRouters.productDetails,
          extra: cachedProduct,
        );
      } else {
        // Product not in cache, search again
        try {
          final product = await repo.searchProductByBarcode(item.searchQuery);
          if (!context.mounted) return;

          if (product != null) {
            context.pushNamed(
              AppRouters.productDetails,
              extra: product,
            );
          } else {
            Flushbar(
              message: 'Product not found. It may have been removed.',
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ).show(context);
          }
        } catch (e) {
          if (!context.mounted) return;
          Flushbar(
            message: 'Error loading product: ${e.toString()}',
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ).show(context);
        }
      }
    } else {
      // For text/category/brand searches, navigate to advanced search with pre-filled query
      // The advanced search will automatically search (including cache) when opened
      context.pushNamed(
        AppRouters.advancedSearch,
        extra: {'query': item.searchQuery},
      );
    }
  }
}

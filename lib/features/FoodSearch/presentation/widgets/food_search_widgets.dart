import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Allergen chip widget
class AllergenChip extends StatelessWidget {
  final String allergen;

  const AllergenChip({super.key, required this.allergen});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(Icons.warning_amber_rounded,
          size: ResponsiveUtils.iconSize(context,
              mobile: 16, tablet: 18, desktop: 20),
          color: Colors.white),
      label: Text(
        allergen,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
      ),
      backgroundColor: Colors.red[700],
      padding: EdgeInsets.symmetric(
        horizontal: context.smallSpacing / 2,
        vertical: 2,
      ),
    );
  }
}

/// Eco-Score widget with leaf icon
class EcoscoreWidget extends StatelessWidget {
  final String? ecoscore;
  final double size;

  const EcoscoreWidget({super.key, required this.ecoscore, this.size = 40});

  @override
  Widget build(BuildContext context) {
    if (ecoscore == null || ecoscore!.isEmpty) {
      return const SizedBox.shrink();
    }

    final score = ecoscore! == 'UNKNOWN' || ecoscore! == 'NOT-APPLICABLE'
        ? "N/A"
        : ecoscore!.toUpperCase();
    final color = _getEcoscoreColor(score);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          score,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Color _getEcoscoreColor(String score) {
    switch (score) {
      case 'A':
        return const Color(0xFF038141);
      case 'B':
        return const Color(0xFF85BB2F);
      case 'C':
        return const Color(0xFFFECC02);
      case 'D':
        return const Color(0xFFEE8100);
      case 'E':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.extraLargeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.iconSize(context,
                  mobile: 80, tablet: 100, desktop: 120),
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            SizedBox(height: context.mediumSpacing),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.smallSpacing),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: context.largeSpacing),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, color: AppColors.white),
                label: Text(actionLabel!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.extraLargeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.iconSize(context,
                  mobile: 80, tablet: 100, desktop: 120),
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: context.mediumSpacing),
            Text(
              context.l10n.oopsSomethingWentWrong,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.smallSpacing),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: context.largeSpacing),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr(context)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading grid with skeleton shimmer for product lists.
///
/// Displays a responsive grid of skeleton loaders while data is loading.
class LoadingProductGrid extends StatelessWidget {
  /// The number of skeleton items to display.
  final int itemCount;

  /// Creates a [LoadingProductGrid] with the specified [itemCount].
  const LoadingProductGrid({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: context.screenPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridColumns(
          context,
          mobile: 2,
          tablet: 3,
          desktop: 4,
        ),
        crossAxisSpacing: context.smallSpacing,
        mainAxisSpacing: context.smallSpacing,
        childAspectRatio: 0.7,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const LoadingProductShimmer(),
    );
  }
}

/// Loading shimmer for product card
class LoadingProductShimmer extends StatelessWidget {
  const LoadingProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Card(
        child: Padding(
          padding: context.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                color: Colors.grey[300],
              ),
              SizedBox(height: context.smallSpacing),
              Container(
                height: 16,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              SizedBox(height: context.smallSpacing / 2),
              Container(
                height: 14,
                width: 100,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nutrition progress bar
class NutritionProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final String unit;

  const NutritionProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final color = _getColorForValue(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        SizedBox(height: context.smallSpacing / 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getColorForValue(double percentage) {
    if (percentage < 0.33) {
      return Colors.green;
    } else if (percentage < 0.66) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

/// Product image widget with error handling
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Icon(
          Icons.fastfood,
          size: width * 0.4,
          color: Colors.grey[400],
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      alignment: Alignment.center,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Icon(
          Icons.broken_image,
          size: width * 0.4,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

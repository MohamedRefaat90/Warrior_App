import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/repo/food_search_repo.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/nutrition_facts_bottom_sheet.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Product form screen for adding/editing products in Open Food Facts
class ProductFormScreen extends ConsumerStatefulWidget {
  final FoodProductModel? product;
  final String? barcode;

  const ProductFormScreen({
    super.key,
    this.product,
    this.barcode,
  });

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _brandsController = TextEditingController();
  final _quantityController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _countriesController = TextEditingController();

  bool _isLoading = false;
  String? _selectedImagePath;
  NutritionFacts? _scannedNutrition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null
            ? context.l10n.editProduct
            : context.l10n.addNewProduct),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.contributionMessage,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Barcode field
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: context.l10n.barcodeRequired,
                  hintText: context.l10n.enterProductBarcode,
                  prefixIcon: const Icon(Icons.qr_code),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: widget.product == null && widget.barcode == null,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.barcodeIsRequired;
                  }
                  if (value.trim().length < 8) {
                    return context.l10n.barcodeMinDigits;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product name field
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: context.l10n.productNameRequired,
                  hintText: context.l10n.enterProductName,
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.productNameIsRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Brands field
              TextFormField(
                controller: _brandsController,
                decoration: InputDecoration(
                  labelText: context.l10n.brand,
                  hintText: context.l10n.enterBrandName,
                  prefixIcon: const Icon(Icons.business),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Quantity field
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: context.l10n.quantity,
                  hintText: context.l10n.quantityExample,
                  prefixIcon: const Icon(Icons.scale),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Serving size field
              TextFormField(
                controller: _servingSizeController,
                decoration: InputDecoration(
                  labelText: context.l10n.servingSize,
                  hintText: context.l10n.servingSizeExample,
                  prefixIcon: const Icon(Icons.restaurant),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Ingredients field
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  labelText: context.l10n.ingredients,
                  hintText: context.l10n.ingredientsHint,
                  prefixIcon: const Icon(Icons.list),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Countries field
              TextFormField(
                controller: _countriesController,
                decoration: InputDecoration(
                  labelText: context.l10n.countries,
                  hintText: context.l10n.countriesHint,
                  prefixIcon: const Icon(Icons.public),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // Nutrition Facts section with OCR scanner
              NutritionFactsBottomSheet(
                initialFacts: _scannedNutrition,
                onChanged: (facts) {
                  setState(() {
                    _scannedNutrition = facts;
                  });
                },
                onScanPressed: _scanNutritionLabel,
              ),
              const SizedBox(height: 24),

              // Image picker section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.productImage,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_selectedImagePath != null) ...[
                        Text(
                          '${context.l10n.imageSelected}: ${_selectedImagePath!.split('/').last}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: context.smallSpacing),
                      ],
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_selectedImagePath != null
                            ? context.l10n.changeImage
                            : context.l10n.takePhoto),
                      ),
                      SizedBox(height: context.smallSpacing),
                      Text(
                        context.l10n.imageTip,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.extraLargeSpacing),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: context.mediumSpacing),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.product != null
                            ? context.l10n.updateProduct
                            : context.l10n.addProduct,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
              ),
              SizedBox(height: context.mediumSpacing),

              // Disclaimer
              Text(
                context.l10n.openFoodFactsDisclaimer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _productNameController.dispose();
    _brandsController.dispose();
    _quantityController.dispose();
    _ingredientsController.dispose();
    _servingSizeController.dispose();
    _countriesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.product != null) {
      _barcodeController.text = widget.product!.barcode;
      _productNameController.text = widget.product!.productName ?? '';
      _brandsController.text = widget.product!.brands ?? '';
      _quantityController.text = widget.product!.quantity ?? '';
      _ingredientsController.text = widget.product!.ingredients ?? '';
      _servingSizeController.text = widget.product!.servingSize ?? '';
      _countriesController.text = widget.product!.countries ?? '';
    } else if (widget.barcode != null) {
      _barcodeController.text = widget.barcode!;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<NutritionFacts?> _scanNutritionLabel() async {
    // Just navigate to scanner - provider handles the result
    await context.push(AppRouters.ocrScanner);
    return null; // Result comes via provider, not navigation
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create Product object
      final product = Product(
        barcode: _barcodeController.text.trim(),
        productName: _productNameController.text.trim(),
        brands: _brandsController.text.trim(),
        quantity: _quantityController.text.trim(),
        ingredientsText: _ingredientsController.text.trim(),
        servingSize: _servingSizeController.text.trim(),
        countries: _countriesController.text.trim(),
      );

      // Create user credentials for Open Food Facts
      // Note: In production, you should use proper authentication
      final user = User(
        userId: 'warrior-app-user',
        password: 'warrior-app-2024',
        comment: 'Contributed via Warrior App',
      );

      final repo = ref.read(foodSearchRepoProvider);
      bool success;

      if (widget.product != null) {
        // Update existing product
        success = await repo.updateProduct(product, user);
      } else {
        // Add new product
        success = await repo.addNewProduct(product, user);
      }

      if (!mounted) return;

      if (success) {
        Flushbar(
          message: widget.product != null
              ? context.l10n.productUpdatedSuccessfully
              : context.l10n.productAddedSuccessfully,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        ).show(context);

        // Go back after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        Flushbar(
          message: widget.product != null
              ? context.l10n.failedToUpdateProduct
              : context.l10n.failedToAddProduct,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error, color: Colors.white),
        ).show(context);
      }
    } catch (e) {
      if (!mounted) return;
      Flushbar(
        message: 'Error: ${e.toString()}',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error, color: Colors.white),
      ).show(context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

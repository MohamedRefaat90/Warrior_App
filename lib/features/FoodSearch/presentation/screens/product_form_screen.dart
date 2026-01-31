import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/off_credentials_service.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/nutrition_facts_bottom_sheet.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_form/product_form_widgets.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Product form screen for adding/editing products in Open Food Facts.
class ProductFormScreen extends ConsumerStatefulWidget {
  final ProductEntity? product;
  final String? barcode;

  const ProductFormScreen({
    super.key,
    this.product,
    this.barcode,
  });

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.openFoodFactsDisclaimer,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
      textAlign: TextAlign.center,
    );
  }
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
              const ProductFormInfoCard(),
              const SizedBox(height: 24),

              // Basic fields (barcode, name, brand, quantity)
              ProductBasicFields(
                barcodeController: _barcodeController,
                productNameController: _productNameController,
                brandsController: _brandsController,
                quantityController: _quantityController,
                isBarcodeEditable:
                    widget.product == null && widget.barcode == null,
              ),
              const SizedBox(height: 16),

              // Details fields (serving size, ingredients, countries)
              ProductDetailsFields(
                servingSizeController: _servingSizeController,
                ingredientsController: _ingredientsController,
                countriesController: _countriesController,
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
              ProductImagePicker(
                selectedImagePath: _selectedImagePath,
                onImageChanged: (path) {
                  setState(() {
                    _selectedImagePath = path;
                  });
                },
              ),
              SizedBox(height: context.extraLargeSpacing),

              // Submit button
              _SubmitButton(
                isLoading: _isLoading,
                isEditing: widget.product != null,
                onPressed: _submitForm,
              ),
              SizedBox(height: context.mediumSpacing),

              // Disclaimer
              _Disclaimer(),
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
      _scannedNutrition = widget.product!.nutrition;
    } else if (widget.barcode != null) {
      _barcodeController.text = widget.barcode!;
    }
  }

  Future<NutritionFacts?> _scanNutritionLabel() async {
    await context.push(AppRouters.ocrScanner);
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = ProductEntity(
        barcode: _barcodeController.text.trim(),
        productName: _productNameController.text.trim(),
        brands: _brandsController.text.trim(),
        quantity: _quantityController.text.trim(),
        ingredients: _ingredientsController.text.trim(),
        servingSize: _servingSizeController.text.trim(),
        countries: _countriesController.text.trim(),
        nutrition: _scannedNutrition,
        lastUpdated: DateTime.now(),
      );

      // Get credentials from secure storage
      // final user = await OpenFoodFactsCredentialsService.getUser();
      final user = await OpenFoodFactsCredentialsService.getUser();

      final repo = ref.read(productWriteRepositoryProvider);
      final success = await repo.submitProduct(
        product: product,
        user: user,
        isUpdate: widget.product != null,
      );

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
      TalkerService.error("Error: ${e.toString()}");
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

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isEditing;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.isEditing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: context.mediumSpacing),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              isEditing ? context.l10n.updateProduct : context.l10n.addProduct,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
    );
  }
}

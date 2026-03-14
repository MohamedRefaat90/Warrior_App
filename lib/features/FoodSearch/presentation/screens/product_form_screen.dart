import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/off_credentials_service.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/barcode_validator.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/brand_validator.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/product_name_validator.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/quantity_validator.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/ocr_scanner_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/product_form_provider.dart';
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

  const ProductFormScreen({super.key, this.product, this.barcode});

  @visibleForTesting
  static bool showNotifications = true;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.openFoodFactsDisclaimer,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        textAlign: TextAlign.center);
  }
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _brandsController = TextEditingController();
  final _quantityController = TextEditingController();
  // final _ingredientsController = TextEditingController();
  // final _servingSizeController = TextEditingController();
  // final _countriesController = TextEditingController();

  bool _isLoading = false;

  // Validation error tracking
  final Map<String, String?> _validationErrors = {
    'barcode': null,
    'productName': null,
    'brand': null,
    'quantity': null,
  };

  bool get _hasValidationErrors {
    return _validationErrors.values.any((error) => error != null);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormProvider);

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
                validationErrors: _validationErrors,
              ),
              const SizedBox(height: 16),

              // Details fields (serving size, ingredients, countries)
              // ProductDetailsFields(
              //   servingSizeController: _servingSizeController,
              //   ingredientsController: _ingredientsController,
              //   countriesController: _countriesController,
              // ),
              // const SizedBox(height: 24),

              // Nutrition Facts section with OCR scanner
              NutritionFactsBottomSheet(
                initialFacts: formState.nutrition,
                onChanged: (facts) {
                  ref.read(productFormProvider.notifier).updateNutrition(facts);
                },
                onScanPressed: () async {
                  // Mark that we're about to scan - this flag will be checked in initState
                  // if the widget rebuilds while we're away
                  ref.read(productFormProvider.notifier).setScanning(true);

                  // Navigate to scanner
                  await context.push(AppRouters.ocrScanner);

                  // Note: We DON'T set isScanning to false here!
                  // The _initializeFormState method will handle state restoration
                  // and reset the flag when it detects we've returned from scanning
                },
              ),
              const SizedBox(height: 24),

              // Image picker section
              ProductImagePicker(
                onImageChanged: (path) {
                  ref.read(productFormProvider.notifier).updateImage(path);
                },
              ),
              SizedBox(height: context.extraLargeSpacing),

              // Submit button
              _SubmitButton(
                isLoading: _isLoading,
                isEditing: widget.product != null,
                hasValidationErrors: _hasValidationErrors,
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
    // _ingredientsController.dispose();
    // _servingSizeController.dispose();
    // _countriesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _initializeFormState();
  }

  void _initializeFormState() {
    Future.microtask(() {
      if (!mounted) return;

      final provider = ref.read(productFormProvider);
      final notifier = ref.read(productFormProvider.notifier);

      if (provider.isScanning) {
        // Returning from OCR - Restore state
        TalkerService.info('Restoring form state from OCR session', 'FORM');

        // Check for newly scanned data
        final ocrState = ref.read(ocrScannerProvider);
        if (ocrState is OcrScanSuccess) {
          TalkerService.info('Applying OCR results to form', 'FORM');
          notifier.updateNutrition(ocrState.facts);
          // Optional: Clear OCR state so we don't re-apply it if we navigate back again without scanning
          ref.read(ocrScannerProvider.notifier).reset();
        }

        notifier.setScanning(false);

        // IMPORTANT: Re-read the state AFTER all updates to get current values
        final currentState = ref.read(productFormProvider);
        _populateControllersFromState(currentState);
      } else {
        // New session - Reset and Initialize
        TalkerService.info('Initializing new form session', 'FORM');
        notifier.initialize(product: widget.product, barcode: widget.barcode);
        _populateControllersFromState(ref.read(productFormProvider));
      }
    });
  }

  void _populateControllersFromState(ProductFormState state) {
    _barcodeController.text = state.barcode;
    _productNameController.text = state.productName;
    _brandsController.text = state.brands;
    _quantityController.text = state.quantity;
    // _servingSizeController.text = state.servingSize;
    // _countriesController.text = state.countries;
  }

  void _setupControllers() {
    _barcodeController.addListener(() {
      ref
          .read(productFormProvider.notifier)
          .updateField(barcode: _barcodeController.text);
      _validateBarcode();
      // TalkerService.debug(
      //     'Barcode changed to ${_barcodeController.text}', 'FORM');
    });
    _productNameController.addListener(() {
      ref
          .read(productFormProvider.notifier)
          .updateField(productName: _productNameController.text);
      _validateProductName();
    });
    _brandsController.addListener(() {
      ref
          .read(productFormProvider.notifier)
          .updateField(brands: _brandsController.text);
      _validateBrand();
    });
    _quantityController.addListener(() {
      ref
          .read(productFormProvider.notifier)
          .updateField(quantity: _quantityController.text);
      _validateQuantity();
    });
    // _ingredientsController.addListener(() {
    //   ref
    //       .read(productFormProvider.notifier)
    //       .updateField(ingredients: _ingredientsController.text);
    // });
    // _servingSizeController.addListener(() {
    //   ref
    //       .read(productFormProvider.notifier)
    //       .updateField(servingSize: _servingSizeController.text);
    // });
    // _countriesController.addListener(() {
    //   ref
    //       .read(productFormProvider.notifier)
    //       .updateField(countries: _countriesController.text);
    // });
  }

  Future<void> _submitForm() async {
    // Run validation
    _validateBarcode();
    _validateProductName();
    _validateBrand();
    _validateQuantity();

    // Check if there are any validation errors
    if (_hasValidationErrors) {
      Flushbar(
        message: context.l10n.validationErrorsFixRequired,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.warning, color: Colors.white),
      ).show(context);
      return;
    }

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
        // ingredients: _ingredientsController.text.trim(),
        // servingSize: _servingSizeController.text.trim(),
        // countries: _countriesController.text.trim(),
        nutrition: ref.read(productFormProvider).nutrition,
        lastUpdated: DateTime.now(),
      );

      // Get credentials from secure storage
      // final user = await OpenFoodFactsCredentialsService.getUser();
      final user = await OpenFoodFactsCredentialsService.getUser();

      final repo = ref.read(productWriteRepositoryProvider);
      final success = await repo.submitProduct(
        product: product,
        user: user,
        imagePath: ref.read(productFormProvider).imagePath,
      );

      if (!mounted) return;

      if (success) {
        if (!context.mounted) return;

        if (ProductFormScreen.showNotifications) {
          Flushbar(
            message: widget.product != null
                ? context.l10n.productUpdatedSuccessfully
                : context.l10n.productAddedSuccessfully,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          ).show(context);

          // Show additional notification if offline
          if (ConnectivityChecker.isOnline != true) {
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              Flushbar(
                message: context.l10n.savedToOfflineQueue,
                duration: const Duration(seconds: 4),
                backgroundColor: Colors.blue,
                icon: const Icon(Icons.cloud_queue, color: Colors.white),
              ).show(context);
            }
          }

          await Future.delayed(const Duration(seconds: 1));
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (ProductFormScreen.showNotifications) {
          Flushbar(
            message: widget.product != null
                ? context.l10n.failedToUpdateProduct
                : context.l10n.failedToAddProduct,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            icon: const Icon(Icons.error, color: Colors.white),
          ).show(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      TalkerService.error("Error: ${e.toString()}");
      if (ProductFormScreen.showNotifications) {
        Flushbar(
          message: 'Error: ${e.toString()}',
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error, color: Colors.white),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _validateBarcode() {
    final result = BarcodeValidator.validate(_barcodeController.text);
    setState(() {
      _validationErrors['barcode'] =
          result.isValid ? null : result.fieldErrors['barcode'];
    });
  }

  void _validateBrand() {
    final result = BrandValidator.validate(_brandsController.text);
    setState(() {
      _validationErrors['brand'] =
          result.isValid ? null : result.fieldErrors['brand'];
    });
  }

  void _validateProductName() {
    final result = ProductNameValidator.validate(_productNameController.text);
    setState(() {
      _validationErrors['productName'] =
          result.isValid ? null : result.fieldErrors['productName'];
    });
  }

  void _validateQuantity() {
    final result = QuantityValidator.validate(_quantityController.text);
    setState(() {
      _validationErrors['quantity'] =
          result.isValid ? null : result.fieldErrors['quantity'];
    });
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isEditing;
  final bool hasValidationErrors;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.isEditing,
    required this.hasValidationErrors,
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

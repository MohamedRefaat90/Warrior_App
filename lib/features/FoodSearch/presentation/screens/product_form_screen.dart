import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/repo/food_search_repo.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.product != null ? 'Edit Product' : 'Add New Product'),
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
                          'Your contribution will help millions of users worldwide make better food choices!',
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
                decoration: const InputDecoration(
                  labelText: 'Barcode *',
                  hintText: 'Enter product barcode',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: widget.product == null && widget.barcode == null,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Barcode is required';
                  }
                  if (value.trim().length < 8) {
                    return 'Barcode must be at least 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product name field
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'Enter product name',
                  prefixIcon: Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Brands field
              TextFormField(
                controller: _brandsController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  hintText: 'Enter brand name',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Quantity field
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g., 500g, 1L, 250ml',
                  prefixIcon: Icon(Icons.scale),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Serving size field
              TextFormField(
                controller: _servingSizeController,
                decoration: const InputDecoration(
                  labelText: 'Serving Size',
                  hintText: 'e.g., 30g, 100ml',
                  prefixIcon: Icon(Icons.restaurant),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Ingredients field
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients',
                  hintText: 'List all ingredients separated by commas',
                  prefixIcon: Icon(Icons.list),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Countries field
              TextFormField(
                controller: _countriesController,
                decoration: const InputDecoration(
                  labelText: 'Countries',
                  hintText: 'Where is this product sold?',
                  prefixIcon: Icon(Icons.public),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
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
                        'Product Image',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_selectedImagePath != null) ...[
                        Text(
                          'Image selected: ${_selectedImagePath!.split('/').last}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                      ],
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_selectedImagePath != null
                            ? 'Change Image'
                            : 'Take Photo'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tip: Take a clear photo of the product front, ingredients list, and nutrition facts.',
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
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.product != null
                            ? 'Update Product'
                            : 'Add Product',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 16),

              // Disclaimer
              Text(
                '* Required fields\n\nBy submitting, you agree to contribute this information to the Open Food Facts database under the Open Database License.',
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
              ? 'Product updated successfully!'
              : 'Product added successfully!',
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
          message:
              'Failed to ${widget.product != null ? 'update' : 'add'} product. Please try again.',
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

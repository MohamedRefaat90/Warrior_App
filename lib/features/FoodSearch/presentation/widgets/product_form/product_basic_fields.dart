import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:flutter/material.dart';

/// Basic product information fields (barcode, name, brand, quantity).
class ProductBasicFields extends StatelessWidget {
  final TextEditingController barcodeController;
  final TextEditingController productNameController;
  final TextEditingController brandsController;
  final TextEditingController quantityController;
  final bool isBarcodeEditable;
  final Map<String, String?> validationErrors;

  const ProductBasicFields({
    super.key,
    required this.barcodeController,
    required this.productNameController,
    required this.brandsController,
    required this.quantityController,
    this.isBarcodeEditable = true,
    this.validationErrors = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barcode field
        TextFormField(
          controller: barcodeController,
          decoration: InputDecoration(
            labelText: context.l10n.barcodeRequired,
            hintText: context.l10n.enterProductBarcode,
            prefixIcon: const Icon(Icons.qr_code),
            border: const OutlineInputBorder(),
            errorText: validationErrors['barcode'],
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          keyboardType: TextInputType.number,
          enabled: isBarcodeEditable,
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
          controller: productNameController,
          decoration: InputDecoration(
            labelText: context.l10n.productNameRequired,
            hintText: context.l10n.enterProductName,
            prefixIcon: const Icon(Icons.shopping_bag),
            border: const OutlineInputBorder(),
            errorText: validationErrors['productName'],
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
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
          controller: brandsController,
          decoration: InputDecoration(
            labelText: context.l10n.brand,
            hintText: context.l10n.enterBrandName,
            prefixIcon: const Icon(Icons.business),
            border: const OutlineInputBorder(),
            errorText: validationErrors['brand'],
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),

        // Quantity field
        TextFormField(
          controller: quantityController,
          decoration: InputDecoration(
            labelText: context.l10n.quantity,
            hintText: context.l10n.quantityExample,
            prefixIcon: const Icon(Icons.scale),
            border: const OutlineInputBorder(),
            errorText: validationErrors['quantity'],
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

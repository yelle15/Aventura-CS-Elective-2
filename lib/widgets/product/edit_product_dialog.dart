import 'package:flutter/material.dart';

import '../../models/product.dart';

class ProductChanges {
  const ProductChanges({required this.name, required this.price});

  final String name;
  final double price;
}

Future<ProductChanges?> showEditProductDialog(
  BuildContext context,
  Product product,
) {
  return showDialog<ProductChanges>(
    context: context,
    builder: (_) => _EditProductDialog(product: product),
  );
}

class _EditProductDialog extends StatefulWidget {
  const _EditProductDialog({required this.product});

  final Product product;

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(
        widget.product.price == widget.product.price.roundToDouble() ? 0 : 2,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ProductChanges(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.replaceAll(',', '').trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit product'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a product name'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '₱ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onFieldSubmitted: (_) => _save(),
                validator: (value) {
                  final price = double.tryParse(
                    (value ?? '').replaceAll(',', '').trim(),
                  );
                  if (price == null) return 'Enter a valid price';
                  if (price < 0) return 'Price cannot be negative';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

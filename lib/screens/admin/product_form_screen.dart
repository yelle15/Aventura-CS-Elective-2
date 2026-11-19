import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product.dart';
import '../../models/product_category.dart';
import '../../providers/product_providers.dart';
import '../../widgets/product_image.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/state_views.dart';

class ProductFormScreen extends ConsumerWidget {
  const ProductFormScreen({super.key, this.productId});

  final int? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = productId;
    final categories = ref.watch(categoriesProvider);
    final isEditing = id != null;

    Widget body;
    if (categories.hasError) {
      body = ErrorView(
        error: categories.error!,
        onRetry: () => ref.invalidate(categoriesProvider),
      );
    } else if (!categories.hasValue) {
      body = const LoadingView();
    } else if (!isEditing) {
      body = _ProductForm(categories: categories.value!);
    } else {
      body = ref.watch(productByIdProvider(id)).when(
            loading: () => const LoadingView(),
            error: (error, _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(productByIdProvider(id)),
            ),
            data: (product) => product == null
                ? MessageView(
                    icon: Icons.search_off_rounded,
                    title: 'Product not found',
                    message: 'It may have been deleted.',
                    actionLabel: 'Back to products',
                    onAction: () => context.go('/admin/products'),
                  )
                : _ProductForm(
                    key: ValueKey(product.id),
                    categories: categories.value!,
                    product: product,
                  ),
          );
    }

    return Scaffold(
      appBar: RiffsAppBar(
        title: isEditing ? 'Edit Product' : 'Add Product',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  const _ProductForm({super.key, required this.categories, this.product});

  final List<ProductCategory> categories;
  final Product? product;

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  int? _categoryId;
  Uint8List? _pickedBytes;
  String? _pickedName;
  String? _pickedType;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    _price = TextEditingController(
      text: product == null ? '' : _formatNumber(product.price),
    );
    _stock = TextEditingController(text: product?.stock.toString() ?? '');
    final categoryIds = widget.categories.map((c) => c.id).toSet();
    _categoryId = product != null && categoryIds.contains(product.categoryId)
        ? product.categoryId
        : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  static String _formatNumber(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1400,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedBytes = bytes;
        _pickedName = file.name;
        _pickedType = file.mimeType ?? _guessType(file.name);
      });
    } catch (error) {
      if (mounted) {
        showMessage(context, 'Could not open that image.', isError: true);
      }
    }
  }

  static String _guessType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final actions = ref.read(catalogActionsProvider);
    try {
      var imageUrl = widget.product?.imageUrl;
      final bytes = _pickedBytes;
      if (bytes != null) {
        imageUrl = await actions.uploadImage(
          bytes: bytes,
          fileName: _pickedName ?? 'product.jpg',
          contentType: _pickedType,
        );
      }
      final input = ProductInput(
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: double.parse(_price.text.replaceAll(',', '').trim()),
        stock: int.parse(_stock.text.trim()),
        categoryId: _categoryId!,
        imageUrl: imageUrl,
      );
      final saved = await actions.saveProduct(
        input,
        productId: widget.product?.id,
      );
      if (!mounted) return;
      showMessage(
        context,
        _isEditing ? 'Saved changes to ${saved.name}.' : 'Added ${saved.name}.',
      );
      context.go('/admin/products');
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessage(context, error.toString(), isError: true);
    }
  }

  String? _validateName(String? value) =>
      (value ?? '').trim().isEmpty ? 'A product name is required' : null;

  String? _validatePrice(String? value) {
    final text = (value ?? '').replaceAll(',', '').trim();
    if (text.isEmpty) return 'Enter a price';
    final price = double.tryParse(text);
    if (price == null) return 'Price must be a number';
    if (price < 0) return 'Price cannot be negative';
    return null;
  }

  String? _validateStock(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Enter the stock quantity';
    final stock = int.tryParse(text);
    if (stock == null) return 'Stock must be a whole number';
    if (stock < 0) return 'Stock cannot be negative';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final picked = _pickedBytes;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: ClipRect(
              child: picked != null
                  ? Image.memory(picked, fit: BoxFit.contain)
                  : ProductImage(url: widget.product?.imageUrl, iconSize: 72),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _saving ? null : _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: Text(
                picked != null || widget.product?.imageUrl != null
                    ? 'Change image'
                    : 'Choose image',
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _description,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Price *',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validatePrice,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock *',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateStock,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            initialValue: _categoryId,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final category in widget.categories)
                DropdownMenuItem(value: category.id, child: Text(category.name)),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _categoryId = value),
            validator: (value) => value == null ? 'Choose a category' : null,
          ),
          if (widget.categories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Create a category first in the Categories tab.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save changes' : 'Add product'),
            ),
          ),
        ],
      ),
    );
  }
}

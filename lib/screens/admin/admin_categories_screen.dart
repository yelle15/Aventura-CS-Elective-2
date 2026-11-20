import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_exception.dart';
import '../../models/product_category.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/state_views.dart';

class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    ProductCategory? category,
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(initialName: category?.name),
    );
    if (name == null || !context.mounted) return;
    final actions = ref.read(catalogActionsProvider);
    try {
      if (category == null) {
        await actions.createCategory(name);
        if (context.mounted) showMessage(context, 'Added $name.');
      } else {
        await actions.renameCategory(category.id, name);
        if (context.mounted) showMessage(context, 'Renamed to $name.');
      }
    } catch (error) {
      if (context.mounted) {
        showMessage(context, error.toString(), isError: true);
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ProductCategory category,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete category?',
      message: 'Delete "${category.name}"? '
          'Categories that still have products cannot be deleted.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(catalogActionsProvider).deleteCategory(category.id);
      if (context.mounted) showMessage(context, 'Deleted ${category.name}.');
    } catch (error) {
      if (!context.mounted) return;
      final message = error is InUseException
          ? '${category.name} still has products. '
              'Move them to another category or delete them first.'
          : error.toString();
      showMessage(context, message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: const RiffsAppBar(title: 'Categories'),
      bottomNavigationBar: const AdminNavigation(selectedIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add category'),
      ),
      body: categories.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (items) => items.isEmpty
            ? const MessageView(
                icon: Icons.category_outlined,
                title: 'No categories yet',
                message: 'Add one so products can be grouped.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final category = items[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.red.withAlpha(30),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.label_outline_rounded,
                              color: AppTheme.red,
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Rename ${category.name}',
                                onPressed: () =>
                                    _edit(context, ref, category: category),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Delete ${category.name}',
                                onPressed: () =>
                                    _delete(context, ref, category),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.initialName});

  final String? initialName;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName ?? '');

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'Add category' : 'Rename category'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category name'),
          onFieldSubmitted: (_) => _submit(),
          validator: (value) =>
              (value ?? '').trim().isEmpty ? 'Enter a name' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}

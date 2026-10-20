import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/nickname_provider.dart';
import '../providers/selected_pokemon_provider.dart';

Future<void> showNicknameEditor(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const NicknameEditorDialog(),
  );
}

class NicknameEditorDialog extends ConsumerStatefulWidget {
  const NicknameEditorDialog({super.key});

  @override
  ConsumerState<NicknameEditorDialog> createState() =>
      _NicknameEditorDialogState();
}

class _NicknameEditorDialogState extends ConsumerState<NicknameEditorDialog> {
  late final Pokemon _pokemon;
  late final String? _currentNickname;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _pokemon = ref.read(selectedPokemonProvider)!;
    _currentNickname = ref.read(nicknameProvider)[_pokemon.id];
    _controller = TextEditingController(text: _currentNickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(nicknameProvider.notifier).setNickname(_pokemon.id, _controller.text);
    Navigator.pop(context);
  }

  void _remove() {
    ref.read(nicknameProvider.notifier).removeNickname(_pokemon.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasNickname = _currentNickname != null;

    return AlertDialog(
      title: Text(
        hasNickname
            ? 'Edit nickname'
            : 'Give ${_pokemon.displayName} a nickname',
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: NicknameNotifier.maxLength,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          labelText: 'Nickname',
          hintText: 'e.g. Sparky',
          helperText: 'Original name: ${_pokemon.displayName}',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        if (hasNickname)
          TextButton.icon(
            onPressed: _remove,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Remove'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _save,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

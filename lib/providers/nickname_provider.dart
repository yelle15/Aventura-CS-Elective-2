import 'package:flutter_riverpod/flutter_riverpod.dart';

class NicknameNotifier extends Notifier<Map<int, String>> {
  static const int maxLength = 20;

  @override
  Map<int, String> build() => const {};

  void setNickname(int pokemonId, String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      removeNickname(pokemonId);
      return;
    }
    state = {...state, pokemonId: trimmed};
  }

  void removeNickname(int pokemonId) {
    if (!state.containsKey(pokemonId)) return;
    state = Map.of(state)..remove(pokemonId);
  }
}

final nicknameProvider = NotifierProvider<NicknameNotifier, Map<int, String>>(
  NicknameNotifier.new,
);

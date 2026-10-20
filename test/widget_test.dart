import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:my_flutter_application/models/pokemon.dart';
import 'package:my_flutter_application/providers/favorites_provider.dart';
import 'package:my_flutter_application/providers/filter_provider.dart';
import 'package:my_flutter_application/providers/nickname_provider.dart';
import 'package:my_flutter_application/providers/pokemon_list_provider.dart';
import 'package:my_flutter_application/providers/selected_pokemon_provider.dart';
import 'package:my_flutter_application/providers/service_provider.dart';
import 'package:my_flutter_application/screens/pokedex_grid_screen.dart';
import 'package:my_flutter_application/screens/pokemon_detail_screen.dart';
import 'package:my_flutter_application/services/pokemon_service.dart';
import 'package:my_flutter_application/widgets/state_views.dart';

MockClient listClient(int count) {
  return MockClient((request) async {
    if (request.url.path.endsWith('/pokemon')) {
      final results = List.generate(
        count,
        (i) => {
          'name': i == 0 ? 'bulbasaur' : 'pokemon${i + 1}',
          'url': 'https://pokeapi.co/api/v2/pokemon/${i + 1}/',
        },
      );
      return http.Response(jsonEncode({'results': results}), 200);
    }
    return http.Response('Not found', 404);
  });
}

ProviderContainer makeContainer(MockClient client) {
  final container = ProviderContainer(
    overrides: [
      pokemonServiceProvider.overrideWithValue(PokemonService(client: client)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> waitUntilLoaded(ProviderContainer container) async {
  for (var i = 0; i < 100; i++) {
    if (!container.read(pokemonListProvider).isLoading) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('Pokémon list never finished loading');
}

const bulbasaur = Pokemon(
  id: 1,
  name: 'bulbasaur',
  imageUrl: 'https://example.com/1.png',
);

void main() {
  group('Pokemon.fromJson', () {
    test('reads the ID from the URL and builds the image URL', () {
      final pokemon = Pokemon.fromJson({
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
      });

      expect(pokemon.id, 1);
      expect(pokemon.displayName, 'Bulbasaur');
      expect(pokemon.formattedId, '#001');
      expect(pokemon.imageUrl, endsWith('/official-artwork/1.png'));
    });
  });

  group('PokemonService', () {
    test('turns an HTTP error into a PokemonServiceException', () async {
      final client = MockClient((_) async => http.Response('oops', 500));

      await expectLater(
        PokemonService(client: client).fetchPokemon(),
        throwsA(isA<PokemonServiceException>()),
      );
    });
  });

  group('PokemonListNotifier', () {
    test('starts loading, then fetches on its own', () async {
      final container = makeContainer(listClient(3));

      expect(container.read(pokemonListProvider).status, PokedexStatus.loading);
      await waitUntilLoaded(container);

      final state = container.read(pokemonListProvider);
      expect(state.status, PokedexStatus.success);
      expect(state.pokemon, hasLength(3));
    });

    test('goes to the error state with a message', () async {
      final container = makeContainer(
        MockClient((_) async => http.Response('oops', 500)),
      );

      container.read(pokemonListProvider);
      await waitUntilLoaded(container);

      final state = container.read(pokemonListProvider);
      expect(state.status, PokedexStatus.error);
      expect(state.errorMessage, contains('500'));
    });

    test('refresh calls the same fetchPokemon method', () async {
      final container = makeContainer(listClient(3));
      container.read(pokemonListProvider);
      await waitUntilLoaded(container);

      final refresh = container
          .read(pokemonListProvider.notifier)
          .fetchPokemon(showLoading: false);
      expect(container.read(pokemonListProvider).isRefreshing, isTrue);
      await refresh;
      expect(container.read(pokemonListProvider).isRefreshing, isFalse);
      expect(container.read(pokemonListProvider).pokemon, hasLength(3));
    });
  });

  group('NicknameNotifier', () {
    test('adds, edits and removes a nickname', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final nicknames = container.read(nicknameProvider.notifier);

      nicknames.setNickname(1, '  Bulby ');
      expect(container.read(nicknameProvider)[1], 'Bulby');

      nicknames.setNickname(1, 'Leafy');
      expect(container.read(nicknameProvider)[1], 'Leafy');

      nicknames.removeNickname(1);
      expect(container.read(nicknameProvider).containsKey(1), isFalse);
    });
  });

  group('FavoritesNotifier', () {
    test('toggles a Pokémon in and out of favorites', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final favorites = container.read(favoritesProvider.notifier);

      favorites.toggleFavorite(bulbasaur);
      expect(container.read(favoritesProvider).keys, [1]);

      favorites.toggleFavorite(bulbasaur);
      expect(container.read(favoritesProvider), isEmpty);
    });

    test('the panel expands and collapses', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(favoritesPanelExpandedProvider), isFalse);
      container.read(favoritesPanelExpandedProvider.notifier).toggle();
      expect(container.read(favoritesPanelExpandedProvider), isTrue);
    });
  });

  group('FilterNotifier', () {
    test('selects and clears a type', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final filter = container.read(filterProvider.notifier);

      filter.selectType('fire');
      expect(container.read(filterProvider).type, 'fire');

      filter.clearType();
      expect(container.read(filterProvider).type, isNull);
    });
  });

  group('PokedexGridScreen', () {
    Future<ProviderContainer> pumpScreen(
      WidgetTester tester,
      MockClient client,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pokemonServiceProvider
                .overrideWithValue(PokemonService(client: client)),
          ],
          child: const MaterialApp(home: PokedexGridScreen()),
        ),
      );
      return ProviderScope.containerOf(
        tester.element(find.byType(PokedexGridScreen)),
        listen: false,
      );
    }

    testWidgets('shows loading, then the empty state', (tester) async {
      await pumpScreen(
        tester,
        MockClient((_) async => http.Response(jsonEncode({'results': []}), 200)),
      );
      expect(find.byType(LoadingView), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(EmptyView), findsOneWidget);
    });

    testWidgets('shows the error state with a retry button', (tester) async {
      await pumpScreen(
        tester,
        MockClient((_) async => http.Response('Server error', 500)),
      );

      await tester.pumpAndSettle();
      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('favorites panel shows a message when empty', (tester) async {
      await pumpScreen(tester, listClient(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byTooltip('Show favorites'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('No favorites yet'), findsOneWidget);
    });

    testWidgets('tapping a card selects it and opens the detail screen',
        (tester) async {
      final container = await pumpScreen(tester, listClient(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(GridView), findsOneWidget);

      await tester.tap(find.text('Bulbasaur'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(container.read(selectedPokemonProvider)?.id, 1);
      expect(find.byType(PokemonDetailScreen), findsOneWidget);
      expect(find.text('#001'), findsOneWidget);
    });
  });
}

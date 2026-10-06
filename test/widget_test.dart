import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:my_flutter_application/models/pokemon.dart';
import 'package:my_flutter_application/providers/pokedex_provider.dart';
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
    test('asks for 30 Pokémon and parses them', () async {
      late Uri requested;
      final client = MockClient((request) async {
        requested = request.url;
        final results = List.generate(
          30,
          (i) => {
            'name': 'pokemon${i + 1}',
            'url': 'https://pokeapi.co/api/v2/pokemon/${i + 1}/',
          },
        );
        return http.Response(jsonEncode({'results': results}), 200);
      });

      final pokemon =
          await PokemonService(client: client).fetchPokemon(limit: 30);

      expect(requested.queryParameters['limit'], '30');
      expect(pokemon, hasLength(30));
      expect(pokemon.last.id, 30);
    });

    test('turns an HTTP error into a PokemonServiceException', () async {
      final client = MockClient((_) async => http.Response('oops', 500));

      await expectLater(
        PokemonService(client: client).fetchPokemon(),
        throwsA(isA<PokemonServiceException>()),
      );
    });
  });

  group('PokedexProvider', () {
    test('goes from loading to success', () async {
      final provider = PokedexProvider(service: PokemonService(client: listClient(3)));
      expect(provider.status, PokedexStatus.loading);

      final future = provider.fetchPokemon();
      expect(provider.status, PokedexStatus.loading);
      await future;

      expect(provider.status, PokedexStatus.success);
      expect(provider.pokemon, hasLength(3));
      expect(provider.errorMessage, isNull);
      provider.dispose();
    });

    test('goes to the error state with a message', () async {
      final provider = PokedexProvider(
        service: PokemonService(
          client: MockClient((_) async => http.Response('oops', 500)),
        ),
      );

      await provider.fetchPokemon();

      expect(provider.status, PokedexStatus.error);
      expect(provider.errorMessage, contains('500'));
      provider.dispose();
    });

    test('pull-to-refresh keeps the grid (no loading state)', () async {
      final provider = PokedexProvider(service: PokemonService(client: listClient(3)));
      await provider.fetchPokemon();

      final future = provider.fetchPokemon(showLoading: false);
      expect(provider.status, PokedexStatus.success);
      expect(provider.isRefreshing, isTrue);
      await future;
      expect(provider.isRefreshing, isFalse);
      provider.dispose();
    });

    test('selectPokemon stores the selection and notifies', () async {
      final provider = PokedexProvider(service: PokemonService(client: listClient(3)));
      await provider.fetchPokemon();
      var notified = 0;
      provider.addListener(() => notified++);

      provider.selectPokemon(provider.pokemon[1]);

      expect(provider.selectedPokemon?.id, 2);
      expect(notified, 1);
      provider.dispose();
    });
  });

  group('PokedexGridScreen', () {
    Future<PokedexProvider> pumpScreen(
      WidgetTester tester,
      MockClient client,
    ) async {
      late PokedexProvider provider;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => provider =
              PokedexProvider(service: PokemonService(client: client))
                ..fetchPokemon(),
          child: const MaterialApp(home: PokedexGridScreen()),
        ),
      );
      return provider;
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

    testWidgets('tapping a card selects it and opens the detail screen',
        (tester) async {
      final provider = await pumpScreen(tester, listClient(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(GridView), findsOneWidget);

      await tester.tap(find.text('Bulbasaur'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(provider.selectedPokemon?.id, 1);
      expect(find.byType(PokemonDetailScreen), findsOneWidget);
      expect(find.text('#001'), findsOneWidget);
    });
  });
}

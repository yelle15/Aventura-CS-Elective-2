import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:my_flutter_application/models/pokemon.dart';
import 'package:my_flutter_application/screens/pokedex_screen.dart';
import 'package:my_flutter_application/services/pokemon_service.dart';
import 'package:my_flutter_application/widgets/state_views.dart';

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

  group('PokedexScreen', () {
    Future<void> pumpScreen(WidgetTester tester, MockClient client) {
      return tester.pumpWidget(
        MaterialApp(
          home: PokedexScreen(service: PokemonService(client: client)),
        ),
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

    testWidgets('shows the error state when the request fails', (tester) async {
      await pumpScreen(
        tester,
        MockClient((_) async => http.Response('Server error', 500)),
      );

      await tester.pumpAndSettle();
      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}

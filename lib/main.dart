import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/pokedex_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/pokedex_grid_screen.dart';
import 'services/pokemon_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key, this.service});

  final PokemonService? service;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PokedexProvider(service: service)..fetchPokemon(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const _PokedexMaterialApp(),
    );
  }
}

class _PokedexMaterialApp extends StatelessWidget {
  const _PokedexMaterialApp();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;

    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const PokedexGridScreen(),
    );
  }
}

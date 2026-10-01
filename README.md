# Pokédex List (Dart Async Activity)

Fetches the first 30 Pokémon from the [PokéAPI](https://pokeapi.co/api/v2/pokemon)
and shows them in a scrollable grid (ID, image, name).

## Folder structure

```
lib/
├── main.dart                     # App entry point
├── models/
│   ├── pokemon.dart              # Pokemon model + fromJson
│   ├── pokemon_details.dart      # HP, stats, attacks, abilities, evolution...
│   └── pokemon_filter.dart       # Search + filter state and matching
├── services/
│   └── pokemon_service.dart      # PokéAPI call (returns a Future)
├── screens/
│   └── pokedex_screen.dart       # Page with the FutureBuilder
└── widgets/
    ├── card_palette.dart         # Card colors, type colors, energy icons
    ├── pokemon_card.dart         # One grid tile, styled like a TCG card
    ├── filter_sheet.dart         # Bottom sheet with extra filters
    ├── pokemon_grid.dart         # Scrollable grid
    ├── search_filter_bar.dart    # Search field + type chips
    └── state_views.dart          # Loading / error / empty views
```

## Run

```
flutter pub get
flutter run
flutter test
```

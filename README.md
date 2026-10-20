# Pokédex (Midterm Exam – Riverpod)

Fetches the first 30 Pokémon from the [PokéAPI](https://pokeapi.co/api/v2/pokemon)
and shows them in a scrollable grid. State is managed with
[Riverpod](https://riverpod.dev) (`flutter_riverpod`).

## Features

1. **Pokémon list management** – `PokemonListNotifier.fetchPokemon()` loads the
   list when the app starts. The App Bar refresh button and pull-to-refresh
   call the same method again. The home page shows loading, error (with retry)
   and empty states.
2. **Nickname editor** – on the detail screen, add, edit or remove a nickname.
   The nickname shows on the card and the detail screen next to the original name.
3. **Favorites** – add/remove favorites; the floating heart button (bottom
   right) slides the favorites panel up from the bottom on every screen.
4. **Favorite indicator** – every card has a heart that shows and toggles the
   favorite status.
5. **Type filter** – type chips filter by each Pokémon's real types from the
   API; "All types" clears the filter.

## Folder structure

```
lib/
├── main.dart                          # ProviderScope + MaterialApp
├── models/                            # Pokemon, PokemonDetails, PokemonFilter
├── services/pokemon_service.dart      # PokéAPI calls
├── providers/
│   ├── service_provider.dart          # PokemonService
│   ├── pokemon_list_provider.dart     # list + loading/success/error
│   ├── pokemon_details_provider.dart  # types, stats, attacks per Pokémon
│   ├── nickname_provider.dart         # nicknames (Map<id, nickname>)
│   ├── favorites_provider.dart        # favorites + panel expanded/collapsed
│   ├── filter_provider.dart           # search/type filter + filtered list
│   ├── selected_pokemon_provider.dart # Pokémon shown on the detail screen
│   └── theme_provider.dart            # light/dark mode
├── screens/
│   ├── pokedex_grid_screen.dart       # home page
│   └── pokemon_detail_screen.dart     # detail page
└── widgets/
    ├── app_bar_actions.dart           # theme button
    ├── favorite_heart.dart            # heart toggle
    ├── favorites_panel.dart           # favorites button + slide-up panel
    ├── nickname_editor.dart           # nickname dialog
    ├── pokemon_card.dart, pokemon_grid.dart, search_filter_bar.dart,
    ├── filter_sheet.dart, card_palette.dart, state_views.dart
```

## Run

```
flutter pub get
flutter run
flutter test
```

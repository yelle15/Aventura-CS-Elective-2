import 'pokemon.dart';

class PokemonDetails {
  const PokemonDetails({
    required this.hp,
    required this.types,
    required this.stage,
    required this.genus,
    required this.heightM,
    required this.weightKg,
    required this.colorName,
    required this.flavorText,
    required this.attacks,
    required this.abilities,
    required this.stats,
    required this.habitat,
    required this.generation,
    required this.isLegendary,
    required this.isMythical,
    required this.evolutionStages,
    this.weakness,
    this.resistance,
  });

  final int hp;
  final List<String> types;
  final String stage;
  final String genus;
  final double heightM;
  final double weightKg;
  final String colorName;
  final String flavorText;
  final List<PokemonAttack> attacks;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;
  final String? habitat;
  final int generation;
  final bool isLegendary;
  final bool isMythical;
  final List<List<String>> evolutionStages;
  final String? weakness;
  final String? resistance;

  String get mainType => types.first;

  String get generationLabel => generationLabelFor(generation);

  static String generationLabelFor(int generation) {
    const roman = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];
    return generation >= 1 && generation <= roman.length
        ? 'Gen ${roman[generation - 1]}'
        : 'Gen $generation';
  }
}

class PokemonAttack {
  const PokemonAttack({
    required this.name,
    required this.type,
    required this.power,
    required this.effect,
  });

  final String name;
  final String type;
  final int? power;
  final String effect;

  int get energyCost {
    final p = power;
    if (p == null || p <= 40) return 1;
    if (p <= 80) return 2;
    return 3;
  }

  String get displayName => prettify(name);
}

class PokemonAbility {
  const PokemonAbility({required this.name, required this.isHidden});

  final String name;
  final bool isHidden;

  String get displayName => prettify(name);
}

class PokemonStat {
  const PokemonStat({required this.name, required this.value});

  final String name;
  final int value;

  String get shortLabel => switch (name) {
        'hp' => 'HP',
        'attack' => 'ATK',
        'defense' => 'DEF',
        'special-attack' => 'SP.ATK',
        'special-defense' => 'SP.DEF',
        'speed' => 'SPD',
        _ => prettify(name),
      };
}

class TypeMatchups {
  const TypeMatchups({this.weakness, this.resistance});

  final String? weakness;
  final String? resistance;
}

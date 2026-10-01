import 'package:flutter/material.dart';

class CardPalette {
  CardPalette._();

  static const Color border = Color(0xFF2E3742);
  static const Color ink = Color(0xFF1D2733);
  static const Color silver = Color(0xFFE4E7EC);
  static const Color loading = Color(0xFFD9DDE3);

  static const Map<String, Color> _speciesColors = {
    'yellow': Color(0xFFF6D44A),
    'red': Color(0xFFEE7B5E),
    'blue': Color(0xFF7FB2E8),
    'green': Color(0xFF8CCB7E),
    'brown': Color(0xFFC79A6E),
    'purple': Color(0xFFB48FD6),
    'pink': Color(0xFFF2A9C8),
    'gray': Color(0xFFB4B8C2),
    'white': Color(0xFFE9EBEF),
    'black': Color(0xFF6E7380),
  };

  static Color forSpecies(String? colorName) =>
      _speciesColors[colorName] ?? loading;

  static const Map<String, Color> _typeColors = {
    'normal': Color(0xFFA8A77A),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'electric': Color(0xFFF7C514),
    'grass': Color(0xFF7AC74C),
    'ice': Color(0xFF6ACFD0),
    'fighting': Color(0xFFC22E28),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFD5AE4D),
    'flying': Color(0xFFA98FF3),
    'psychic': Color(0xFFF95587),
    'bug': Color(0xFFA6B91A),
    'rock': Color(0xFFB6A136),
    'ghost': Color(0xFF735797),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'steel': Color(0xFFB7B7CE),
    'fairy': Color(0xFFD685AD),
    'colorless': Color(0xFFC9CDD4),
  };

  static const List<String> types = [
    'normal', 'fire', 'water', 'electric', 'grass', 'ice',
    'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
  ];

  static Color forType(String type) => _typeColors[type] ?? Colors.grey;

  static const Map<String, IconData> _typeIcons = {
    'normal': Icons.star_rounded,
    'fire': Icons.local_fire_department_rounded,
    'water': Icons.water_drop_rounded,
    'electric': Icons.bolt_rounded,
    'grass': Icons.eco_rounded,
    'ice': Icons.ac_unit_rounded,
    'fighting': Icons.sports_mma_rounded,
    'poison': Icons.science_rounded,
    'ground': Icons.terrain_rounded,
    'flying': Icons.air_rounded,
    'psychic': Icons.visibility_rounded,
    'bug': Icons.bug_report_rounded,
    'rock': Icons.landscape_rounded,
    'ghost': Icons.nightlight_round,
    'dragon': Icons.whatshot_rounded,
    'dark': Icons.dark_mode_rounded,
    'steel': Icons.shield_rounded,
    'fairy': Icons.auto_awesome_rounded,
    'colorless': Icons.star_rounded,
  };

  static IconData iconFor(String type) =>
      _typeIcons[type] ?? Icons.circle_outlined;
}

class EnergyIcon extends StatelessWidget {
  const EnergyIcon({super.key, required this.type, this.size = 16});

  final String type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CardPalette.forType(type),
        border: Border.all(color: Colors.white, width: size * 0.08),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Icon(CardPalette.iconFor(type), size: size * 0.62, color: type == 'colorless' ? CardPalette.ink : Colors.white),
    );
  }
}

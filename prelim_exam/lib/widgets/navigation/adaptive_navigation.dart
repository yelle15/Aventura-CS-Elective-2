import 'package:flutter/material.dart';

class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    super.key,
    required this.body,
    required this.destinations,
  });

  final Widget body;
  final List<NavigationRailDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) return body;
        return Row(
          children: [
            NavigationRail(selectedIndex: 0, destinations: destinations),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'design/design.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = switch (location) {
      final String p when p.startsWith('/favorites') => 1,
      final String p when p.startsWith('/settings') => 2,
      _ => 0,
    };
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) =>
            context.go(['/', '/favorites', '/settings'][value]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed),
            label: 'Flux',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}

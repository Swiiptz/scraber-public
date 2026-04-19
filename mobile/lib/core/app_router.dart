import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/detail/detail_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/feed/feed_screen.dart';
import '../features/settings/settings_screen.dart';
import 'shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const FeedScreen()),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/items/:id',
        builder: (context, state) =>
            DetailScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
});

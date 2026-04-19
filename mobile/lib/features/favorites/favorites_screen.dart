import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../models/cyber_item.dart';
import '../../services/favorites_service.dart';
import '../../services/item_repository.dart';
import '../feed/item_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final favorites = ref.watch(favoriteIdsProvider).valueOrNull ?? const {};
    final feedAsync = ref.watch(itemsStreamProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: feedAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Favoris indisponibles.\n$error',
              style: AppText.body(palette.inkSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          data: (items) {
            final pinned =
                items.where((item) => favorites.contains(item.id)).toList();
            return _FavoritesBody(pinned: pinned);
          },
        ),
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody({required this.pinned});

  final List<CyberItem> pinned;

  @override
  Widget build(BuildContext context) {
    final count = pinned.length;
    final edition = count == 0
        ? 'AUCUNE PIÈCE'
        : '$count PIÈCE${count > 1 ? "S" : ""} ÉPINGLÉE${count > 1 ? "S" : ""}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditionHeader(
          edition: 'SCRABER · $edition',
          trailing: 'SUIVI RAPPROCHÉ',
          title: 'Favoris',
        ),
        Expanded(
          child: count == 0
              ? const _EmptyFavorites()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                  itemCount: pinned.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      ItemCard(item: pinned[index]),
                ),
        ),
      ],
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 56, color: palette.inkTertiary),
          const SizedBox(height: 24),
          Text(
            'COLLECTION VIDE',
            style: AppText.monoLabel(palette.inkTertiary),
          ),
          const SizedBox(height: 14),
          Text(
            'Aucune pièce épinglée',
            style: AppText.slab24(palette.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Touchez l\'étoile sur un item du flux pour le conserver ici et en assurer le suivi.',
            style: AppText.bodySmall(palette.inkSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          const Colophon(),
        ],
      ),
    );
  }
}

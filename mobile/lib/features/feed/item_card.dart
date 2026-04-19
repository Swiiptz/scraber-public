import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../../models/cyber_item.dart';
import '../../services/favorites_service.dart';
import '../../utils/date_format.dart';

class ItemCard extends ConsumerWidget {
  const ItemCard({required this.item, super.key});

  final CyberItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final favorites = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
    final isFavorite = favorites.contains(item.id);
    final sourceName = item.primarySource?.name ?? '';

    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(AppDims.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDims.radiusMd),
        onTap: () => context.push('/items/${item.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDims.radiusMd),
            border: Border.all(color: palette.border, width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopRow(
                editionNumber: item.editionNumber,
                level: item.level,
                type: item.type,
                isFavorite: isFavorite,
                onToggleFavorite: () =>
                    ref.read(favoritesServiceProvider).toggle(item.id),
              ),
              const SizedBox(height: 9),
              Text(item.title, style: AppText.slab17(palette.ink)),
              if (item.primaryCve != null) ...[
                const SizedBox(height: 9),
                _CveLine(cve: item.primaryCve!, cvss: item.cvss),
              ],
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 9),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    for (final tag in item.tags.take(4)) TagChip(tag),
                  ],
                ),
              ],
              const SizedBox(height: 11),
              const Filet(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sourceName.toUpperCase(),
                      style: AppText.monoLabel(palette.ink),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    relativeDateFr(item.date),
                    style: AppText.monoEdition(palette.inkSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.editionNumber,
    required this.level,
    required this.type,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final int? editionNumber;
  final String level;
  final String type;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Row(
      children: [
        EditionNumber(editionNumber, color: palette.inkTertiary),
        const SizedBox(width: 8),
        const VerticalTick(),
        const SizedBox(width: 8),
        LevelPill(level, dense: true),
        const SizedBox(width: 6),
        TypePill(type),
        const Spacer(),
        InkResponse(
          onTap: onToggleFavorite,
          radius: 18,
          child: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            size: 18,
            color: isFavorite ? palette.accent : palette.inkTertiary,
          ),
        ),
      ],
    );
  }
}

class _CveLine extends StatelessWidget {
  const _CveLine({required this.cve, required this.cvss});

  final String cve;
  final double? cvss;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Row(
      children: [
        Text(cve, style: AppText.monoData(palette.inkSecondary)),
        if (cvss != null) ...[
          const SizedBox(width: 10),
          Text('·', style: AppText.monoData(palette.inkTertiary)),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              style: AppText.monoData(palette.inkSecondary),
              children: [
                const TextSpan(text: 'CVSS '),
                TextSpan(
                  text: cvss!.toStringAsFixed(1),
                  style: AppText.monoData(palette.ink).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

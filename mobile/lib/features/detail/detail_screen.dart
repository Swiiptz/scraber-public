import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design/design.dart';
import '../../models/cyber_item.dart';
import '../../services/favorites_service.dart';
import '../../services/item_repository.dart';
import '../../utils/content_format.dart';

final itemDetailProvider = FutureProvider.family<CyberItem, String>((ref, id) {
  return ref.watch(itemRepositoryProvider).fetchItem(id);
});

class DetailScreen extends ConsumerWidget {
  const DetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final itemAsync = ref.watch(itemDetailProvider(id));
    final favorites = ref.watch(favoriteIdsProvider).valueOrNull ?? {};
    final isFavorite = favorites.contains(id);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: itemAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Détail indisponible.\n$error',
                style: AppText.body(palette.inkSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (item) => _DetailView(
            item: item,
            isFavorite: isFavorite,
            onToggleFavorite: () =>
                ref.read(favoritesServiceProvider).toggle(id),
          ),
        ),
      ),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final CyberItem item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final cleanSummary = sanitizeMarkdown(item.summary);
    // Pour la section « Détails » on rend le markdown natif (titres, blocs de
    // code, listes…). Le sanitizer reste utilisé uniquement pour comparer avec
    // le summary et éviter de ré-afficher deux fois le même paragraphe.
    // Le content en base a été aplati par le scraper (plus de `\n`) : on
    // réinjecte la structure markdown avant de le passer au renderer.
    final richContent = expandFlattenedMarkdown(item.content.trim());
    final cleanContentForCompare = sanitizeMarkdown(richContent);
    final showContent = richContent.isNotEmpty &&
        !isContentRedundantWithSummary(cleanSummary, cleanContentForCompare);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(
          isFavorite: isFavorite,
          onToggleFavorite: onToggleFavorite,
          onShare: item.primarySource == null
              ? null
              : () => launchUrl(
                    Uri.parse(item.primarySource!.url),
                    mode: LaunchMode.externalApplication,
                  ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
            children: [
              _EditionBar(item: item),
              const SizedBox(height: 14),
              Row(
                children: [
                  LevelPill(item.level),
                  const SizedBox(width: 6),
                  TypePill(item.type),
                ],
              ),
              const SizedBox(height: 14),
              Text(item.title, style: AppText.slab26(palette.ink)),
              if (cleanSummary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  cleanSummary,
                  style: AppText.body(palette.inkSecondary).copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
              if (_hasMeta(item)) ...[
                const SizedBox(height: 22),
                _MetaGrid(item: item),
              ],
              if (showContent) ...[
                const SizedBox(height: 22),
                const SectionHeader('Détails'),
                const SizedBox(height: 4),
                _ContentMarkdown(raw: richContent, palette: palette),
              ],
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 18),
                const SectionHeader('Tags'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [for (final tag in item.tags) TagChip(tag)],
                ),
              ],
              if (item.sources.isNotEmpty) ...[
                const SizedBox(height: 18),
                const SectionHeader('Sources'),
                const SizedBox(height: 4),
                _SourcesCard(sources: item.sources),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _hasMeta(CyberItem item) {
    return item.primaryCve != null ||
        item.cvss != null ||
        item.vendor != null ||
        item.product != null ||
        item.exploited;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShare,
  });

  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: palette.ink),
            tooltip: 'Retour',
          ),
          const Spacer(),
          if (onShare != null)
            IconButton(
              onPressed: onShare,
              icon: Icon(Icons.open_in_new, color: palette.ink, size: 20),
              tooltip: 'Ouvrir la source',
            ),
          IconButton(
            onPressed: onToggleFavorite,
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? palette.accent : palette.ink,
            ),
            tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
        ],
      ),
    );
  }
}

class _EditionBar extends StatelessWidget {
  const _EditionBar({required this.item});

  final CyberItem item;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final editionLabel = item.editionNumber != null
        ? '№${item.editionNumber!.toString().padLeft(3, '0')}'
        : '№—';
    final typeLabel = item.type.toUpperCase();
    final dateLabel = DateFormat("dd·MM·yyyy · HH:mm", 'fr_FR').format(item.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$editionLabel · $typeLabel',
                style: AppText.monoLabel(palette.inkSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(dateLabel, style: AppText.monoLabel(palette.inkSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: palette.border),
      ],
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.item});

  final CyberItem item;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final cells = <Widget>[];
    if (item.primaryCve != null) {
      cells.add(_MetaCell(label: 'CVE', value: item.primaryCve!, mono: true));
    }
    if (item.cvss != null) {
      cells.add(_MetaCell(
        label: 'CVSS',
        value: item.cvss!.toStringAsFixed(1),
        mono: true,
        accent: true,
        big: true,
      ));
    }
    if (item.vendor != null) {
      cells.add(_MetaCell(label: 'Éditeur', value: item.vendor!));
    }
    if (item.product != null) {
      cells.add(_MetaCell(label: 'Produit', value: item.product!));
    }
    if (item.exploited) {
      cells.add(const _MetaCell(label: 'État', value: 'Exploitée', accent: true));
    }
    if (item.score > 0) {
      cells.add(_MetaCell(label: 'Score', value: item.score.toString(), mono: true));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppDims.radiusMd),
        border: Border.all(color: palette.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final half = (constraints.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 14,
            children: [
              for (final cell in cells)
                SizedBox(width: half, child: cell),
            ],
          );
        },
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.label,
    required this.value,
    this.mono = false,
    this.accent = false,
    this.big = false,
  });

  final String label;
  final String value;
  final bool mono;
  final bool accent;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final valueColor = accent ? palette.accent : palette.ink;
    final valueStyle = big
        ? AppText.monoEdition(valueColor).copyWith(fontSize: 20, fontWeight: FontWeight.w600)
        : mono
            ? AppText.monoData(valueColor)
            : AppText.bodySmall(valueColor).copyWith(fontSize: 13, fontWeight: FontWeight.w500);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppText.monoLabelSm(palette.inkTertiary),
        ),
        const SizedBox(height: 4),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _SourcesCard extends StatelessWidget {
  const _SourcesCard({required this.sources});

  final List<CyberSource> sources;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppDims.radiusMd),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < sources.length; i++) ...[
            _SourceRow(source: sources[i]),
            if (i < sources.length - 1)
              Filet(indent: 14, endIndent: 14),
          ],
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.source});

  final CyberSource source;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final host = _hostOf(source.url);
    return InkWell(
      onTap: () => launchUrl(
        Uri.parse(source.url),
        mode: LaunchMode.externalApplication,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(host, style: AppText.monoData(palette.accent)),
                  const SizedBox(height: 2),
                  Text(
                    source.name,
                    style: AppText.bodySmall(palette.ink).copyWith(fontSize: 12.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, size: 14, color: palette.inkSecondary),
          ],
        ),
      ),
    );
  }

  String _hostOf(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return url;
    }
  }
}

/// Rend le content Markdown avec la typo Scraber : Inter pour le texte
/// courant, Roboto Slab pour les titres, JetBrains Mono pour le code.
class _ContentMarkdown extends StatelessWidget {
  const _ContentMarkdown({required this.raw, required this.palette});

  final String raw;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppText.body(palette.ink).copyWith(height: 1.6);
    final mono = AppText.monoData(palette.ink).copyWith(fontSize: 12.5);
    return MarkdownBody(
      data: raw,
      selectable: true,
      softLineBreak: true,
      onTapLink: (_, href, __) {
        if (href != null) {
          launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
        }
      },
      styleSheet: MarkdownStyleSheet(
        p: bodyStyle,
        h1: AppText.slab26(palette.ink).copyWith(fontSize: 22, height: 1.25),
        h2: AppText.slab22(palette.ink).copyWith(fontSize: 19, height: 1.25),
        h3: AppText.slab17(palette.ink).copyWith(fontSize: 16, height: 1.3),
        h4: AppText.slab17(palette.ink).copyWith(fontSize: 15, height: 1.3),
        h5: bodyStyle.copyWith(fontWeight: FontWeight.w600),
        h6: bodyStyle.copyWith(fontWeight: FontWeight.w600),
        a: bodyStyle.copyWith(
          color: palette.accent,
          decoration: TextDecoration.underline,
        ),
        em: bodyStyle.copyWith(fontStyle: FontStyle.italic),
        strong: bodyStyle.copyWith(fontWeight: FontWeight.w600),
        blockquote: bodyStyle.copyWith(
          color: palette.inkSecondary,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: palette.surface,
          border: Border(left: BorderSide(color: palette.border, width: 3)),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        code: mono.copyWith(
          backgroundColor: palette.surface,
          fontSize: 12,
        ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: palette.surface,
          border: Border.all(color: palette.border),
          borderRadius: BorderRadius.circular(AppDims.radiusSm),
        ),
        listBullet: bodyStyle,
        tableHead: bodyStyle.copyWith(fontWeight: FontWeight.w600),
        tableBody: bodyStyle,
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.border)),
        ),
        h1Padding: const EdgeInsets.only(top: 12, bottom: 4),
        h2Padding: const EdgeInsets.only(top: 12, bottom: 4),
        h3Padding: const EdgeInsets.only(top: 10, bottom: 2),
      ),
    );
  }
}

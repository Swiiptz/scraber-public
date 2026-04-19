import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Bandeau signature d'un écran : top-line mono uppercase à gauche,
/// date/info à droite, filet 1 px, puis grand titre slab 32.
class EditionHeader extends StatelessWidget {
  const EditionHeader({
    super.key,
    required this.edition,
    this.trailing,
    required this.title,
  });

  /// Ex. `SCRABER · ÉDITION AVRIL 2026`
  final String edition;

  /// Ex. date du jour ou compteur, en mono.
  final String? trailing;

  /// Titre slab 32 sous la ligne.
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDims.sp5,
        AppDims.sp6,
        AppDims.sp5,
        AppDims.sp4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  edition.toUpperCase(),
                  style: AppText.monoLabel(palette.inkTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: AppText.monoLabel(palette.inkTertiary),
                ),
            ],
          ),
          const SizedBox(height: AppDims.sp3),
          Container(height: 1, color: palette.border),
          const SizedBox(height: AppDims.sp4),
          Text(title, style: AppText.slab32(palette.ink)),
        ],
      ),
    );
  }
}

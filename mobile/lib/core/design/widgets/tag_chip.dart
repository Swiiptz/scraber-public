import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Tag inline `#label` en mono. Pas de boîte ni de fond.
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Text.rich(
      TextSpan(
        style: AppText.monoTag(palette.inkSecondary),
        children: [
          TextSpan(
            text: '#',
            style: AppText.monoTag(palette.inkTertiary),
          ),
          TextSpan(text: label),
        ],
      ),
    );
  }
}

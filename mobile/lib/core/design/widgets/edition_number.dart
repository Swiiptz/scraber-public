import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Affichage signature `№XXX` (3 chiffres paddés) en JetBrains Mono.
class EditionNumber extends StatelessWidget {
  const EditionNumber(this.number, {super.key, this.color});

  final int? number;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = number == null
        ? '№—'
        : '№${number!.toString().padLeft(3, '0')}';
    return Text(text, style: AppText.monoEdition(color ?? palette.inkTertiary));
  }
}

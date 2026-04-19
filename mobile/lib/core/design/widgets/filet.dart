import 'package:flutter/material.dart';

import '../tokens.dart';

/// Filet horizontal 1 px, soft par défaut.
class Filet extends StatelessWidget {
  const Filet({super.key, this.hard = false, this.indent = 0, this.endIndent = 0});

  final bool hard;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      margin: EdgeInsetsDirectional.only(start: indent, end: endIndent),
      height: 1,
      color: hard ? palette.border : palette.borderSoft,
    );
  }
}

/// Séparateur vertical 1×10, pour le top row des cards.
class VerticalTick extends StatelessWidget {
  const VerticalTick({super.key, this.height = 10});

  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      width: 1,
      height: height,
      color: palette.border,
    );
  }
}

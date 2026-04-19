import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Pill de type (VULNÉRABILITÉ / ACTUALITÉ).
/// Transparente, bordure 1 px, texte secondaire.
class TypePill extends StatelessWidget {
  const TypePill(this.type, {super.key});

  final String type;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDims.pill),
        border: Border.all(color: palette.border, width: 1),
      ),
      child: Text(
        _label(type),
        style: AppText.pillType(palette.inkSecondary),
      ),
    );
  }

  String _label(String type) {
    switch (type.toUpperCase()) {
      case 'VULNERABILITE':
      case 'VULNÉRABILITÉ':
        return 'VULN.';
      case 'ACTUALITE':
      case 'ACTUALITÉ':
        return 'ACTU';
      default:
        return type.toUpperCase();
    }
  }
}

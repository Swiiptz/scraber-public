import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Chip de filtre pill façon bouton dropdown (label + chevron).
/// Actif = fond foncé (accent / ink) + texte clair.
class ScraberFilterChip extends StatelessWidget {
  const ScraberFilterChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.onClear,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final fg = active ? palette.background : palette.ink;
    final bg = active ? palette.ink : Colors.transparent;
    final borderColor = active ? palette.ink : palette.border;

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: borderColor, width: 1)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppText.bodySmall(fg).copyWith(fontSize: 12),
              ),
              const SizedBox(width: 5),
              if (active && onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 12, color: fg),
                )
              else
                Icon(Icons.expand_more, size: 14, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

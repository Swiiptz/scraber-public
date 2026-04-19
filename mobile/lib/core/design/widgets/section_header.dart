import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';

/// Label mono uppercase 10/600 + filet qui s'étend à droite.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDims.sp3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: AppText.monoLabel(palette.inkTertiary),
          ),
          const SizedBox(width: AppDims.sp3),
          Expanded(
            child: Container(
              height: 1,
              color: palette.borderSoft,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppDims.sp3),
            trailing!,
          ],
        ],
      ),
    );
  }
}

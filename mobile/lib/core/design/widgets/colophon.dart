import 'package:flutter/material.dart';

import '../tokens.dart';
import '../typography.dart';
import 'filet.dart';

/// Colophon éditorial `— Scraber · v1.0 —` encadré de filets.
class Colophon extends StatelessWidget {
  const Colophon({super.key, this.version = 'v1.0', this.label = 'Scraber'});

  final String version;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDims.sp5,
        vertical: AppDims.sp6,
      ),
      child: Column(
        children: [
          const Filet(),
          const SizedBox(height: AppDims.sp4),
          Text(
            '— $label · $version —',
            style: AppText.monoLabelSm(palette.inkTertiary),
          ),
          const SizedBox(height: AppDims.sp4),
          const Filet(),
        ],
      ),
    );
  }
}

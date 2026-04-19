import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../services/notification_service.dart';
import '../../services/preferences_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final prefs = ref.watch(preferencesControllerProvider);
    final controller = ref.read(preferencesControllerProvider.notifier);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const EditionHeader(
              edition: 'SCRABER · CONFIGURATION',
              trailing: 'v1.0',
              title: 'Paramètres',
            ),
            const SizedBox(height: 4),
            _SettingsGroup(
              label: 'Notifications',
              child: Column(
                children: [
                  _ThresholdRow(
                    value: prefs.threshold,
                    onChanged: (value) async {
                      await controller.setThreshold(value);
                      await NotificationService.syncThreshold(value);
                    },
                  ),
                  _Divider(),
                  _ToggleRow(
                    label: 'Heures silencieuses',
                    hint: 'Pas de notification 22 h → 07 h.',
                    value: prefs.quietHours,
                    onChanged: controller.setQuietHours,
                  ),
                ],
              ),
            ),
            _SettingsGroup(
              label: 'Apparence',
              child: _ThemeRow(
                value: prefs.themeMode,
                onChanged: controller.setThemeMode,
              ),
            ),
            _SettingsGroup(
              label: 'À propos',
              child: Column(
                children: [
                  _InfoRow(label: 'Version', value: '1.0.0'),
                  _Divider(),
                  _InfoRow(
                    label: 'Source de données',
                    value: 'Firebase',
                  ),
                  _Divider(),
                  _InfoRow(
                    label: 'Rythme de collecte',
                    value: 'Toutes les 2 h',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Colophon(),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: SectionHeader(label),
          ),
          Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppDims.radiusMd),
              border: Border.all(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(height: 1, color: palette.borderSoft);
  }
}

class _ThresholdRow extends StatelessWidget {
  const _ThresholdRow({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seuil de notification',
            style: AppText.body(palette.ink)
                .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Recevoir une alerte à partir de ce niveau de sévérité.',
            style: AppText.bodySmall(palette.inkSecondary)
                .copyWith(fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          _ThresholdPicker(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ThresholdPicker extends StatelessWidget {
  const _ThresholdPicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const List<({String id, String short})> _levels = [
    (id: 'CRITIQUE', short: 'CRIT.'),
    (id: 'ELEVEE', short: 'ÉLEV.'),
    (id: 'MOYENNE', short: 'MOY.'),
    (id: 'FAIBLE', short: 'FAIB.'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Row(
      children: [
        for (final level in _levels) ...[
          Expanded(
            child: _ThresholdTile(
              active: level.id == value,
              label: level.short,
              colors: palette.forLevel(level.id),
              onTap: () => onChanged(level.id),
            ),
          ),
          if (level.id != _levels.last.id) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _ThresholdTile extends StatelessWidget {
  const _ThresholdTile({
    required this.active,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  final bool active;
  final String label;
  final ({Color fg, Color bg}) colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppDims.radiusSm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? colors.bg : palette.surface,
          borderRadius: BorderRadius.circular(AppDims.radiusSm),
          border: Border.all(
            color: active ? colors.fg : palette.border,
            width: active ? 1.4 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppText.pillLevel(
                active ? colors.fg : palette.inkSecondary,
              ).copyWith(fontSize: 10.5, fontWeight: active ? FontWeight.w700 : FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thème',
            style: AppText.body(palette.ink)
                .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          _Segmented<ThemeMode>(
            value: value,
            onChanged: onChanged,
            options: const [
              (value: ThemeMode.light, label: 'Clair'),
              (value: ThemeMode.dark, label: 'Sombre'),
              (value: ThemeMode.system, label: 'Système'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<({T value, String label})> options;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: palette.backgroundAlt,
        borderRadius: BorderRadius.circular(AppDims.radiusSm + 2),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _SegmentedItem(
                active: option.value == value,
                label: option.label,
                onTap: () => onChanged(option.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentedItem extends StatelessWidget {
  const _SegmentedItem({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDims.radiusSm),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? palette.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDims.radiusSm),
          border: Border.all(
            color: active ? palette.border : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.bodySmall(
              active ? palette.ink : palette.inkSecondary,
            ).copyWith(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppText.body(palette.ink)
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hint,
                    style: AppText.bodySmall(palette.inkSecondary)
                        .copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: palette.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.body(palette.ink)
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value.toUpperCase(),
            style: AppText.monoLabelSm(palette.inkSecondary)
                .copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

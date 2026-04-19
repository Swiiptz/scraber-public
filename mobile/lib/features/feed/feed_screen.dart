import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/design/design.dart';
import '../../models/cyber_item.dart';
import '../../services/item_repository.dart';
import '../../utils/date_format.dart';
import 'feed_controller.dart';
import 'item_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final filters = ref.watch(feedFiltersProvider);
    final itemsAsync = ref.watch(feedItemsProvider);
    final rawAsync = ref.watch(itemsStreamProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              editionLabel: _latestEditionLabel(rawAsync.valueOrNull),
              onCalendarTap: () => _openCalendar(context),
            ),
            _SearchRow(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(feedFiltersProvider.notifier).setQuery(value),
              onCalendarTap: () => _openCalendar(context),
            ),
            const SizedBox(height: 10),
            _FilterBar(),
            if (filters.day != null) _DayBanner(day: filters.day!),
            const SizedBox(height: 6),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(itemsStreamProvider);
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: itemsAsync.when(
                  data: (items) => items.isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              ItemCard(item: items[index]),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Impossible de charger le flux.\n$error',
                          style: AppText.body(palette.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _latestEditionLabel(List<CyberItem>? items) {
    if (items == null || items.isEmpty) return null;
    final latest = items
        .map((item) => item.editionNumber)
        .whereType<int>()
        .fold<int>(0, (max, n) => n > max ? n : max);
    if (latest <= 0) return null;
    return 'N° ${latest.toString().padLeft(3, '0')}';
  }

  Future<void> _openCalendar(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppPalette.of(context).surface,
      isScrollControlled: true,
      builder: (_) => const _CalendarSheet(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.editionLabel, required this.onCalendarTap});

  final String? editionLabel;
  final VoidCallback onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return EditionHeader(
      edition: 'SCRABER · ${editionLabel ?? "VEILLE"}',
      trailing: longHeaderDateFr(DateTime.now()),
      title: 'Flux',
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onCalendarTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCalendarTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDims.sp5, 0, AppDims.sp5, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(AppDims.radiusMd),
                border: Border.all(color: palette.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: palette.inkSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: AppText.bodySmall(palette.ink).copyWith(
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: 'Rechercher CVE, vendeur, tag…',
                        hintStyle: AppText.bodySmall(palette.inkTertiary)
                            .copyWith(fontSize: 13.5),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkResponse(
            onTap: onCalendarTap,
            radius: 24,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(AppDims.radiusMd),
                border: Border.all(color: palette.border),
              ),
              child: Icon(Icons.calendar_today_outlined,
                  size: 18, color: palette.ink),
            ),
          ),
        ],
      ),
    );
  }
}

enum _FilterKind { level, type, tag, source }

const _kindLabels = {
  _FilterKind.level: 'Niveau',
  _FilterKind.type: 'Type',
  _FilterKind.tag: 'Tag',
  _FilterKind.source: 'Source',
};

const _kindIcons = {
  _FilterKind.level: Icons.warning_amber_rounded,
  _FilterKind.type: Icons.category_outlined,
  _FilterKind.tag: Icons.sell_outlined,
  _FilterKind.source: Icons.rss_feed_rounded,
};

class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(feedFiltersProvider);
    final options = ref.watch(filterOptionsProvider);
    final controller = ref.read(feedFiltersProvider.notifier);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDims.sp5),
        children: [
          _buildChip(
            context: context,
            kind: _FilterKind.level,
            selected: filters.level,
            options: options['levels'] ?? const [],
            onSelected: controller.setLevel,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            kind: _FilterKind.type,
            selected: filters.type,
            options: options['types'] ?? const [],
            onSelected: controller.setType,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            kind: _FilterKind.tag,
            selected: filters.tag,
            options: options['tags'] ?? const [],
            onSelected: controller.setTag,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            kind: _FilterKind.source,
            selected: filters.source,
            options: options['sources'] ?? const [],
            onSelected: controller.setSource,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required _FilterKind kind,
    required String? selected,
    required List<String> options,
    required ValueChanged<String?> onSelected,
  }) {
    final label = selected ?? _kindLabels[kind]!;
    return ScraberFilterChip(
      label: label,
      active: selected != null,
      onTap: () => _openFilterSheet(
        context: context,
        kind: kind,
        values: options,
        selected: selected,
        onPicked: onSelected,
      ),
      onClear: selected != null ? () => onSelected(null) : null,
    );
  }
}

Future<void> _openFilterSheet({
  required BuildContext context,
  required _FilterKind kind,
  required List<String> values,
  required String? selected,
  required ValueChanged<String?> onPicked,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (sheetContext) => _FilterSheet(
      kind: kind,
      values: values,
      selected: selected,
      onPicked: (value) {
        onPicked(value);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.kind,
    required this.values,
    required this.selected,
    required this.onPicked,
  });

  final _FilterKind kind;
  final List<String> values;
  final String? selected;
  final ValueChanged<String?> onPicked;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDims.radiusLg),
        ),
        border: Border(top: BorderSide(color: palette.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(AppDims.pill),
                ),
              ),
            ),
            _FilterSheetHeader(
              kind: kind,
              hasSelection: selected != null,
              onReset: () => onPicked(null),
            ),
            Flexible(
              child: values.isEmpty
                  ? _FilterSheetEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppDims.sp3,
                        AppDims.sp2,
                        AppDims.sp3,
                        AppDims.sp4,
                      ),
                      itemCount: values.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final value = values[i];
                        return _FilterOptionRow(
                          kind: kind,
                          value: value,
                          isSelected: value == selected,
                          onTap: () => onPicked(value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheetHeader extends StatelessWidget {
  const _FilterSheetHeader({
    required this.kind,
    required this.hasSelection,
    required this.onReset,
  });

  final _FilterKind kind;
  final bool hasSelection;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDims.sp5,
        AppDims.sp3,
        AppDims.sp3,
        AppDims.sp3,
      ),
      child: Row(
        children: [
          Icon(_kindIcons[kind], size: 18, color: palette.inkSecondary),
          const SizedBox(width: 10),
          Text(
            'Filtrer par ${_kindLabels[kind]!.toLowerCase()}',
            style: AppText.bodySmall(palette.ink).copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (hasSelection)
            TextButton.icon(
              onPressed: onReset,
              icon: Icon(Icons.close_rounded, size: 16, color: palette.critique),
              label: Text(
                'Effacer',
                style: AppText.bodySmall(palette.critique).copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDims.sp2,
                  vertical: AppDims.sp1,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterSheetEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDims.sp5,
        AppDims.sp5,
        AppDims.sp5,
        AppDims.sp6,
      ),
      child: Column(
        children: [
          Icon(Icons.filter_alt_off_outlined,
              size: 28, color: palette.inkTertiary),
          const SizedBox(height: AppDims.sp2),
          Text(
            'Aucune option disponible',
            style: AppText.bodySmall(palette.inkSecondary),
          ),
        ],
      ),
    );
  }
}

class _FilterOptionRow extends StatelessWidget {
  const _FilterOptionRow({
    required this.kind,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final _FilterKind kind;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final bg = isSelected ? palette.accentSoft : Colors.transparent;
    final borderColor = isSelected ? palette.accent : palette.borderSoft;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppDims.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDims.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDims.sp3,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDims.radiusMd),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: _valueRepresentation(context, palette)),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check,
                      size: 12, color: palette.background),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rend la valeur filtrée avec la visuelle qui correspond à sa nature.
  Widget _valueRepresentation(BuildContext context, AppPalette palette) {
    switch (kind) {
      case _FilterKind.level:
        return Row(
          children: [
            LevelPill(value),
            const SizedBox(width: AppDims.sp2),
            Text(
              _levelDescriptor(value),
              style: AppText.bodySmall(palette.inkSecondary),
            ),
          ],
        );
      case _FilterKind.type:
        return Row(
          children: [
            TypePill(value),
            const SizedBox(width: AppDims.sp2),
            Text(
              value.toLowerCase(),
              style: AppText.body(palette.ink).copyWith(fontSize: 13.5),
            ),
          ],
        );
      case _FilterKind.tag:
        return Row(
          children: [
            Icon(Icons.sell_outlined, size: 14, color: palette.inkTertiary),
            const SizedBox(width: 8),
            Text(
              value,
              style: AppText.monoTag(palette.ink).copyWith(fontSize: 12.5),
            ),
          ],
        );
      case _FilterKind.source:
        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: palette.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: AppText.body(palette.ink).copyWith(fontSize: 13.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
    }
  }

  String _levelDescriptor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITIQUE':
        return 'CVSS ≥ 9.0';
      case 'ELEVEE':
      case 'ÉLEVÉE':
        return 'CVSS 7.0 – 8.9';
      case 'MOYENNE':
        return 'CVSS 4.0 – 6.9';
      case 'FAIBLE':
        return 'CVSS < 4.0';
      default:
        return '';
    }
  }
}

class _DayBanner extends ConsumerWidget {
  const _DayBanner({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDims.sp5, 6, AppDims.sp5, 0),
      child: Row(
        children: [
          Icon(Icons.event, size: 14, color: palette.inkSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(day),
              style: AppText.bodySmall(palette.inkSecondary),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              foregroundColor: palette.accent,
            ),
            onPressed: () =>
                ref.read(feedFiltersProvider.notifier).setDay(null),
            child: Text(
              'Tout voir',
              style: AppText.bodySmall(palette.accent)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined,
                  size: 48, color: palette.inkTertiary),
              const SizedBox(height: 16),
              Text(
                'Aucun contenu pour cette sélection.',
                style: AppText.body(palette.inkSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalendarSheet extends ConsumerWidget {
  const _CalendarSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final items = ref.watch(itemsStreamProvider).valueOrNull ?? const [];
    final filters = ref.watch(feedFiltersProvider);
    final selectedDay = filters.day ?? DateTime.now();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: TableCalendar<CyberItem>(
          locale: 'fr_FR',
          firstDay: DateTime(2020),
          lastDay: DateTime.now().add(const Duration(days: 1)),
          focusedDay: selectedDay,
          selectedDayPredicate: (day) => isSameDay(day, filters.day),
          eventLoader: (day) =>
              items.where((item) => isSameDay(item.date, day)).toList(),
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Mois'},
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppText.slab22(palette.ink),
            leftChevronIcon: Icon(Icons.chevron_left, color: palette.ink),
            rightChevronIcon: Icon(Icons.chevron_right, color: palette.ink),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppText.monoLabelSm(palette.inkTertiary),
            weekendStyle: AppText.monoLabelSm(palette.inkTertiary),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: BoxDecoration(
              color: palette.accentSoft,
              shape: BoxShape.circle,
            ),
            todayTextStyle: AppText.body(palette.ink),
            selectedDecoration: BoxDecoration(
              color: palette.accent,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: AppText.body(Colors.white),
            defaultTextStyle: AppText.body(palette.ink),
            weekendTextStyle: AppText.body(palette.ink),
          ),
          onDaySelected: (selected, _) {
            ref.read(feedFiltersProvider.notifier).setDay(selected);
            Navigator.of(context).pop();
          },
          calendarBuilders: CalendarBuilders<CyberItem>(
            markerBuilder: (context, day, dayItems) {
              if (dayItems.isEmpty) return const SizedBox.shrink();
              final colors = _markerColors(palette, dayItems);
              return Positioned(
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final color in colors.take(3))
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Color> _markerColors(AppPalette palette, List<CyberItem> items) {
    final levels = items.map((item) => item.level.toUpperCase()).toSet();
    return [
      if (levels.contains('CRITIQUE')) palette.critique,
      if (levels.contains('ELEVEE') || levels.contains('ÉLEVÉE'))
        palette.elevee,
      if (levels.contains('MOYENNE')) palette.moyenne,
      if (levels.contains('FAIBLE')) palette.faible,
    ];
  }
}

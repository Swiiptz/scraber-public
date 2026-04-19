import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/cyber_item.dart';
import '../../services/item_repository.dart';

final feedFiltersProvider =
    StateNotifierProvider<FeedFiltersController, FeedFilters>((ref) {
  return FeedFiltersController();
});

final feedItemsProvider = Provider<AsyncValue<List<CyberItem>>>((ref) {
  final raw = ref.watch(itemsStreamProvider);
  final filters = ref.watch(feedFiltersProvider);
  return raw.whenData((items) => filters.apply(items));
});

final filterOptionsProvider = Provider<Map<String, List<String>>>((ref) {
  final items = ref.watch(itemsStreamProvider).valueOrNull ?? const [];
  return filtersFromItems(items);
});

@immutable
class FeedFilters {
  const FeedFilters({
    this.query = '',
    this.type,
    this.level,
    this.tag,
    this.source,
    this.day,
  });

  final String query;
  final String? type;
  final String? level;
  final String? tag;
  final String? source;
  final DateTime? day;

  bool get hasFilters =>
      type != null ||
      level != null ||
      tag != null ||
      source != null ||
      day != null ||
      query.trim().length >= 2;

  FeedFilters copyWith({
    String? query,
    String? type,
    String? level,
    String? tag,
    String? source,
    DateTime? day,
    bool clearType = false,
    bool clearLevel = false,
    bool clearTag = false,
    bool clearSource = false,
    bool clearDay = false,
  }) {
    return FeedFilters(
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      level: clearLevel ? null : (level ?? this.level),
      tag: clearTag ? null : (tag ?? this.tag),
      source: clearSource ? null : (source ?? this.source),
      day: clearDay ? null : (day ?? this.day),
    );
  }

  List<CyberItem> apply(List<CyberItem> items) {
    final needle = query.trim().toLowerCase();
    return items.where((item) {
      if (type != null && item.type != type) return false;
      if (level != null && item.level != level) return false;
      if (tag != null && !item.tags.contains(tag)) return false;
      if (source != null && !item.sources.any((s) => s.name == source)) {
        return false;
      }
      if (day != null && !isSameDay(item.date, day!)) return false;
      if (needle.length >= 2) {
        final inTitle = item.title.toLowerCase().contains(needle);
        final inSummary = item.summary.toLowerCase().contains(needle);
        final inTags = item.tags.any((t) => t.toLowerCase().contains(needle));
        final inCves = item.cves.any((c) => c.toLowerCase().contains(needle));
        final inProduct =
            item.product?.toLowerCase().contains(needle) ?? false;
        final inVendor = item.vendor?.toLowerCase().contains(needle) ?? false;
        if (!(inTitle || inSummary || inTags || inCves || inProduct || inVendor)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

class FeedFiltersController extends StateNotifier<FeedFilters> {
  FeedFiltersController() : super(const FeedFilters());

  void setQuery(String query) => state = state.copyWith(query: query);

  void setType(String? type) {
    state = type == null
        ? state.copyWith(clearType: true)
        : state.copyWith(type: type);
  }

  void setLevel(String? level) {
    state = level == null
        ? state.copyWith(clearLevel: true)
        : state.copyWith(level: level);
  }

  void setTag(String? tag) {
    state = tag == null
        ? state.copyWith(clearTag: true)
        : state.copyWith(tag: tag);
  }

  void setSource(String? source) {
    state = source == null
        ? state.copyWith(clearSource: true)
        : state.copyWith(source: source);
  }

  void setDay(DateTime? day) {
    state = day == null
        ? state.copyWith(clearDay: true)
        : state.copyWith(day: DateTime(day.year, day.month, day.day));
  }

  void clearAll() => state = const FeedFilters();
}
